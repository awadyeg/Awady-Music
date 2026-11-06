import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/data/db/app_database.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/local_playlist.dart';
import 'package:awady_music/data/models/playlist_export.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/models/track_validator.dart';
import 'package:awady_music/data/sources/innertube/matcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Playlist reordering sort modes.
enum PlaylistSortMode { title, artist, duration }

/// Generates the lowest unused "My Playlist #N" name.
String nextPlaylistName(List<LocalPlaylist> playlists) {
  final reg = RegExp(r'^My Playlist #(\d+)$');
  final taken = <int>{};
  for (final p in playlists) {
    final m = reg.firstMatch(p.name);
    if (m != null) {
      final n = int.tryParse(m.group(1)!);
      if (n != null) taken.add(n);
    }
  }
  var n = 1;
  while (taken.contains(n)) {
    n++;
  }
  return 'My Playlist #$n';
}

/// Serializes a local playlist for export matching .freebify.json format.
String playlistExportJson(LocalPlaylist p) {
  final exportObj = PlaylistExport(
    name: p.name,
    exportedAt: DateTime.now().toUtc().toIso8601String(),
    tracks: p.tracks.map((t) {
      return PlaylistExportTrack(
        title: t.title,
        artist: t.artist.name,
        duration: t.duration,
        source: t.source.name,
        streamId: t.streamId,
        album: t.album?.name,
      );
    }).toList(),
  );
  return const JsonEncoder.withIndent('  ').convert(exportObj.toJson());
}

/// Interface for user library management (likes, recents, followed artists,
/// and local playlists).
abstract interface class LibraryRepository {
  List<Track> get likedTracks;
  List<String> get likedOrder;
  List<Track> get recents;
  List<LocalPlaylist> get playlists;
  List<Artist> get followedArtists;

  Stream<List<Track>> watchLikedTracks();
  Stream<List<Track>> watchRecentTracks();
  Stream<List<LocalPlaylist>> watchPlaylists();
  Stream<List<Artist>> watchFollowedArtists();

  bool isLiked(String id);
  void toggleLike(Track track);

  bool isFollowing(String id);
  void toggleFollow(Artist artist);

  void addRecent(Track track);

  String createPlaylist([String? name]);
  void renamePlaylist(String id, String name);
  void deletePlaylist(String id);
  void addToPlaylist(String id, Track track);
  void addTracksToPlaylist(String id, List<Track> tracks);
  void removeFromPlaylist(String id, String trackId);
  void moveInPlaylist(String id, int from, int to);
  void sortPlaylist(String id, PlaylistSortMode mode);
  void resolveTracks(Map<String, Track> hits);
  void dropTracks(List<String> ids);

  LocalPlaylist? getPlaylist(String id);
  Future<void> init();
}

/// In-memory and SQLite-backed implementation of [LibraryRepository].
class LibraryRepositoryImpl implements LibraryRepository {
  LibraryRepositoryImpl({this.db});

  final AppDatabase? db;

  final Map<String, Track> _liked = {};
  final List<String> _likedOrder = [];
  final List<Track> _recents = [];
  final List<LocalPlaylist> _playlists = [];
  final Map<String, Artist> _followed = {};
  final List<String> _followedOrder = [];

  final _likedController = StreamController<List<Track>>.broadcast();
  final _recentsController = StreamController<List<Track>>.broadcast();
  final _playlistsController =
      StreamController<List<LocalPlaylist>>.broadcast();
  final _followedController = StreamController<List<Artist>>.broadcast();

  @override
  List<Track> get likedTracks =>
      _likedOrder.map((id) => _liked[id]).whereType<Track>().toList();

  @override
  List<String> get likedOrder => List.unmodifiable(_likedOrder);

  @override
  List<Track> get recents => List.unmodifiable(_recents);

  @override
  List<LocalPlaylist> get playlists => List.unmodifiable(_playlists);

  @override
  List<Artist> get followedArtists =>
      _followedOrder.map((id) => _followed[id]).whereType<Artist>().toList();

  @override
  Stream<List<Track>> watchLikedTracks() => _likedController.stream;

  @override
  Stream<List<Track>> watchRecentTracks() => _recentsController.stream;

  @override
  Stream<List<LocalPlaylist>> watchPlaylists() => _playlistsController.stream;

