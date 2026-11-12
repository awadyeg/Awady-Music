import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:awady_music/data/sources/youtube/yt_account_importer.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockHttpClientRequest implements HttpClientRequest {
  _MockHttpClientRequest(this.response);

  final HttpClientResponse response;
  final List<int> bodyBytes = [];

  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  void add(List<int> data) {
    bodyBytes.addAll(data);
  }

  @override
  Future<HttpClientResponse> close() async => response;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  _MockHttpClientResponse(this.statusCode, this.body);

  @override
  final int statusCode;
  final String body;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream.value(utf8.encode(body)).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpHeaders implements HttpHeaders {
  final Map<String, String> values = {};

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    values[name.toLowerCase()] = value.toString();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClient implements HttpClient {
  _MockHttpClient({required this.statusCode});

  final int statusCode;

  @override
  Duration? connectionTimeout;

  @override
  Future<HttpClientRequest> postUrl(Uri url) async {
    final response = _MockHttpClientResponse(statusCode, '{}');
    return _MockHttpClientRequest(response);
  }

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('SHA-1 and SAPISID tests', () {
    test('sha1Hex computes standard vectors correctly', () {
      expect(sha1Hex(''), 'da39a3ee5e6b4b0d3255bfef95601890afd80709');
      expect(
        sha1Hex('The quick brown fox jumps over the lazy dog'),
        '2fd4e1c67a2d28fced849ee1bb76e7391b93eb12',
      );
    });

    test('extractSapisid finds standard SAPISID and __Secure-3PAPISID', () {
      expect(
        YtMusicAccountImporter.extractSapisid('foo=1; SAPISID=token123; bar=2'),
        'token123',
      );
      expect(
        YtMusicAccountImporter.extractSapisid(
          'foo=1; __Secure-3PAPISID=secToken456; bar=2',
        ),
        'secToken456',
      );
      expect(YtMusicAccountImporter.extractSapisid('foo=1; bar=2'), isNull);
    });

    test('buildSapisidHash generates expected SAPISIDHASH prefix and sha1', () {
      final hash = YtMusicAccountImporter.buildSapisidHash(
        'mytoken',
        timestamp: 1700000000,
      );
      expect(hash.startsWith('SAPISIDHASH 1700000000_'), isTrue);
      final expectedSha = sha1Hex(
        '1700000000 mytoken https://music.youtube.com',
      );
      expect(hash, 'SAPISIDHASH 1700000000_$expectedSha');
    });

    test(
      'buildInnertubeHeaders includes authorization when SAPISID present',
      () {
        final headers = YtMusicAccountImporter.buildInnertubeHeaders(
          'SAPISID=auth123; HSID=foo',
        );
        expect(headers['Cookie'], contains('SAPISID=auth123'));
        expect(headers['Authorization'], startsWith('SAPISIDHASH '));
        expect(headers['X-YouTube-Client-Name'], '67');
      },
    );
  });

  group('YtMusicAccountImporter syncLikeToAccount tests', () {
    test('syncLikeToAccount returns true on status 200', () async {
      final mock = _MockHttpClient(statusCode: 200);
      final ok = await YtMusicAccountImporter.syncLikeToAccount(
        'video123',
        like: true,
        cookie: 'SAPISID=token;',
        httpClient: mock,
      );
      expect(ok, isTrue);
    });

    test('syncLikeToAccount returns false on non-200', () async {
      final mock = _MockHttpClient(statusCode: 403);
      final ok = await YtMusicAccountImporter.syncLikeToAccount(
        'video123',
        like: false,
        cookie: 'SAPISID=token;',
        httpClient: mock,
      );
      expect(ok, isFalse);
    });
  });
}
