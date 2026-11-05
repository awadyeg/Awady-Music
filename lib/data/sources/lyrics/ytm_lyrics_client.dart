import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/data/models/lyrics.dart';
import 'package:awady_music/data/sources/http.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:awady_music/data/sources/lyrics/lrc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for YtmLyricsClient
final ytmLyricsClientProvider = Provider<YtmLyricsClient>((ref) {
  final innertube = ref.watch(innertubeClientProvider);
  return YtmLyricsClient(innertube: innertube);
});

/// Client for fetching line-timed lyrics directly from YouTube Music / LyricFind.
/// Uses a 2-hop sequence:
/// 1. `/next` resolves the lyrics tab browseId (`MPLYt...`).
/// 2. `/browse` with `ANDROID_MUSIC` mobile client context retrieves
///    `timedLyricsData`.
class YtmLyricsClient {
  YtmLyricsClient({InnertubeClient? innertube, Dio? dio})
    : innertube = innertube ?? InnertubeClient(),
      _dio = dio ?? createDio();

  final InnertubeClient innertube;
  final Dio _dio;

  static const String browseUrl =
      'https://music.youtube.com/youtubei/v1/browse?prettyPrint=false';

  /// Resolves line-timed lyrics for a given YouTube video ID.
  /// Returns [SyncedLyrics] if timed data is available, [PlainLyrics] if only
  /// untimed text is present, or null if no lyrics are available.
  Future<Lyrics?> timed(String videoId) async {
    try {
      // Hop 1: Call /next to resolve the lyrics tab's browseId
      final nextData = await innertube.post('/next', {'videoId': videoId});
      final browseId = resolveBrowseId(nextData);
      if (browseId == null || browseId.isEmpty) {
        return null;
      }

      // Hop 2: Call /browse with ANDROID_MUSIC context
      final response = await _dio.post<Map<String, dynamic>>(
        browseUrl,
        options: Options(
          headers: const {
            'Content-Type': 'application/json',
            'X-YouTube-Client-Name': '6',
            'X-YouTube-Client-Version': '7.21.50',
            'User-Agent':
                'com.google.android.apps.youtube.music/7.21.50 '
                '(Linux; U; Android 14) gzip',
            'Accept-Language': 'en-US,en',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 12),
        ),
        data: {
          'context': {
            'client': {
              'clientName': 'ANDROID_MUSIC',
              'clientVersion': '7.21.50',
              'androidSdkVersion': 34,
              'hl': 'en',
              'gl': 'US',
            },
          },
          'browseId': browseId,
        },
      );

      final data = response.data;
      if (data == null) return null;

      return parseBrowseLyrics(data);
    } on Object catch (e) {
      Log.w('Failed to fetch YTM lyrics for $videoId: $e');
      return null;
    }
  }

  /// Extracts the lyrics tab browseId from a `/next` response payload.
  String? resolveBrowseId(Map<String, dynamic> nextData) {
    final tabs = _findKey(nextData, 'tabRenderer');
    for (final tab in tabs) {
      if (tab is! Map) continue;
      if (tab['unselectable'] == true) continue;

      final pageType = dig(tab, [
        'endpoint',
        'browseEndpoint',
        'browseEndpointContextSupportedConfigs',
        'browseEndpointContextMusicConfig',
        'pageType',
      ]);

      if (pageType == 'MUSIC_PAGE_TYPE_TRACK_LYRICS') {
        final browseId = dig(tab, ['endpoint', 'browseEndpoint', 'browseId']);
        if (browseId is String && browseId.isNotEmpty) {
          return browseId;
        }
      }
    }
    return null;
  }

  /// Parses a `/browse` response into either [SyncedLyrics] or [PlainLyrics].
  Lyrics? parseBrowseLyrics(Map<String, dynamic> browseData) {
    // 1. Try to extract timed lyrics directly from timedLyricsData
    final timedDataLists = _findKey(browseData, 'timedLyricsData');
    for (final item in timedDataLists) {
      if (item is List && item.isNotEmpty) {
        final lines = <LyricLine>[];
        for (final row in item) {
          if (row is! Map) continue;
          final lyricText = row['lyricLine']?.toString().trim();
          final startMsRaw = dig(row, ['cueRange', 'startTimeMilliseconds']);

          if (lyricText != null && lyricText.isNotEmpty && startMsRaw != null) {
            final startMs = (startMsRaw is num)
                ? startMsRaw.toInt()
                : int.tryParse(startMsRaw.toString()) ?? 0;
            lines.add(LyricLine(startMs: startMs, text: lyricText));
          }
        }

        if (lines.isNotEmpty) {
          lines.sort((a, b) => a.startMs.compareTo(b.startMs));
          return SyncedLyrics(
            lines: lines,
            source: 'ytm',
            fingerprint: sheetFingerprint(lines),
          );
        }
      }
    }

    // 2. Fallback: plain lyrics from description shelf
    final descriptionShelves = _findKey(
      browseData,
      'musicDescriptionShelfRenderer',
    );
    for (final shelf in descriptionShelves) {
      if (shelf is! Map) continue;
      final runs = dig(shelf, ['description', 'runs']);
      if (runs is List && runs.isNotEmpty) {
        final textBuffer = StringBuffer();
        for (final run in runs) {
          if (run is Map && run['text'] != null) {
            textBuffer.write(run['text']);
          }
        }
        final text = textBuffer.toString().trim();
        if (text.isNotEmpty) {
          return PlainLyrics(text: text);
        }
      }
    }

    return null;
  }

  /// Helper recursively traversing JSON structure to find all values
  /// for a given key.
  List<dynamic> _findKey(dynamic obj, String targetKey, [List<dynamic>? out]) {
    final result = out ?? <dynamic>[];
    if (obj == null || result.length > 100) return result;

    if (obj is Map) {
      if (obj.containsKey(targetKey)) {
        result.add(obj[targetKey]);
      }
      for (final value in obj.values) {
        if (value is Map || value is List) {
          _findKey(value, targetKey, result);
        }
      }
    } else if (obj is List) {
      for (final item in obj) {
        if (item is Map || item is List) {
          _findKey(item, targetKey, result);
        }
      }
    }

    return result;
  }
}