  @override
  Stream<List<Artist>> watchFollowedArtists() => _followedController.stream;

  String _newPlaylistId() {
    final now = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final rnd = math.Random()
        .nextInt(1679616)
        .toRadixString(36)
        .padLeft(4, '0');
    return 'local-$now-$rnd';
  }

  @override
  Future<void> init() async {
    if (db == null) return;
    try {
      final likedIds = await db!.libraryDao.getLikedTrackIds();
      for (final id in likedIds) {
        final jsonStr = await db!.libraryDao.getTrackJson(id);
        if (jsonStr != null) {
          try {
            final json = jsonDecode(jsonStr);
            if (isValidTrack(json)) {
              final t = repairTrack(
                Track.fromJson(json as Map<String, dynamic>),
              );
              _liked[t.id] = t;
              _likedOrder.add(t.id);
            }
          } on Object catch (_) {}
        }
      }
      _likedController.add(likedTracks);

      final recentIds = await db!.libraryDao.getRecentTrackIds(50);
      for (final id in recentIds) {
        final jsonStr = await db!.libraryDao.getTrackJson(id);
        if (jsonStr != null) {
          try {
            final json = jsonDecode(jsonStr);
            if (isValidTrack(json)) {
              _recents.add(
                repairTrack(Track.fromJson(json as Map<String, dynamic>)),
              );
            }
          } on Object catch (_) {}
        }
      }
      _recentsController.add(recents);

      final followedJsons = await db!.libraryDao.getFollowedArtistJsons();
      for (final jsonStr in followedJsons) {
        try {
          final json = jsonDecode(jsonStr);
          if (isValidUser(json)) {
            final a = Artist.fromJson(json as Map<String, dynamic>);
            _followed[a.id] = a;
            _followedOrder.add(a.id);
          }
        } on Object catch (_) {}
      }
      _followedController.add(followedArtists);

      final dbPlaylists = await db!.playlistDao.getAllPlaylists();
      for (final pRow in dbPlaylists) {
        final trackRows = await db!.playlistDao.getPlaylistTracks(pRow.id);
        final tracks = <Track>[];
        for (final tr in trackRows) {
          final jsonStr = await db!.libraryDao.getTrackJson(tr.trackId);
          if (jsonStr != null) {
            try {
              final json = jsonDecode(jsonStr);
              if (isValidTrack(json)) {
                tracks.add(
                  repairTrack(Track.fromJson(json as Map<String, dynamic>)),
                );
              }
            } on Object catch (_) {}
          }
        }
        _playlists.add(
          LocalPlaylist(
            id: pRow.id,
            name: pRow.name,
            tracks: tracks,
            createdAt: pRow.createdAt,
          ),
        );
      }
      _playlistsController.add(playlists);
    } on Object catch (e) {
      Log.w('Failed to hydrate library repository from database: $e');
    }
  }

  @override
  bool isLiked(String id) => _liked.containsKey(id);

  @override
  void toggleLike(Track track) {
    if (_liked.containsKey(track.id)) {
      _liked.remove(track.id);
      _likedOrder.remove(track.id);
      if (db != null) {
        unawaited(db!.libraryDao.unlikeTrack(track.id));
      }
    } else {
      final repaired = repairTrack(track);
      _liked[track.id] = repaired;
      _likedOrder
        ..remove(track.id)
        ..insert(0, track.id);
      if (db != null) {
        final now = DateTime.now();
        unawaited(
          db!.libraryDao.upsertTrack(track.id, jsonEncode(slimTrack(repaired))),
        );
        unawaited(db!.libraryDao.likeTrack(track.id, now));
      }
    }
    _likedController.add(likedTracks);
  }

  @override
  bool isFollowing(String id) => _followed.containsKey(id);

  @override
  void toggleFollow(Artist artist) {
    if (_followed.containsKey(artist.id)) {
      _followed.remove(artist.id);
      _followedOrder.remove(artist.id);
      if (db != null) {
        unawaited(db!.libraryDao.unfollowArtist(artist.id));
      }
    } else {
      if (_followedOrder.length >= 500) return;
      _followed[artist.id] = artist;
      _followedOrder
        ..remove(artist.id)
        ..insert(0, artist.id);
      if (db != null) {
        final now = DateTime.now();
        unawaited(
          db!.libraryDao.followArtist(
            artist.id,
            jsonEncode(slimUser(artist)),
            now,
          ),
        );
      }
    }
    _followedController.add(followedArtists);
  }

