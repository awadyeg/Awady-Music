import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/core/util/semaphore.dart';
import 'package:awady_music/data/db/app_database.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/sources/ytstream/client_constants.dart';
import 'package:awady_music/data/sources/ytstream/stream_resolver_impl.dart';
import 'package:awady_music/data/sources/ytstream/stream_resolver_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum DownloadStatus { queued, downloading, completed, failed, cancelled }

class DownloadProgress {
  const DownloadProgress({
    required this.trackId,
    required this.status,
    this.bytesReceived = 0,
    this.totalBytes = 0,
    this.error,
  });

  final String trackId;
  final DownloadStatus status;
  final int bytesReceived;
  final int totalBytes;
  final String? error;

  double get progress =>
      totalBytes > 0 ? (bytesReceived / totalBytes).clamp(0.0, 1.0) : 0.0;
}

class DownloadsRepository {
  DownloadsRepository({
    required this.db,
    required this.streamResolver,
    Dio? dio,
    Connectivity? connectivity,
    this.ref,
    Future<Directory> Function()? getDownloadsDir,
  }) : _dio = dio ?? Dio(),
       _connectivity = connectivity ?? Connectivity(),
       _customGetDownloadsDir = getDownloadsDir,
       _semaphore = Semaphore(2);

  final AppDatabase db;
  final StreamResolver streamResolver;
  final Dio _dio;
  final Connectivity _connectivity;
  final Ref? ref;
  final Future<Directory> Function()? _customGetDownloadsDir;
  final Semaphore _semaphore;

  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, DownloadProgress> _progressMap = {};
  final _progressStreamController =
      StreamController<Map<String, DownloadProgress>>.broadcast();

  Stream<Map<String, DownloadProgress>> get progressStream =>
      _progressStreamController.stream;

  Map<String, DownloadProgress> get currentProgress =>
      Map.unmodifiable(_progressMap);

  DownloadProgress? getProgress(String trackId) => _progressMap[trackId];

