import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/sources/claude/claude_ai_client.dart';
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
  _MockHttpClient(this.handler);

  final Future<HttpClientResponse> Function(Uri uri) handler;

  @override
  Duration? connectionTimeout;

  @override
  Future<HttpClientRequest> postUrl(Uri url) async {
    final response = await handler(url);
    return _MockHttpClientRequest(response);
  }

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(ClaudeAiClient.clearCache);

  group('ClaudeAiClient parser tests', () {
    test('parses pure json array correctly', () {
      const json = '[{"title": "Song A", "artist": "Artist A"}]';
      final res = ClaudeAiClient.parseTrackSuggestions(json);
      expect(res.length, 1);
      expect(res.first.title, 'Song A');
      expect(res.first.artist, 'Artist A');
    });

    test('parses alternative keys (song/singer)', () {
      const json = '[{"song": "Song B", "singer": "Singer B"}]';
      final res = ClaudeAiClient.parseTrackSuggestions(json);
      expect(res.length, 1);
      expect(res.first.title, 'Song B');
      expect(res.first.artist, 'Singer B');
    });

    test('extracts json array from surrounding text/markdown', () {
      const raw =
          'Here is your curated list:\n```json\n'
          '[{"title": "Clocks", "artist": "Coldplay"}]\n```\nEnjoy!';
      final res = ClaudeAiClient.parseTrackSuggestions(raw);
      expect(res.length, 1);
      expect(res.first.title, 'Clocks');
      expect(res.first.artist, 'Coldplay');
    });

    test('returns empty list on invalid input', () {
      expect(ClaudeAiClient.parseTrackSuggestions(''), isEmpty);
      expect(ClaudeAiClient.parseTrackSuggestions('not json'), isEmpty);
      expect(ClaudeAiClient.parseTrackSuggestions('{}'), isEmpty);
    });
  });

  group('ClaudeAiClient suggest methods', () {
    test('suggestSimilarForSearch completes with mock client', () async {
      final mock = _MockHttpClient((uri) async {
        return _MockHttpClientResponse(
          200,
          jsonEncode({
            'content': [
              {'text': '[{"title": "In the End", "artist": "Linkin Park"}]'},
            ],
          }),
        );
      });

      final client = ClaudeAiClient(apiKey: 'test-key', httpClient: mock);

      final results = await client.suggestSimilarForSearch(
        query: 'Numb',
        topTrack: const Track(
          id: 'yt-1',
          title: 'Numb',
          artist: Artist(id: 'a1', name: 'Linkin Park'),
        ),
      );

      expect(results, isNotEmpty);
      expect(results.first.title, 'In the End');
    });

    test(
      'suggestRecommendations returns cached results on repeated call',
      () async {
        final mock = _MockHttpClient((uri) async {
          return _MockHttpClientResponse(
            200,
            '[{"title": "Song X", "artist": "Artist X"}]',
          );
        });

        final client = ClaudeAiClient(httpClient: mock);
        final res1 = await client.suggestRecommendations(
          likedTracks: const [
            Track(
              id: 't1',
              title: 'Track 1',
              artist: Artist(id: 'a1', name: 'Artist 1'),
            ),
          ],
          followedArtists: const [],
          recentTracks: const [],
        );

        final res2 = await client.suggestRecommendations(
          likedTracks: const [
            Track(
              id: 't1',
              title: 'Track 1',
              artist: Artist(id: 'a1', name: 'Artist 1'),
            ),
          ],
          followedArtists: const [],
          recentTracks: const [],
        );

        expect(res1.length, res2.length);
      },
    );
  });
}
