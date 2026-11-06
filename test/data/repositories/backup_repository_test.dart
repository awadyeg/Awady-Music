import 'dart:convert';
import 'dart:io';

import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/local_playlist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/backup_repository.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/data/repositories/stats_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLibraryRepository implements LibraryRepository {
  final Map<String, Track> _liked = {};
  final Map<String, Artist> _followed = {};
  final List<LocalPlaylist> _playlists = [];

  @override
  List<Track> get likedTracks => _liked.values.toList();
  @override
  List<String> get likedOrder => _liked.keys.toList();
  @override
  List<Artist> get followedArtists => _followed.values.toList();
  @override
  List<LocalPlaylist> get playlists => List.unmodifiable(_playlists);
  @override
  List<Track> get recents => [];

  @override
  bool isLiked(String id) => _liked.containsKey(id);

  @override
  void toggleLike(Track track) {
    if (_liked.containsKey(track.id)) {
      _liked.remove(track.id);
    } else {
      _liked[track.id] = track;
    }
  }

  @override
  bool isFollowing(String id) => _followed.containsKey(id);

  @override
  void toggleFollow(Artist artist) {
    if (_followed.containsKey(artist.id)) {
      _followed.remove(artist.id);
    } else {
      _followed[artist.id] = artist;
    }
  }

  @override
  String createPlaylist([String? name]) {
    final id = 'local-${DateTime.now().millisecondsSinceEpoch}';
    final pl = LocalPlaylist(
      id: id,
      name: name ?? 'New Playlist',
      tracks: [],
      createdAt: DateTime.now(),
    );
    _playlists.add(pl);
    return id;
  }

  @override
  LocalPlaylist? getPlaylist(String id) {
    return _playlists.where((p) => p.id == id).firstOrNull;
  }

  @override
  void addTracksToPlaylist(String id, List<Track> tracks) {
    final idx = _playlists.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final cur = _playlists[idx];
      _playlists[idx] = cur.copyWith(tracks: [...cur.tracks, ...tracks]);
    }
  }

  @override
  void addToPlaylist(String id, Track track) =>
      addTracksToPlaylist(id, [track]);

  @override
  void renamePlaylist(String id, String name) {}
  @override
  void deletePlaylist(String id) {}
  @override
  void removeFromPlaylist(String id, String trackId) {}
  @override
  void moveInPlaylist(String id, int from, int to) {}
  @override
  void sortPlaylist(String id, PlaylistSortMode mode) {}
  @override
  void resolveTracks(Map<String, Track> hits) {}
  @override
  void dropTracks(List<String> ids) {}
  @override
  void addRecent(Track track) {}
  @override
  Future<void> init() async {}
  @override
  Stream<List<Track>> watchLikedTracks() => Stream.value(likedTracks);
  @override
  Stream<List<Track>> watchRecentTracks() => Stream.value([]);
  @override
  Stream<List<LocalPlaylist>> watchPlaylists() => Stream.value(playlists);
  @override
  Stream<List<Artist>> watchFollowedArtists() => Stream.value(followedArtists);
}

class _FakeSettingsNotifier extends SettingsNotifier {
  AppSettings _mockState = const AppSettings();

  @override
  AppSettings build() => _mockState;

