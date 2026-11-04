import 'dart:async';

import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/core/util/semaphore.dart';
import 'package:awady_music/data/sources/http.dart';
import 'package:dio/dio.dart';

/// Represents a bootstrapped session context for Innertube.
class InnertubeSession {
  const InnertubeSession({
    required this.apiKey,
    required this.clientVersion,
    this.visitorData,
  });

  final String apiKey;
  final String clientVersion;
  final String? visitorData;
}

/// Defensive nested JSON reader helper that never throws.
dynamic dig(dynamic source, List<dynamic> path) {
  dynamic current = source;
  for (final segment in path) {
    if (current == null) return null;
    if (segment is String && current is Map) {
      current = current[segment];
    } else if (segment is int && current is List) {
      if (segment >= 0 && segment < current.length) {
        current = current[segment];
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
  return current;
}

/// Type-safe defensive JSON reader helper.
T? digAs<T>(dynamic source, List<dynamic> path) {
  final val = dig(source, path);
  return val is T ? val : null;
}

/// Client for interacting with the raw YouTube Music Innertube API.
class InnertubeClient {
  InnertubeClient({Dio? dio, Semaphore? limiter})
    : _dio = dio ?? createDio(),
      _limiter = limiter ?? Semaphore(4);

  final Dio _dio;
  final Semaphore _limiter;

  /// Current session credentials. Can be set directly for testing.
  InnertubeSession? session;
  Future<InnertubeSession>? _bootstrapFuture;

  static const String defaultApiKey = 'AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8';
  static const String defaultClientVersion = '1.20241028.01.00';
  static const String userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36';

  /// Bootstraps session tokens from music.youtube.com homepage ytcfg.
  Future<InnertubeSession> bootstrapSession({bool force = false}) {
    if (!force && session != null) {
      return Future.value(session!);
    }
    if (_bootstrapFuture != null) {
      return _bootstrapFuture!;
    }

    _bootstrapFuture = _performBootstrap();
    return _bootstrapFuture!;
  }

  Future<InnertubeSession> _performBootstrap() async {
    try {
      final response = await _limiter.run(
        () => _dio.get<String>(
          'https://music.youtube.com/',
          options: Options(
            headers: const {
              'User-Agent': userAgent,
              'Accept-Language': 'en-US,en;q=0.9',
            },
          ),
        ),
      );

      final html = response.data ?? '';
      final keyMatch = RegExp(r'"INNERTUBE_API_KEY"\s*:\s*"([^"]+)"')
          .firstMatch(html);
      final verMatch = RegExp(r'"INNERTUBE_CLIENT_VERSION"\s*:\s*"([^"]+)"')
          .firstMatch(html);
      final visMatch = RegExp(r'"VISITOR_DATA"\s*:\s*"([^"]+)"')
          .firstMatch(html);

      final resolvedSession = InnertubeSession(
        apiKey: keyMatch?.group(1) ?? defaultApiKey,
        clientVersion: verMatch?.group(1) ?? defaultClientVersion,
        visitorData: visMatch?.group(1),
      );
      session = resolvedSession;
      return resolvedSession;
    } on Object catch (e) {
      Log.w('Failed to bootstrap Innertube session, using defaults: $e');
      const fallback = InnertubeSession(
        apiKey: defaultApiKey,
        clientVersion: defaultClientVersion,
      );
      session = fallback;
      return fallback;
    } finally {
      _bootstrapFuture = null;
    }
  }

  /// Sends a POST request to an Innertube endpoint with
  /// WEB_REMIX client context.
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final session = await bootstrapSession();

    final payload = {
      'context': {
        'client': {
          'clientName': 'WEB_REMIX',
          'clientVersion': session.clientVersion,
          if (session.visitorData != null) 'visitorData': session.visitorData,
          'hl': 'en',
          'gl': 'US',
        },
      },
      ...body,
    };

    final url =
        'https://music.youtube.com/youtubei/v1/$endpoint?prettyPrint=false&key=${session.apiKey}';

    final response = await _limiter.run(
      () => _dio.post<Map<String, dynamic>>(
        url,
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': userAgent,
            'X-YouTube-Client-Name': '67',
            'X-YouTube-Client-Version': session.clientVersion,
            'X-Origin': 'https://music.youtube.com',
          },
        ),
      ),
    );

    return response.data ?? <String, dynamic>{};
  }
}
