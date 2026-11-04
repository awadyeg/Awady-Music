import 'dart:convert';
import 'dart:io';

import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/sources/http.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:awady_music/data/sources/innertube/parsers/search_parser.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class StaticMockAdapter implements HttpClientAdapter {
  StaticMockAdapter(this.responseMap);

  final Map<String, String> responseMap;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    for (final entry in responseMap.entries) {
      if (options.uri.path.endsWith(entry.key)) {
        return Future.value(
          ResponseBody.fromString(
            entry.value,
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          ),
        );
      }
    }
    return Future.value(ResponseBody.fromString('{}', 200));
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('SearchParser with recorded fixtures', () {
    const parser = SearchParser();

    test('parseSearch parses top artist, songs, artists, and playlists', () {
      final file = File('test/fixtures/innertube/search_adele.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

      final results = parser.parseSearch(json);

      // 1. Top result should be Artist Adele
      expect(results.top, isNotNull);
      expect(results.top, isA<Artist>());
      final topArtist = results.top! as Artist;
      expect(topArtist.name, 'Adele');
      expect(topArtist.isVerified, isTrue);
      expect(topArtist.id, startsWith('yt-UC'));

      // 2. Songs should contain tracks and filter non-originals / non-music
      expect(results.songs, isNotEmpty);
      expect(
        results.songs.any((s) => s.title == 'Set Fire to the Rain'),
        isTrue,
      );
      expect(results.songs.any((s) => s.title == 'Hometown Glory'), isTrue);

      for (final song in results.songs) {
        expect(song.source, TrackSource.yt);
        expect(song.streamId?.length, 11);
        expect(song.id, startsWith('yt-'));
        expect(song.artist.name.isNotEmpty, isTrue);
        // Titles should not have trailing raw "(Official Video)" etc.
        expect(song.title.contains('(Official Video)'), isFalse);
        expect(song.title.contains('(Video Oficial)'), isFalse);
      }

      // Check first valid song
      final setFire = results.songs.firstWhere(
        (s) => s.title == 'Set Fire to the Rain',
      );
      expect(setFire.duration, greaterThanOrEqualTo(0));
      expect(setFire.playCount, greaterThan(0));
      expect(setFire.album?.id, startsWith('MPREb_'));

      // 3. Artists
      expect(results.artists, isNotEmpty);
      for (final artist in results.artists) {
        expect(artist.id, startsWith('yt-UC'));
        expect(artist.name.isNotEmpty, isTrue);
      }

      // 4. Playlists / Albums
      expect(results.playlists, isNotEmpty);
      final album21 = results.playlists.firstWhere((p) => p.name == '21');
      expect(album21.isAlbum, isTrue);
      expect(album21.id, startsWith('ytalb-MPREb_'));
    });

    test('parseSuggestions returns cleaned query strings', () {
      final file = File('test/fixtures/innertube/suggestions.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

      final suggestions = parser.parseSuggestions(json);

      expect(suggestions, isNotEmpty);
      expect(suggestions.any((s) => s.toLowerCase().contains('adele')), isTrue);
    });

    test('helper utilities parse durations, counts, and titles properly', () {
      expect(parseDuration('3:45'), 225);
      expect(parseDuration('1:02:15'), 3735);
      expect(parseDuration(''), 0);
      expect(parseDuration(null), 0);

      expect(parseCount('1.8K views'), 1800);
      expect(parseCount('74M views'), 74000000);
      expect(parseCount('1B views'), 1000000000);
      expect(parseCount('123 views'), 123);
      expect(parseCount(null), 0);

      expect(
        cleanSongTitle('Rolling in the Deep (Official Music Video)'),
        'Rolling in the Deep',
      );
      expect(cleanSongTitle('Hello [Lyric Video]'), 'Hello');
    });

    test(
      'InnertubeClient.search and suggest integrate cleanly with parsers',
      () async {
        final searchRaw = File('test/fixtures/innertube/search_adele.json')
            .readAsStringSync();
        final suggRaw = File('test/fixtures/innertube/suggestions.json')
            .readAsStringSync();

        final dio = createDio()
          ..httpClientAdapter = StaticMockAdapter({
            'search': searchRaw,
            'get_search_suggestions': suggRaw,
          });

        final client = InnertubeClient(dio: dio)
          ..session = const InnertubeSession(
            apiKey: 'TEST_KEY',
            clientVersion: '1.2.3',
          );

        final searchResults = await client.search('adele');
        expect(searchResults.songs, isNotEmpty);
        expect(searchResults.top, isNotNull);

        final suggestions = await client.suggest('adele');
        expect(suggestions, isNotEmpty);
      },
    );
  });
}
