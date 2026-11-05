import 'dart:async';
import 'dart:convert';

import 'package:awady_music/data/db/app_database.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:awady_music/data/sources/innertube/matcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class ImportProgress {
  const ImportProgress({required this.done, required this.total});

  final int done;
  final int total;

  ImportProgress copyWith({int? done, int? total}) =>
      ImportProgress(done: done ?? this.done, total: total ?? this.total);

  @override
  String toString() => 'ImportProgress(done: $done, total: $total)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImportProgress &&
          runtimeType == other.runtimeType &&
          done == other.done &&
          total == other.total;

  @override
  int get hashCode => Object.hash(done, total);
}

class ImportJob {
  ImportJob({required this.playlistId, required this.track, this.tries = 0});

  final String playlistId;
  final Track track;
  int tries;
}

class ImportQueue {
  ImportQueue({
    required this.libraryRepo,
    required this.innertubeClient,
    this.db,
    this.concurrency = 3,
  });

  static const int maxTries = 2;
  static const int defaultGapMs = 200;
  static const int quietGapMs = 1000;

  final LibraryRepository libraryRepo;
  final InnertubeClient innertubeClient;
  final AppDatabase? db;
  final int concurrency;

  final Map<String, ImportJob> _queued = {};
  final List<String> _order = [];
  final Map<String, Future<Track?>> _inflight = {};
  final Map<String, ImportProgress> _progress = {};

  final _progressController =
      StreamController<Map<String, ImportProgress>>.broadcast();
  bool _pumping = false;
  bool _disposed = false;

  Stream<Map<String, ImportProgress>> get progressStream =>
      _progressController.stream;

  Map<String, ImportProgress> get currentProgress =>
      Map.unmodifiable(_progress);

  int get queuedCount => _order.length;

  static String cacheKey(String title, String artist, int duration) {
    final cleanT = cleanText(title);
    final cleanA = cleanText(artist);
    return '$cleanA:$cleanT:$duration';
  }

  void _settle(String playlistId, int n) {
    if (n <= 0) return;
    final cur = _progress[playlistId];
    if (cur == null) return;

    final newDone = cur.done + n;
    if (newDone >= cur.total) {
      _progress.remove(playlistId);
    } else {
      _progress[playlistId] = cur.copyWith(done: newDone);
    }
    if (!_progressController.isClosed) {
      _progressController.add(Map.unmodifiable(_progress));
    }
  }

  void _dropQueued(String id) {
    _queued.remove(id);
    _order.remove(id);
  }

  Future<Track?> _resolveOne(Track track) async {
    final running = _inflight[track.id];
    if (running != null) return await running;

    final completer = Completer<Track?>();
    unawaited(_inflight[track.id] = completer.future);
    try {
      final res = await _doResolveOne(track);
      completer.complete(res);
      return res;
    } on Object {
      completer.complete(null);
      return null;
    } finally {
      unawaited(_inflight.remove(track.id));
    }
  }

  Future<Track?> _doResolveOne(Track track) async {
    final key = cacheKey(track.title, track.artist.name, track.duration);

    // Check DB cache
    if (db != null) {
      try {
        final cached = await db!.cacheDao.getSongMatch(key);
        if (cached != null) {
          final dynamic json = jsonDecode(cached);
          if (json is Map<String, dynamic>) {
            return Track.fromJson(json);
          }
        }
      } on Object {
        // Ignore cache read failures.
      }
    }

    // Query Innertube
    final query = MatchQuery(
      title: track.title,
      artist: track.artist.name,
      duration: track.duration,
    );

    try {
      final hit = await matchSingleTrack(innertubeClient, query);
      if (hit != null && db != null) {
        unawaited(
          db!.cacheDao
              .putSongMatch(key, jsonEncode(hit.toJson()))
              .catchError((_) {}),
        );
      }
      return hit;
    } on Object {
      return null;
    }
  }