  Future<Directory> getDownloadsDirectory() async {
    if (_customGetDownloadsDir != null) {
      return await _customGetDownloadsDir();
    }
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'downloads'));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  static String sanitizeFilename(String artist, String title) {
    final raw = '$artist - $title';
    final cleaned = raw.replaceAll(RegExp(r'[\\/:*?"<>|\r\n\t]'), '_').trim();
    return cleaned.isEmpty ? 'track' : cleaned;
  }

  void _updateProgress(
    String trackId,
    DownloadStatus status, {
    int bytesReceived = 0,
    int totalBytes = 0,
    String? error,
  }) {
    _progressMap[trackId] = DownloadProgress(
      trackId: trackId,
      status: status,
      bytesReceived: bytesReceived,
      totalBytes: totalBytes,
      error: error,
    );
    if (!_progressStreamController.isClosed) {
      _progressStreamController.add(Map.unmodifiable(_progressMap));
    }
  }

  Future<bool> isDownloaded(String trackId) async {
    final entry = await db.downloadsDao.getDownload(trackId);
    if (entry == null) return false;
    return File(entry.filePath).existsSync();
  }

  Future<String?> getDownloadedFilePath(String trackId) async {
    final entry = await db.downloadsDao.getDownload(trackId);
    if (entry == null) return null;
    final file = File(entry.filePath);
    return file.existsSync() ? entry.filePath : null;
  }

  Future<void> enqueueDownload(Track track) async {
    // If already downloaded, nothing to do
    if (await isDownloaded(track.id)) return;

    if (_progressMap[track.id]?.status == DownloadStatus.downloading ||
        _progressMap[track.id]?.status == DownloadStatus.queued) {
      return;
    }

    _updateProgress(track.id, DownloadStatus.queued);

    unawaited(
      _semaphore.run(() async {
        await _executeDownload(track);
      }),
    );
  }

  Future<void> _executeDownload(Track track) async {
    if (_progressMap[track.id]?.status == DownloadStatus.cancelled) return;

    // Check Wi-Fi only restriction if enabled
    final wifiOnly = ref?.read(settingsProvider).wifiOnlyDownloads ?? false;
    if (wifiOnly) {
      final connectivity = await _connectivity.checkConnectivity();
      final hasWifi =
          connectivity.contains(ConnectivityResult.wifi) ||
          connectivity.contains(ConnectivityResult.ethernet);
      if (!hasWifi) {
        Log.w('Download skipped for ${track.id}: Wi-Fi only required');
        _updateProgress(
          track.id,
          DownloadStatus.failed,
          error: 'Wi-Fi required',
        );
        return;
      }
    }

    _updateProgress(track.id, DownloadStatus.downloading);
    final cancelToken = CancelToken();
    _cancelTokens[track.id] = cancelToken;

    String? partPath;
    try {
      final dir = await getDownloadsDirectory();
      final filename = sanitizeFilename(track.artist.name, track.title);
      final finalPath = p.join(dir.path, '$filename.m4a');
      partPath = p.join(dir.path, '$filename.m4a.part');

      // Resolve audio stream
      final videoId = track.streamId ?? track.id;
      final info = await streamResolver.resolve(videoId);
      final isVisionOs = info.url.queryParameters['c'] == 'VISIONOS';

      // Download audio file to .part first
      await _dio.download(
        info.url.toString(),
        partPath,
        cancelToken: cancelToken,
        options: isVisionOs
            ? Options(headers: const {'User-Agent': visionOsUserAgent})
            : null,
        onReceiveProgress: (received, total) {
          _updateProgress(
            track.id,
            DownloadStatus.downloading,
            bytesReceived: received,
            totalBytes: total,
          );
        },
      );

      // Atomic rename
      final partFile = File(partPath);
      if (partFile.existsSync()) {
        final destFile = File(finalPath);
        if (destFile.existsSync()) {
          destFile.deleteSync();
        }
        partFile.renameSync(finalPath);
      }

      // Save track metadata and download record to DB
      await db.libraryDao.upsertTrack(track.id, jsonEncode(track.toJson()));
      await db.downloadsDao.insertDownload(track.id, finalPath, DateTime.now());

      _updateProgress(track.id, DownloadStatus.completed);
      Log.i('Successfully downloaded track ${track.id} to $finalPath');
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        Log.i('Download cancelled for ${track.id}');
        _updateProgress(track.id, DownloadStatus.cancelled);
      } else {
        Log.e('Failed downloading track ${track.id}: $e', e);
        _updateProgress(track.id, DownloadStatus.failed, error: e.message);
      }
      if (partPath != null) {
        final partFile = File(partPath);
        if (partFile.existsSync()) {
          try {
            partFile.deleteSync();
          } on Object catch (_) {}
        }
      }
    } on Object catch (e, st) {
      Log.e('Unexpected error downloading track ${track.id}: $e', e, st);
      _updateProgress(track.id, DownloadStatus.failed, error: e.toString());
      if (partPath != null) {
        final partFile = File(partPath);
        if (partFile.existsSync()) {
          try {
            partFile.deleteSync();
          } on Object catch (_) {}
        }
      }
    } finally {
      _cancelTokens.remove(track.id);
    }
  }

  void cancelDownload(String trackId) {
    final token = _cancelTokens[trackId];
    if (token != null && !token.isCancelled) {
      token.cancel();
    }
    _updateProgress(trackId, DownloadStatus.cancelled);
  }

  Future<void> deleteDownload(String trackId) async {
    cancelDownload(trackId);
    final entry = await db.downloadsDao.getDownload(trackId);
    if (entry != null) {
      final file = File(entry.filePath);
      if (file.existsSync()) {
        try {
          file.deleteSync();
        } on Object catch (_) {}
      }
      await db.downloadsDao.deleteDownload(trackId);
    }
    _progressMap.remove(trackId);
    if (!_progressStreamController.isClosed) {
      _progressStreamController.add(Map.unmodifiable(_progressMap));
    }
  }

  Future<void> pruneMissing() async {
    try {
      final all = await db.downloadsDao.getAllDownloads();
      for (final entry in all) {
        final file = File(entry.filePath);
        if (!file.existsSync()) {
          Log.i(
            'Pruning missing download: ${entry.trackId} at ${entry.filePath}',
          );
          await db.downloadsDao.deleteDownload(entry.trackId);
        }
      }

      // Clean up orphaned .part files
      final dir = await getDownloadsDirectory();
      if (dir.existsSync()) {
        final entities = dir.listSync();
        for (final entity in entities) {
          if (entity is File && entity.path.endsWith('.part')) {
            try {
              entity.deleteSync();
            } on Object catch (_) {}
          }
        }
      }
    } on Object catch (e, st) {
      Log.w('Error during pruneMissing: $e', e, st);
    }
  }

  Future<List<Track>> getDownloadedTracks() async {
    final all = await db.downloadsDao.getAllDownloads();
    final tracks = <Track>[];
    for (final entry in all) {
      final file = File(entry.filePath);
      if (!file.existsSync()) continue;

      final trackJson = await db.libraryDao.getTrackJson(entry.trackId);
      if (trackJson != null && trackJson.isNotEmpty) {
        try {
          final map = jsonDecode(trackJson) as Map<String, dynamic>;
          tracks.add(Track.fromJson(map));
        } on Object catch (_) {}
      }
    }
    return tracks;
  }

  Stream<List<Track>> watchDownloadedTracks() {
    return db.downloadsDao.watchAllDownloads().asyncMap((all) async {
      final tracks = <Track>[];
      for (final entry in all) {
        final file = File(entry.filePath);
        if (!file.existsSync()) continue;

        final trackJson = await db.libraryDao.getTrackJson(entry.trackId);
        if (trackJson != null && trackJson.isNotEmpty) {
          try {
            final map = jsonDecode(trackJson) as Map<String, dynamic>;
            tracks.add(Track.fromJson(map));
          } on Object catch (_) {}
        }
      }
      return tracks;
    });
  }

  void dispose() {
    for (final token in _cancelTokens.values) {
      if (!token.isCancelled) token.cancel();
    }
    _cancelTokens.clear();
    unawaited(_progressStreamController.close());
  }
}

final downloadsRepositoryProvider = Provider<DownloadsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final streamResolver = ref.watch(streamResolverProvider);
  final repo = DownloadsRepository(
    db: db,
    streamResolver: streamResolver,
    ref: ref,
  );
  ref.onDispose(repo.dispose);
  unawaited(repo.pruneMissing());
  return repo;
});

final downloadedTracksProvider = StreamProvider<List<Track>>((ref) {
  final repo = ref.watch(downloadsRepositoryProvider);
  return repo.watchDownloadedTracks();
});

final downloadProgressStreamProvider =
    StreamProvider<Map<String, DownloadProgress>>((ref) {
      final repo = ref.watch(downloadsRepositoryProvider);
      return repo.progressStream;
    });
