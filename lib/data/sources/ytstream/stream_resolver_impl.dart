import 'dart:async';
import 'dart:collection';
import 'dart:io' show Platform;

import 'package:awady_music/data/models/stream_info.dart';
import 'package:awady_music/data/sources/ytstream/explode_resolver.dart';
import 'package:awady_music/data/sources/ytstream/visionos_resolver.dart';
import 'package:dio/dio.dart';

/// Thrown when no resolver in the chain could produce a valid playable stream.
class StreamUnavailableException implements Exception {
  const StreamUnavailableException(this.videoId);

  final String videoId;

  @override
  String toString() =>
      'StreamUnavailableException: video $videoId has no available stream';
}

/// Abstract storage interface for caching stream URLs in persistent database.
abstract interface class StreamCacheStorage {
  Future<String?> getStreamUrl(String videoId);
  Future<void> putStreamUrl(String videoId, String url, DateTime expiresAt);
}

/// Abstract interface for resolving audio stream URLs with caching and
/// prefetching.
abstract interface class StreamResolver {
  /// Resolves a playable [StreamInfo] for [videoId].
  Future<StreamInfo> resolve(String videoId, {bool forceFresh = false});

  /// Warms up stream resolution in the background.
  void prefetch(String videoId);

  /// Invalidates cached stream info for [videoId].
  void invalidate(String videoId);
}

/// Production implementation of [StreamResolver] chaining VISIONOS in-process
/// resolution with youtube_explode_dart fallback and dual-layer caching.
class StreamResolverImpl implements StreamResolver {
  StreamResolverImpl({
    Dio? dio,
    this.cacheStorage,
    VisionOsResolver? visionOsResolver,
    YoutubeExplodeResolver? explodeResolver,
    bool? isIosOverride,
  }) : dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 8),
               receiveTimeout: const Duration(seconds: 15),
             ),
           ),
       visionOsResolver = visionOsResolver ?? VisionOsResolver(),
       explodeResolver = explodeResolver ?? const YoutubeExplodeResolver(),
       isIos = isIosOverride ?? (Platform.isIOS || Platform.isMacOS);

  final Dio dio;
  final StreamCacheStorage? cacheStorage;
  final VisionOsResolver visionOsResolver;
  final YoutubeExplodeResolver explodeResolver;
  final bool isIos;

  static const int _maxMemoryCacheSize = 200;
  final LinkedHashMap<String, StreamInfo> _memoryCache =
      LinkedHashMap<String, StreamInfo>();

  final Map<String, Future<StreamInfo>> _inflight = {};

  @override
  Future<StreamInfo> resolve(String videoId, {bool forceFresh = false}) async {
    final cleanId = _cleanVideoId(videoId);

    if (!forceFresh) {
      // 1. Check in-memory cache
      final mem = _memoryCache[cleanId];
      if (mem != null && mem.expiresAt.isAfter(DateTime.now())) {
        return mem;
      }

      // 2. Check DB cache
      final storage = cacheStorage;
      if (storage != null) {
        try {
          final dbUrl = await storage.getStreamUrl(cleanId);
          if (dbUrl != null) {
            final uri = Uri.tryParse(dbUrl);
            if (uri != null) {
              final expireStr = uri.queryParameters['expire'];
              final expireSec = int.tryParse(expireStr ?? '');
              final expiresAt = expireSec != null
                  ? DateTime.fromMillisecondsSinceEpoch(expireSec * 1000)
                        .subtract(const Duration(minutes: 10))
                  : DateTime.now().add(const Duration(hours: 3));

              if (expiresAt.isAfter(DateTime.now())) {
                final info = StreamInfo(url: uri, expiresAt: expiresAt);
                _putMemory(cleanId, info);
                return info;
              }
            }
          }
        } on Exception {
          // Ignore cache check errors
        }
      }
    }

    // 3. In-flight deduplication
    final running = _inflight[cleanId];
    if (running != null) {
      return await running;
    }

    final job = _executeResolveChain(cleanId);
    _inflight[cleanId] = job;

    try {
      final info = await job;
      _putMemory(cleanId, info);

      if (cacheStorage != null) {
        unawaited(_saveDbCache(cleanId, info));
      }

      return info;
    } finally {
      unawaited(_inflight.remove(cleanId));
    }
  }

  Future<void> _saveDbCache(String cleanId, StreamInfo info) async {
    try {
      await cacheStorage?.putStreamUrl(
        cleanId,
        info.url.toString(),
        info.expiresAt,
      );
    } on Exception {
      // Ignore cache save errors
    }
  }

  Future<StreamInfo> _executeResolveChain(String cleanId) async {
    // Step 1: VisionOS in-process /player resolver
    final vInfo = await visionOsResolver.resolve(dio, cleanId, isIos: isIos);
    if (vInfo != null) {
      return vInfo;
    }

    // Step 2: YoutubeExplode fallback
    final eInfo = await explodeResolver.resolve(cleanId, isIos: isIos);
    if (eInfo != null) {
      return eInfo;
    }

    // Step 3: Stream unavailable
    throw StreamUnavailableException(cleanId);
  }

  @override
  void prefetch(String videoId) {
    final cleanId = _cleanVideoId(videoId);
    if (_memoryCache.containsKey(cleanId) || _inflight.containsKey(cleanId)) {
      return;
    }

    unawaited(_doPrefetch(cleanId));
  }

  Future<void> _doPrefetch(String cleanId) async {
    try {
      await resolve(cleanId);
    } on Exception {
      // Ignore prefetch failures
    }
  }

  @override
  void invalidate(String videoId) {
    final cleanId = _cleanVideoId(videoId);
    _memoryCache.remove(cleanId);
    unawaited(_inflight.remove(cleanId));
  }

  void _putMemory(String id, StreamInfo info) {
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      _memoryCache.remove(_memoryCache.keys.first);
    }
    _memoryCache[id] = info;
  }

  String _cleanVideoId(String id) {
    return id.startsWith('yt-') ? id.substring(3) : id;
  }
}
