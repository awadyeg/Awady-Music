import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:awady_music/core/util/semaphore.dart';
import 'package:awady_music/data/sources/http.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class MockHttpAdapter implements HttpClientAdapter {
  MockHttpAdapter({this.onFetch});

  final Future<ResponseBody> Function(RequestOptions options)? onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    if (onFetch != null) {
      return onFetch!(options);
    }
    return Future.value(ResponseBody.fromString('{}', 200));
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('dig and digAs helpers', () {
    test('safely navigates nested maps and lists', () {
      final data = {
        'contents': {
          'items': [
            {'title': 'Song 1', 'id': 'yt-1'},
            {'title': 'Song 2', 'id': 'yt-2'},
          ],
        },
      };

      expect(dig(data, ['contents', 'items', 0, 'title']), 'Song 1');
      expect(dig(data, ['contents', 'items', 1, 'id']), 'yt-2');
      expect(digAs<String>(data, ['contents', 'items', 0, 'title']), 'Song 1');
      expect(digAs<int>(data, ['contents', 'items', 0, 'title']), isNull);
    });

    test('returns null gracefully on missing paths or mismatched types', () {
      final data = {
        'contents': {'items': <dynamic>[]},
      };

      expect(dig(data, ['contents', 'items', 0, 'title']), isNull);
      expect(dig(data, ['nonexistent', 'key']), isNull);
      expect(dig(null, ['any']), isNull);
      expect(dig(data, ['contents', 5]), isNull);
    });
  });

  group('InnertubeClient bootstrap & post', () {
    test('bootstrap parses HTML ytcfg tokens', () async {
      final mockAdapter = MockHttpAdapter(
        onFetch: (options) {
          if (options.uri.host == 'music.youtube.com') {
            const html = '''
              <script>
                ytcfg.set({
                  "INNERTUBE_API_KEY": "CUSTOM_KEY_123",
                  "INNERTUBE_CLIENT_VERSION": "1.9999.00.00",
                  "VISITOR_DATA": "VISITOR_TOKEN_ABC"
                });
              </script>
            ''';
            return Future.value(ResponseBody.fromString(html, 200));
          }
          return Future.value(ResponseBody.fromString('{}', 200));
        },
      );

      final dio = createDio()..httpClientAdapter = mockAdapter;
      final client = InnertubeClient(dio: dio);

      final session = await client.bootstrapSession();
      expect(session.apiKey, 'CUSTOM_KEY_123');
      expect(session.clientVersion, '1.9999.00.00');
      expect(session.visitorData, 'VISITOR_TOKEN_ABC');
    });

    test('bootstrap falls back gracefully on error', () async {
      final mockAdapter = MockHttpAdapter(
        onFetch: (options) => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        ),
      );

      final dio = createDio()..httpClientAdapter = mockAdapter;
      final client = InnertubeClient(dio: dio);

      final session = await client.bootstrapSession();
      expect(session.apiKey, InnertubeClient.defaultApiKey);
      expect(session.clientVersion, InnertubeClient.defaultClientVersion);
    });

    test('post attaches WEB_REMIX context and limiter', () async {
      RequestOptions? capturedOptions;
      Map<String, dynamic>? capturedBody;

      final mockAdapter = MockHttpAdapter(
        onFetch: (options) async {
          capturedOptions = options;
          if (options.data is Map<String, dynamic>) {
            capturedBody = options.data as Map<String, dynamic>;
          }
          return ResponseBody.fromString(
            jsonEncode({'results': 'ok'}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        },
      );

      final dio = createDio()..httpClientAdapter = mockAdapter;
      final client = InnertubeClient(dio: dio, limiter: Semaphore(4))
        ..session = const InnertubeSession(
          apiKey: 'TEST_KEY',
          clientVersion: '1.2.3',
          visitorData: 'VISITOR_XYZ',
        );

      final res = await client.post('search', {'query': 'test'});
      expect(res['results'], 'ok');
      expect(capturedOptions?.uri.toString(), contains('key=TEST_KEY'));
      expect(capturedOptions?.headers['X-YouTube-Client-Name'], '67');
      expect(capturedOptions?.headers['X-YouTube-Client-Version'], '1.2.3');

      final contextClient = dig(capturedBody, ['context', 'client']) as Map?;
      expect(contextClient?['clientName'], 'WEB_REMIX');
      expect(contextClient?['clientVersion'], '1.2.3');
      expect(contextClient?['visitorData'], 'VISITOR_XYZ');
      expect(capturedBody?['query'], 'test');
    });
  });

  group('Innertube recorded fixtures validation', () {
    test('all recorded fixtures exist and contain valid JSON structure', () {
      final fixtureNames = [
        'search_adele.json',
        'suggestions.json',
        'artist_adele.json',
        'album.json',
        'playlist.json',
        'home.json',
        'explore.json',
        'charts.json',
        'new_releases.json',
        'moods.json',
        'mood_page.json',
        'next.json',
      ];

      for (final name in fixtureNames) {
        final file = File('test/fixtures/innertube/$name');
        expect(file.existsSync(), isTrue, reason: 'Missing fixture: $name');

        final content = file.readAsStringSync();
        final json = jsonDecode(content);
        expect(
          json,
          isA<Map<String, dynamic>>(),
          reason: '$name should be a Map',
        );
      }
    });

    test('search_adele fixture has expected contents and tabs', () {
      final file = File('test/fixtures/innertube/search_adele.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

      final contents = dig(json, ['contents']);
      expect(contents, isNotNull);
    });
  });
}
