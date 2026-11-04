import 'dart:async';

import 'package:awady_music/data/models/stream_info.dart';
import 'package:awady_music/data/sources/ytstream/client_constants.dart';
import 'package:dio/dio.dart';

void _log(String msg) {
  // Silent fallback for standalone CLI scripts without Flutter engine
}

/// Bootstrapped session credentials for the VISIONOS client context.
class VisionOsSession {
  const VisionOsSession({
    required this.sts,
    required this.visitorData,
    required this.at,
  });

  final int sts;
  final String visitorData;
  final DateTime at;

  bool get isExpired => DateTime.now().difference(at) > ytSessionTtl;
}

/// Resolves audio stream URLs directly from the `/player` endpoint using the
/// VISIONOS client context.
class VisionOsResolver {
  VisionOsResolver();

  VisionOsSession? _session;
  Future<VisionOsSession?>? _sessionInflight;

  /// Fetches fresh or cached session credentials (STS and visitorData).
  Future<VisionOsSession?> fetchSessionCreds(
    Dio dio, {
    bool force = false,
  }) async {
    if (_session != null && !force && !_session!.isExpired) {
      return _session;
    }
    if (!force && _sessionInflight != null) {
      return await _sessionInflight!;
    }

    final job = _fetchCredsInternal(dio);
    _sessionInflight = job;
    try {
      final res = await job;
      if (res != null) {
        _session = res;
      }
      return res;
    } finally {
      if (_sessionInflight == job) {
        _sessionInflight = null;
      }
    }
  }

  Future<VisionOsSession?> _fetchCredsInternal(Dio dio) async {
    try {
      final res = await dio.get<String>(
        'https://www.youtube.com/',
        options: Options(
          headers: {'User-Agent': visionOsUserAgent},
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );

      final html = res.data ?? '';
      final stsMatch = RegExp(r'"STS":(\d+)').firstMatch(html);
      final visitorMatch = RegExp('"VISITOR_DATA":"([^"]+)"').firstMatch(html);

      final sts = int.tryParse(stsMatch?.group(1) ?? '');
      final visitorData = visitorMatch?.group(1);

      if (sts == null || visitorData == null || visitorData.isEmpty) {
        _log('Failed to parse STS or VISITOR_DATA from youtube.com homepage');
        return null;
      }

      return VisionOsSession(
        sts: sts,
        visitorData: visitorData,
        at: DateTime.now(),
      );
    } on Exception catch (e) {
      _log('Failed to fetch YouTube homepage credentials: $e');
      return null;
    }
  }

  /// Resolves the best audio stream URL for [videoId].
  Future<StreamInfo?> resolve(
    Dio dio,
    String videoId, {
    bool isIos = false,
  }) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      final creds = await fetchSessionCreds(dio, force: attempt > 0);
      if (creds == null) return null;

      try {
        final res = await dio.post<Map<String, dynamic>>(
          'https://www.youtube.com/youtubei/v1/player',
          queryParameters: {'prettyPrint': 'false', 'key': innertubeKey},
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': visionOsUserAgent,
              'Origin': 'https://www.youtube.com',
              'X-Goog-Visitor-Id': creds.visitorData,
              'X-YouTube-Client-Name': '101',
              'X-YouTube-Client-Version':
                  visionOsContext['clientVersion'] as String,
            },
            receiveTimeout: const Duration(seconds: 9),
            sendTimeout: const Duration(seconds: 9),
          ),
          data: {
            'videoId': videoId,
            'context': {
              'client': {...visionOsContext, 'visitorData': creds.visitorData},
            },
            'playbackContext': {
              'contentPlaybackContext': {
                'html5Preference': 'HTML5_PREF_WANTS',
                'signatureTimestamp': creds.sts,
              },
            },
            'contentCheckOk': true,
            'racyCheckOk': true,
          },
        );

        final data = res.data ?? const <String, dynamic>{};
        final playability =
            data['playabilityStatus'] as Map<String, dynamic>? ??
            const <String, dynamic>{};
        final status = playability['status'] as String? ?? '';

        if (status != 'OK') {
          if (status == 'LOGIN_REQUIRED' && attempt == 0) {
            continue;
          }
          _log('VisionOS playability status not OK: $status for $videoId');
          return null;
        }

        final streamingData =
            data['streamingData'] as Map<String, dynamic>? ??
            const <String, dynamic>{};
        final formats =
            (streamingData['adaptiveFormats'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .toList() ??
            const <Map<String, dynamic>>[];

        final audioFormats = formats.where((f) {
          final mime = f['mimeType'] as String? ?? '';
          final url = f['url'] as String? ?? '';
          return mime.startsWith('audio/') && url.isNotEmpty;
        }).toList();

        if (audioFormats.isEmpty) return null;

        // Sort audio formats
        audioFormats.sort((a, b) {
          final mimeA = a['mimeType'] as String? ?? '';
          final mimeB = b['mimeType'] as String? ?? '';
          final isMp4A = mimeA.contains('mp4') || mimeA.contains('m4a');
          final isMp4B = mimeB.contains('mp4') || mimeB.contains('m4a');

          if (isIos && isMp4A != isMp4B) {
            return isMp4A ? -1 : 1;
          }

          final bitrateA = (a['averageBitrate'] ?? a['bitrate'] ?? 0) as int;
          final bitrateB = (b['averageBitrate'] ?? b['bitrate'] ?? 0) as int;
          return bitrateB.compareTo(bitrateA);
        });

        final selected = audioFormats.first;
        final rawUrl = selected['url'] as String? ?? '';
        final uri = Uri.tryParse(rawUrl);
        if (uri == null) return null;

        final host = uri.host;
        if (host != 'googlevideo.com' && !host.endsWith('.googlevideo.com')) {
          _log('Untrusted stream hostname: $host');
          return null;
        }

        // 1-byte range probe
        try {
          final probe = await dio.get<dynamic>(
            rawUrl,
            options: Options(
              headers: {'Range': 'bytes=0-0'},
              receiveTimeout: const Duration(seconds: 5),
              sendTimeout: const Duration(seconds: 5),
              validateStatus: (s) => s != null && (s == 200 || s == 206),
            ),
          );
          if (probe.statusCode != 200 && probe.statusCode != 206) {
            _log('1-byte range probe rejected with ${probe.statusCode}');
            return null;
          }
        } on Exception catch (e) {
          _log('1-byte range probe network error: $e');
          return null;
        }

        final expireStr = uri.queryParameters['expire'];
        final expireSec = int.tryParse(expireStr ?? '');
        final expiresAt = expireSec != null
            ? DateTime.fromMillisecondsSinceEpoch(expireSec * 1000)
                  .subtract(const Duration(minutes: 10))
            : DateTime.now().add(const Duration(hours: 5));

        final mimeType = selected['mimeType'] as String?;
        final bitrate =
            (selected['averageBitrate'] ?? selected['bitrate']) as int?;
        final playerConfig = data['playerConfig'] as Map<String, dynamic>?;
        final audioConfig =
            playerConfig?['audioConfig'] as Map<String, dynamic>?;
        final loudnessDb = (audioConfig?['loudnessDb'] as num?)?.toDouble();

        return StreamInfo(
          url: uri,
          expiresAt: expiresAt,
          mimeType: mimeType,
          bitrate: bitrate,
          loudnessDb: loudnessDb,
        );
      } on Exception catch (e) {
        _log('VisionOS resolve error for $videoId (attempt $attempt): $e');
        if (attempt == 0) continue;
      }
    }

    return null;
  }
}