  @override
  AppSettings get state => _mockState;

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    _mockState = _mockState.copyWith(themeMode: mode);
  }

  @override
  Future<void> setAutoplay({required bool autoplay}) async {
    _mockState = _mockState.copyWith(autoplay: autoplay);
  }

  @override
  Future<void> setWifiOnlyDownloads({required bool wifiOnly}) async {
    _mockState = _mockState.copyWith(wifiOnlyDownloads: wifiOnly);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeLibraryRepository libraryRepo;
  late StatsRepository statsRepo;
  late _FakeSettingsNotifier settingsNotifier;
  late BackupRepository repo;
  late Directory tempDir;

  setUp(() async {
    libraryRepo = _FakeLibraryRepository();
    statsRepo = StatsRepository();
    settingsNotifier = _FakeSettingsNotifier();
    tempDir = await Directory.systemTemp.createTemp('awady_backup_test_');

    repo = BackupRepository(
      libraryRepo: libraryRepo,
      statsRepo: statsRepo,
      settingsNotifier: settingsNotifier,
      getTempDir: () async => tempDir,
    );
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('BackupRepository tests', () {
    test('exportBackupJson produces valid JSON with all sections', () {
      const sampleTrack = Track(
        id: 't1',
        title: 'Song 1',
        artist: Artist(id: 'a1', name: 'Artist 1'),
        duration: 180,
      );
      libraryRepo
        ..toggleLike(sampleTrack)
        ..toggleFollow(const Artist(id: 'a1', name: 'Artist 1'));
      final pid = libraryRepo.createPlaylist('Favorites');
      libraryRepo.addTracksToPlaylist(pid, [sampleTrack]);

      final jsonStr = repo.exportBackupJson();
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(map['app'], equals('awadymusic'));
      expect(map['version'], equals(1));
      expect(map['exportedAt'], isNotNull);
      expect(map['library'], isNotNull);
      expect(map['stats'], isNotNull);
      expect(map['settings'], isNotNull);

      final lib = map['library'] as Map<String, dynamic>;
      expect(lib['liked'], isNotNull);
      expect(lib['playlists'], isNotEmpty);
      expect(lib['followedArtists'], isNotEmpty);
    });

    test('importBackupJson merges library items and updates stats', () async {
      final backupData = {
        'app': 'awadymusic',
        'version': 1,
        'library': {
          'liked': {
            'imported1': {
              'id': 'imported1',
              'title': 'Imported Track',
              'artist': {'id': 'impA', 'name': 'Imp Artist'},
              'duration': 200,
            },
          },
          'followedArtists': [
            {'id': 'artist_x', 'name': 'Star Artist'},
          ],
          'playlists': [
            {
              'id': 'local-imported-pl',
              'name': 'Rock Hits',
              'createdAt': '2026-11-05T00:00:00.000Z',
              'tracks': [
                {
                  'id': 'rock1',
                  'title': 'Rock Anthem',
                  'artist': {'id': 'impA', 'name': 'Imp Artist'},
                  'duration': 190,
                },
              ],
            },
          ],
        },
        'stats': {
          'totalMs': 500000,
          'totalPlays': 45,
          'days': {'2026-11-05': 120000},
          'months': {
            '2026-11': {
              'ms': 500000,
              'plays': 45,
              'tracks': <String, dynamic>{},
              'artists': <String, dynamic>{},
            },
          },
        },
        'settings': {
          'themeMode': 'light',
          'autoplay': false,
          'wifiOnlyDownloads': true,
        },
      };

      final result = await repo.importBackupJson(jsonEncode(backupData));

      expect(result.success, isTrue);
      expect(result.likedCount, 1);
      expect(result.artistsCount, 1);
      expect(result.playlistsCount, 1);
      expect(result.statsMerged, isTrue);

      expect(libraryRepo.isLiked('imported1'), isTrue);
      expect(libraryRepo.isFollowing('artist_x'), isTrue);
      expect(libraryRepo.playlists.length, 1);
      expect(libraryRepo.playlists.first.name, 'Rock Hits');

      expect(statsRepo.state.totalMs, 500000);
      expect(statsRepo.state.totalPlays, 45);

      expect(settingsNotifier.state.themeMode, ThemeMode.light);
      expect(settingsNotifier.state.autoplay, isFalse);
      expect(settingsNotifier.state.wifiOnlyDownloads, isTrue);
    });

    test('writeBackupToFile writes json file to temp dir', () async {
      final file = await repo.writeBackupToFile();
      expect(file.existsSync(), isTrue);
      expect(file.path.endsWith('.json'), isTrue);
      final read = file.readAsStringSync();
      expect(read.contains('awadymusic'), isTrue);
    });
  });
}