  @override
  void addRecent(Track track) {
    final repaired = repairTrack(track);
    _recents.removeWhere((r) => r.id == track.id);
    _recents.insert(0, repaired);
    if (_recents.length > 50) {
      _recents.removeRange(50, _recents.length);
    }
    if (db != null) {
      final now = DateTime.now();
      unawaited(
        db!.libraryDao.upsertTrack(track.id, jsonEncode(slimTrack(repaired))),
      );
      unawaited(db!.libraryDao.addRecent(track.id, now));
    }
    _recentsController.add(recents);
  }

  @override
  String createPlaylist([String? name]) {
    final id = _newPlaylistId();
    final effectiveName = name?.trim().isNotEmpty == true
        ? name!.trim()
        : nextPlaylistName(_playlists);
    final now = DateTime.now();
    final p = LocalPlaylist(
      id: id,
      name: effectiveName,
      tracks: const [],
      createdAt: now,
    );
    _playlists.insert(0, p);
    if (db != null) {
      unawaited(db!.playlistDao.createPlaylist(id, effectiveName, now));
    }
    _playlistsController.add(playlists);
    return id;
  }

  @override
  void renamePlaylist(String id, String name) {
    final trimmed = name.trim();
    final idx = _playlists.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final current = _playlists[idx];
      final newName = trimmed.isNotEmpty ? trimmed : current.name;
      _playlists[idx] = current.copyWith(name: newName);
      if (db != null) {
        unawaited(db!.playlistDao.renamePlaylist(id, newName));
      }
      _playlistsController.add(playlists);
    }
  }

  @override
  void deletePlaylist(String id) {
    _playlists.removeWhere((p) => p.id == id);
    if (db != null) {
      unawaited(db!.playlistDao.deletePlaylist(id));
    }
    _playlistsController.add(playlists);
  }

  @override
  void addToPlaylist(String id, Track track) {
    final idx = _playlists.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final p = _playlists[idx];
      if (!p.tracks.any((t) => t.id == track.id)) {
        final repaired = repairTrack(track);
        final updatedTracks = [...p.tracks, repaired];
        _playlists[idx] = p.copyWith(tracks: updatedTracks);
        if (db != null) {
          unawaited(
            db!.libraryDao.upsertTrack(
              track.id,
              jsonEncode(slimTrack(repaired)),
            ),
          );
          unawaited(
            db!.playlistDao.addTrackToPlaylist(
              id,
              track.id,
              updatedTracks.length - 1,
            ),
          );
        }
        _playlistsController.add(playlists);
      }
    }
  }

  @override
  void addTracksToPlaylist(String id, List<Track> tracks) {
    final idx = _playlists.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final p = _playlists[idx];
      final have = p.tracks.map((t) => t.id).toSet();
      final toAdd = <Track>[];
      for (final t in tracks) {
        if (!have.contains(t.id)) {
          have.add(t.id);
          toAdd.add(repairTrack(t));
        }
      }
      if (toAdd.isNotEmpty) {
        final updatedTracks = [...p.tracks, ...toAdd];
        _playlists[idx] = p.copyWith(tracks: updatedTracks);
        if (db != null) {
          for (final t in toAdd) {
            unawaited(
              db!.libraryDao.upsertTrack(t.id, jsonEncode(slimTrack(t))),
            );
          }
          final entries = updatedTracks
              .map((t) => (trackId: t.id, pending: t.pending))
              .toList();
          unawaited(db!.playlistDao.setPlaylistTracks(id, entries));
        }
        _playlistsController.add(playlists);
      }
    }
  }

  @override
  void removeFromPlaylist(String id, String trackId) {
    final idx = _playlists.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final p = _playlists[idx];
      final updatedTracks = p.tracks.where((t) => t.id != trackId).toList();
      _playlists[idx] = p.copyWith(tracks: updatedTracks);
      if (db != null) {
        final entries = updatedTracks
            .map((t) => (trackId: t.id, pending: t.pending))
            .toList();
        unawaited(db!.playlistDao.setPlaylistTracks(id, entries));
      }
      _playlistsController.add(playlists);
    }
  }

  @override
  void moveInPlaylist(String id, int from, int to) {
    final idx = _playlists.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final p = _playlists[idx];
      if (from == to ||
          from < 0 ||
          to < 0 ||
          from >= p.tracks.length ||
          to >= p.tracks.length) {
        return;
      }
      final updatedTracks = List<Track>.from(p.tracks);
      final item = updatedTracks.removeAt(from);
      updatedTracks.insert(to, item);
      _playlists[idx] = p.copyWith(tracks: updatedTracks);
      if (db != null) {
        final entries = updatedTracks
            .map((t) => (trackId: t.id, pending: t.pending))
            .toList();
        unawaited(db!.playlistDao.setPlaylistTracks(id, entries));
      }
      _playlistsController.add(playlists);
    }
  }

  @override
  void sortPlaylist(String id, PlaylistSortMode mode) {
    final idx = _playlists.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final p = _playlists[idx];
      final sortedTracks = List<Track>.from(p.tracks)
        ..sort((a, b) {
          if (mode == PlaylistSortMode.duration) {
            final da = a.duration > 0 ? a.duration : 999999999;
            final db = b.duration > 0 ? b.duration : 999999999;
            return da.compareTo(db);
          }
          final ka = fold(
            mode == PlaylistSortMode.title ? a.title : a.artist.name,
          );
          final kb = fold(
            mode == PlaylistSortMode.title ? b.title : b.artist.name,
          );
          return ka.compareTo(kb);
        });
      _playlists[idx] = p.copyWith(tracks: sortedTracks);
      if (db != null) {
        final entries = sortedTracks
            .map((t) => (trackId: t.id, pending: t.pending))
            .toList();
        unawaited(db!.playlistDao.setPlaylistTracks(id, entries));
      }
      _playlistsController.add(playlists);
    }
  }

  @override
  void resolveTracks(Map<String, Track> hits) {
    if (hits.isEmpty) return;
    var touched = false;
    for (var i = 0; i < _playlists.length; i++) {
      final p = _playlists[i];
      if (p.tracks.any((t) => hits.containsKey(t.id))) {
        touched = true;
        final updated = p.tracks.map((t) => hits[t.id] ?? t).toList();
        _playlists[i] = p.copyWith(tracks: updated);
        if (db != null) {
          final entries = updated
              .map((t) => (trackId: t.id, pending: t.pending))
              .toList();
          unawaited(db!.playlistDao.setPlaylistTracks(p.id, entries));
        }
      }
    }
    if (touched) {
      _playlistsController.add(playlists);
    }
  }

  @override
  void dropTracks(List<String> ids) {
    if (ids.isEmpty) return;
    final gone = ids.toSet();
    var touched = false;
    for (var i = 0; i < _playlists.length; i++) {
      final p = _playlists[i];
      if (p.tracks.any((t) => gone.contains(t.id))) {
        touched = true;
        final updated = p.tracks.where((t) => !gone.contains(t.id)).toList();
        _playlists[i] = p.copyWith(tracks: updated);
        if (db != null) {
          final entries = updated
              .map((t) => (trackId: t.id, pending: t.pending))
              .toList();
          unawaited(db!.playlistDao.setPlaylistTracks(p.id, entries));
        }
      }
    }
    if (touched) {
      _playlistsController.add(playlists);
    }
  }

  @override
  LocalPlaylist? getPlaylist(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } on Object catch (_) {
      return null;
    }
  }
}

/// Provider for [LibraryRepository].
final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final repo = LibraryRepositoryImpl(db: db);
  unawaited(repo.init());
  return repo;
});

/// Reactive stream provider for liked tracks.
final likedTracksStreamProvider = StreamProvider<List<Track>>((ref) async* {
  final repo = ref.watch(libraryRepositoryProvider);
  try {
    yield repo.likedTracks;
    yield* repo.watchLikedTracks();
  } on Object catch (_) {
    yield const [];
  }
});

/// Reactive stream provider for followed artists.
final followedArtistsStreamProvider = StreamProvider<List<Artist>>((
  ref,
) async* {
  final repo = ref.watch(libraryRepositoryProvider);
  try {
    yield repo.followedArtists;
    yield* repo.watchFollowedArtists();
  } on Object catch (_) {
    yield const [];
  }
});