  Future<Track?> resolveNow(Track track) async {
    if (!track.pending) return track;
    final hit = await _resolveOne(track);
    _dropQueued(track.id);
    if (hit != null) {
      libraryRepo.resolveTracks({track.id: hit});
    }
    return hit;
  }

  void enqueuePending(String playlistId, List<Track> tracks) {
    var added = 0;
    for (final track in tracks) {
      if (!track.pending || track.id.isEmpty) continue;
      if (_queued.containsKey(track.id) || _inflight.containsKey(track.id)) {
        continue;
      }
      _queued[track.id] = ImportJob(playlistId: playlistId, track: track);
      _order.add(track.id);
      added++;
    }
    if (added == 0) return;

    final cur =
        _progress[playlistId] ?? const ImportProgress(done: 0, total: 0);
    _progress[playlistId] = cur.copyWith(total: cur.total + added);
    if (!_progressController.isClosed) {
      _progressController.add(Map.unmodifiable(_progress));
    }

    unawaited(_pump());
  }

  void resumePending() {
    for (final playlist in libraryRepo.playlists) {
      final pendingTracks = playlist.tracks.where((t) => t.pending).toList();
      if (pendingTracks.isNotEmpty) {
        enqueuePending(playlist.id, pendingTracks);
      }
    }
  }

  Future<void> _pump() async {
    if (_pumping) return;
    _pumping = true;

    try {
      while (_order.isNotEmpty && !_disposed) {
        final count = _order.length < concurrency ? _order.length : concurrency;
        final ids = _order.sublist(0, count);
        final jobs = ids
            .map((id) => _queued[id])
            .whereType<ImportJob>()
            .toList();

        if (jobs.isEmpty) {
          _order.removeRange(0, count);
          continue;
        }

        final hits = await Future.wait(jobs.map((j) => _resolveOne(j.track)));

        final replace = <String, Track>{};
        final dead = <String>[];
        final retry = <String>[];
        final settled = <String, int>{};

        final allMissed = hits.every((h) => h == null);

        for (var i = 0; i < jobs.length; i++) {
          final job = jobs[i];
          final hit = hits[i];

          if (hit != null) {
            replace[job.track.id] = hit;
            _queued.remove(job.track.id);
            _order.remove(job.track.id);
            settled[job.playlistId] = (settled[job.playlistId] ?? 0) + 1;
          } else if (allMissed && jobs.length > 1 && job.tries < maxTries) {
            job.tries++;
            _order.remove(job.track.id);
            retry.add(job.track.id);
          } else {
            _queued.remove(job.track.id);
            _order.remove(job.track.id);
            dead.add(job.track.id);
            settled[job.playlistId] = (settled[job.playlistId] ?? 0) + 1;
          }
        }

        if (replace.isNotEmpty) {
          libraryRepo.resolveTracks(replace);
        }
        if (dead.isNotEmpty) {
          libraryRepo.dropTracks(dead);
        }

        _order.addAll(retry);

        settled.forEach(_settle);

        await Future<void>.delayed(
          Duration(milliseconds: allMissed ? quietGapMs : defaultGapMs),
        );
      }
    } finally {
      _pumping = false;
    }
  }

  void dispose() {
    _disposed = true;
    unawaited(_progressController.close());
  }
}

final importQueueProvider = Provider<ImportQueue>((ref) {
  final libraryRepo = ref.watch(libraryRepositoryProvider);
  final innertube = ref.watch(innertubeClientProvider);
  final db = ref.watch(appDatabaseProvider);

  final queue = ImportQueue(
    libraryRepo: libraryRepo,
    innertubeClient: innertube,
    db: db,
  );
  ref.onDispose(queue.dispose);
  return queue;
});

final importProgressProvider = StreamProvider<Map<String, ImportProgress>>((
  ref,
) {
  final queue = ref.watch(importQueueProvider);
  return queue.progressStream;
});
