import 'dart:async';

import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/data/db/app_database.dart';
import 'package:awady_music/data/models/lyrics.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/sources/lyrics/lrclib_client.dart';
import 'package:awady_music/data/sources/lyrics/musixmatch_client.dart';
import 'package:awady_music/data/sources/lyrics/ytm_lyrics_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for LyricsRepository
final lyricsRepositoryProvider = Provider<LyricsRepository>((ref) {
  final ytm = ref.watch(ytmLyricsClientProvider);
  final mxm = ref.watch(musixmatchClientProvider);
  final lrclib = ref.watch(lrclibClientProvider);
  final db = ref.watch(appDatabaseProvider);
  return LyricsRepository(
    ytmLyricsClient: ytm,
    musixmatchClient: mxm,
    lrclibClient: lrclib,
    cacheDao: db.cacheDao,
  );
});

/// Convenience provider for loading lyrics for a specific Track
final lyricsForTrackProvider = FutureProvider.family<Lyrics, Track>((
  ref,
  track,
) {
  final repo = ref.watch(lyricsRepositoryProvider);
  return repo.get(track);
});

/// Repository coordinating lyrics resolution across multiple providers with
/// deterministic fallback and per-sheet offset persistence in SQLite.
///
/// Order:
/// 1. YTM timed lyrics
/// 2. Musixmatch human-curated timed lyrics
/// 3. LRCLIB synced lyrics with auto lead-in offset
/// 4. Any plain lyrics fallback (YTM / LRCLIB plain)
/// 5. NoLyrics
class LyricsRepository {
  LyricsRepository({
    required this.ytmLyricsClient,
    required this.musixmatchClient,
    required this.lrclibClient,
    required this.cacheDao,
  });

  final YtmLyricsClient ytmLyricsClient;
  final MusixmatchClient musixmatchClient;
  final LrclibClient lrclibClient;
  final CacheDao cacheDao;

  final Map<String, Lyrics> _memoryCache = {};

  /// Constructs unique database key per track and sheet fingerprint
  static String offsetKey(String trackId, String fingerprint) {
    if (fingerprint.isNotEmpty) {
      return '$trackId:$fingerprint';
    }
    return trackId;
  }

  /// Resolves lyrics following the deterministic priority fallback chain.
  Future<Lyrics> get(Track track, {bool forceFresh = false}) async {
    if (!forceFresh && _memoryCache.containsKey(track.id)) {
      return _memoryCache[track.id]!;
    }

    PlainLyrics? fallbackPlain;

    // 1. YouTube Music timed lyrics
    try {
      final ytmRes = await ytmLyricsClient.timed(track.id);
      if (ytmRes is SyncedLyrics) {
        final withOffset = await _resolveOffset(track.id, ytmRes);
        _memoryCache[track.id] = withOffset;
        return withOffset;
      } else if (ytmRes is PlainLyrics) {
        fallbackPlain ??= ytmRes;
      }
    } on Object catch (e) {
      Log.w('YTM lyrics failed for ${track.id}: $e');
    }

    // 2. Musixmatch timed lyrics
    try {
      final mxmRes = await musixmatchClient.getLyrics(
        track.title,
        track.artist.name,
        expectedDurationSec: track.duration,
      );
      if (mxmRes is SyncedLyrics) {
        final withOffset = await _resolveOffset(track.id, mxmRes);
        _memoryCache[track.id] = withOffset;
        return withOffset;
      }
    } on Object catch (e) {
      Log.w('Musixmatch lyrics failed for ${track.id}: $e');
    }

    // 3. LRCLIB synced lyrics
    try {
      final lrcRes = await lrclibClient.getLyrics(
        track.title,
        track.artist.name,
        durationSec: track.duration,
      );
      if (lrcRes is SyncedLyrics) {
        final withOffset = await _resolveOffset(track.id, lrcRes);
        _memoryCache[track.id] = withOffset;
        return withOffset;
      } else if (lrcRes is PlainLyrics) {
        fallbackPlain ??= lrcRes;
      }
    } on Object catch (e) {
      Log.w('LRCLIB lyrics failed for ${track.id}: $e');
    }

    // 4. Any plain lyrics fallback
    if (fallbackPlain != null) {
      _memoryCache[track.id] = fallbackPlain;
      return fallbackPlain;
    }

    const noLyrics = NoLyrics();
    _memoryCache[track.id] = noLyrics;
    return noLyrics;
  }

  Future<SyncedLyrics> _resolveOffset(
    String trackId,
    SyncedLyrics lyrics,
  ) async {
    final key = offsetKey(trackId, lyrics.fingerprint);
    var row = await cacheDao.getLyricOffset(key);
    if (row == null && key != trackId) {
      row = await cacheDao.getLyricOffset(trackId);
    }

    int effectiveOffsetMs;
    if (row != null) {
      effectiveOffsetMs = row.ms;
    } else if (lyrics.autoOffsetMs != 0) {
      effectiveOffsetMs = lyrics.autoOffsetMs;
      await cacheDao.putLyricOffset(key, effectiveOffsetMs);
    } else {
      effectiveOffsetMs = 0;
    }

    return SyncedLyrics(
      lines: lyrics.lines,
      source: lyrics.source,
      fingerprint: lyrics.fingerprint,
      autoOffsetMs: effectiveOffsetMs,
    );
  }

  /// Manually pins an offset for a specific track and sheet fingerprint.
  Future<void> pinOffset({
    required String trackId,
    required String fingerprint,
    required int offsetMs,
  }) async {
    final key = offsetKey(trackId, fingerprint);
    await cacheDao.putLyricOffset(key, offsetMs, manual: true);

    final cached = _memoryCache[trackId];
    if (cached is SyncedLyrics) {
      _memoryCache[trackId] = SyncedLyrics(
        lines: cached.lines,
        source: cached.source,
        fingerprint: cached.fingerprint,
        autoOffsetMs: offsetMs,
      );
    }
  }

  /// Retrieves the persisted manual or auto offset for a track and fingerprint.
  Future<int?> getOffset({
    required String trackId,
    required String fingerprint,
  }) async {
    final key = offsetKey(trackId, fingerprint);
    final row =
        await cacheDao.getLyricOffset(key) ??
        await cacheDao.getLyricOffset(trackId);
    return row?.ms;
  }
}
