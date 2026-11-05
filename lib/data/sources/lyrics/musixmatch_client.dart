import 'dart:async';

import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/data/models/lyrics.dart';
import 'package:awady_music/data/sources/http.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:awady_music/data/sources/lyrics/lrc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for MusixmatchClient
final musixmatchClientProvider = Provider<MusixmatchClient>((ref) {
  return MusixmatchClient();
});

/// Candidate track with timed LRC subtitles from Musixmatch
class MusixmatchCandidate {
  const MusixmatchCandidate({
    required this.trackId,
    required this.trackName,
    required this.artistName,
    required this.durationSec,
    required this.lrc,
  });

  final int trackId;
  final String trackName;
  final String artistName;
  final int durationSec;
  final String lrc;
}

/// Client for Musixmatch anonymous API.
/// Retrieves guest tokens (cached in SharedPreferences), searches tracks,
/// and fetches human-curated timed LRC subtitles with an 8-second timeout.
class MusixmatchClient {
  MusixmatchClient({Dio? dio, this.prefs}) : _dio = dio ?? createDio();

  final Dio _dio;
  SharedPreferences? prefs;
  String? _cachedToken;

  static const String baseUrl = 'https://apic.musixmatch.com/ws/1.1';
  static const String userAgent = 'Dalvik/2.1.0 (Linux; U; Android 9; Pixel 3)';
  static const Duration requestTimeout = Duration(seconds: 8);
  static const String tokenPrefsKey = 'mxm_user_token';
  static const String appId = 'android-player-v1.0';

  /// Obtains or refreshes the anonymous guest token.
  Future<String?> getToken({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      if (_cachedToken != null && _cachedToken!.isNotEmpty) {
        return _cachedToken;
      }
      final saved = prefs?.getString(tokenPrefsKey);
      if (saved != null && saved.isNotEmpty) {
        _cachedToken = saved;
        return saved;
      }
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$baseUrl/token.get',
        queryParameters: {'app_id': appId, 'user_language': 'en'},
        options: Options(
          headers: {'User-Agent': userAgent},
          sendTimeout: requestTimeout,
          receiveTimeout: requestTimeout,
        ),
      );

      final data = response.data;
      final token = dig(data, ['message', 'body', 'user_token'])?.toString();
      if (token != null && token.isNotEmpty) {
        _cachedToken = token;
        unawaited(prefs?.setString(tokenPrefsKey, token));
        return token;
      }
    } on Object catch (e) {
      Log.w('Musixmatch token.get failed: $e');
    }
    return null;
  }

  /// Searches Musixmatch for subtitle candidates matching track title
  /// and artist.
  Future<List<MusixmatchCandidate>> searchLyrics(
    String title,
    String artist,
  ) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final token = await getToken(forceRefresh: attempt > 0);
        if (token == null || token.isEmpty) return const [];

        final searchRes = await _dio.get<Map<String, dynamic>>(
          '$baseUrl/track.search',
          queryParameters: {
            'q_track': title,
            'q_artist': artist,
            'app_id': appId,
            'usertoken': token,
            'page_size': 4,
            's_track_rating': 'desc',
          },
          options: Options(
            headers: {'User-Agent': userAgent},
            sendTimeout: requestTimeout,
            receiveTimeout: requestTimeout,
          ),
        );

        final searchData = searchRes.data;
        final statusCode = dig(searchData, [
          'message',
          'header',
          'status_code',
        ]);

        // Token expired or invalid
        if (statusCode == 401 || statusCode == 419) {
          _cachedToken = null;
          unawaited(prefs?.remove(tokenPrefsKey));
          continue; // retry once with fresh token
        }

        final trackList = dig(searchData, ['message', 'body', 'track_list']);
        if (trackList is! List || trackList.isEmpty) {
          return const [];
        }

        final candidates = <MusixmatchCandidate>[];
        final topTracks = trackList.take(3);

        for (final item in topTracks) {
          final tr = dig(item, ['track']);
          if (tr is! Map) continue;

          final trackId = tr['track_id'];
          final hasSubtitles = tr['has_subtitles'];
          final isSubtitled = hasSubtitles == 1 || hasSubtitles == true;

          if (trackId == null || !isSubtitled) continue;

          try {
            final subRes = await _dio.get<Map<String, dynamic>>(
              '$baseUrl/track.subtitle.get',
              queryParameters: {
                'track_id': trackId.toString(),
                'subtitle_format': 'lrc',
                'app_id': appId,
                'usertoken': token,
              },
              options: Options(
                headers: {'User-Agent': userAgent},
                sendTimeout: requestTimeout,
                receiveTimeout: requestTimeout,
              ),
            );

            final subData = subRes.data;
            final lrcBody = dig(subData, [
              'message',
              'body',
              'subtitle',
              'subtitle_body',
            ])?.toString();

            if (lrcBody != null &&
                RegExp(r'\[\d{1,2}:\d{2}').hasMatch(lrcBody)) {
              final trackName = tr['track_name']?.toString() ?? '';
              final artistName = tr['artist_name']?.toString() ?? '';
              final lenRaw = tr['track_length'];
              final durationSec = (lenRaw is num)
                  ? lenRaw.round()
                  : int.tryParse(lenRaw?.toString() ?? '0') ?? 0;

              candidates.add(
                MusixmatchCandidate(
                  trackId: (trackId is int)
                      ? trackId
                      : int.tryParse(trackId.toString()) ?? 0,
                  trackName: trackName,
                  artistName: artistName,
                  durationSec: durationSec,
                  lrc: lrcBody,
                ),
              );
            }
          } on Object catch (e) {
            Log.w('Musixmatch track.subtitle.get failed for $trackId: $e');
          }
        }

        return candidates;
      } on Object catch (e) {
        Log.w('Musixmatch search failed for "$title - $artist": $e');
        if (attempt == 1) return const [];
      }
    }
    return const [];
  }

  /// Resolves synced lyrics for a track, selecting the closest duration
  /// candidate.
  Future<SyncedLyrics?> getLyrics(
    String title,
    String artist, {
    int? expectedDurationSec,
  }) async {
    final candidates = await searchLyrics(title, artist);
    if (candidates.isEmpty) return null;

    final sortedCandidates = List<MusixmatchCandidate>.from(candidates);
    if (expectedDurationSec != null && expectedDurationSec > 0) {
      sortedCandidates.sort((a, b) {
        final diffA = (a.durationSec - expectedDurationSec).abs();
        final diffB = (b.durationSec - expectedDurationSec).abs();
        return diffA.compareTo(diffB);
      });
    }

    final best = sortedCandidates.first;
    final lines = parseLrc(best.lrc);
    if (lines.isEmpty) return null;

    return SyncedLyrics(
      lines: lines,
      source: 'musixmatch',
      fingerprint: sheetFingerprint(lines),
    );
  }
}
