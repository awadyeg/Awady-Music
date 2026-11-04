import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/search_results.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/sources/deezer/deezer_client.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:awady_music/data/sources/innertube/matcher.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

class _FakeInnertubeClient extends InnertubeClient {
  _FakeInnertubeClient({this.matchedTracks = const {}});

  final Map<String, Track?> matchedTracks;

  @override
  Future<SearchResults> search(String q) async {
    for (final entry in matchedTracks.entries) {
      if (q.toLowerCase().contains(entry.key.toLowerCase())) {
        final hit = entry.value;
        return SearchResults(songs: hit != null ? [hit] : const <Track>[]);
      }
    }
    return const SearchResults();
  }

  @override
  Future<List<Track?>> match(List<MatchQuery> items) async {
    final list = <Track?>[];
    for (final item in items) {
      list.add(await matchSingleTrack(this, item));
    }
    return list;
  }
}

void main() {
  group('DeezerClient', () {
    late Dio dio;
    late DioAdapter dioAdapter;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://api.deezer.com'));
      dioAdapter = DioAdapter(dio: dio);
    });

    test(
      'radioTracks returns empty list for blank or Unknown artist',
      () async {
        final client = DeezerClientImpl(dio: dio);

        expect(await client.radioTracks('', 'Song'), isEmpty);
        expect(await client.radioTracks('   ', 'Song'), isEmpty);
        expect(await client.radioTracks('Unknown artist', 'Song'), isEmpty);
      },
    );

    test(
      'radioTracks returns empty list if artist search returns no results',
      () async {
        dioAdapter.onGet(
          '/search/artist?q=NonExistent&limit=1',
          (server) => server.reply(200, {'data': <dynamic>[]}),
        );

        final client = DeezerClientImpl(dio: dio);
        final tracks = await client.radioTracks('NonExistent', 'Song');
        expect(tracks, isEmpty);
      },
    );

    test(
      'radioTracks returns empty list if related artists is empty',
      () async {
        dioAdapter
          ..onGet(
            '/search/artist?q=Adele&limit=1',
            (server) => server.reply(200, {
              'data': [
                {'id': 123, 'name': 'Adele'},
              ],
            }),
          )
          ..onGet(
            '/artist/123/related?limit=6',
            (server) => server.reply(200, {'data': <dynamic>[]}),
          );

        final client = DeezerClientImpl(dio: dio);
        final tracks = await client.radioTracks('Adele', 'Hello');
        expect(tracks, isEmpty);
      },
    );

    test(
      'radioTracks discovers related artists, round-robins, and drops seed',
      () async {
        dioAdapter
          ..onGet(
            '/search/artist?q=Adele&limit=1',
            (server) => server.reply(200, {
              'data': [
                {'id': 123, 'name': 'Adele'},
              ],
            }),
          )
          ..onGet(
            '/artist/123/related?limit=6',
            (server) => server.reply(200, {
              'data': [
                {'id': 10, 'name': 'Sia'},
                {'id': 20, 'name': 'Sam Smith'},
              ],
            }),
          )
          ..onGet(
            '/artist/10/top?limit=3',
            (server) => server.reply(200, {
              'data': [
                {
                  'title': 'Chandelier',
                  'duration': 216,
                  'artist': {'name': 'Sia'},
                },
                {
                  'title': 'Cheap Thrills',
                  'duration': 211,
                  'artist': {'name': 'Sia'},
                },
              ],
            }),
          )
          ..onGet(
            '/artist/20/top?limit=3',
            (server) => server.reply(200, {
              'data': [
                {
                  'title': 'Stay With Me',
                  'duration': 172,
                  'artist': {'name': 'Sam Smith'},
                },
                {
                  // Seed track to be dropped!
                  'title': 'Hello',
                  'duration': 200,
                  'artist': {'name': 'Sam Smith'},
                },
              ],
            }),
          );

        final client = DeezerClientImpl(dio: dio);
        final tracks = await client.radioTracks('Adele', 'Hello', limit: 10);

        // Expected order:
        // Round 0: Sia - Chandelier, Sam Smith - Stay With Me
        // Round 1: Sia - Cheap Thrills (Sam Smith - Hello dropped because seed)
        expect(tracks.length, equals(3));
        expect(tracks[0].artist, equals('Sia'));
        expect(tracks[0].title, equals('Chandelier'));
        expect(tracks[0].duration, equals(216));

        expect(tracks[1].artist, equals('Sam Smith'));
        expect(tracks[1].title, equals('Stay With Me'));
        expect(tracks[1].duration, equals(172));

        expect(tracks[2].artist, equals('Sia'));
        expect(tracks[2].title, equals('Cheap Thrills'));
        expect(tracks[2].duration, equals(211));
      },
    );

    test(
      'radio handles network errors gracefully and returns empty list',
      () async {
        dioAdapter.onGet(
          '/search/artist?q=Adele&limit=1',
          (server) => server.reply(500, {'error': 'Server error'}),
        );

        final client = DeezerClientImpl(dio: dio);
        final tracks = await client.radioTracks('Adele', 'Hello');
        expect(tracks, isEmpty);
      },
    );

    test(
      'radio matches Deezer tracks to YouTube tracks using InnertubeClient',
      () async {
        dioAdapter
          ..onGet(
            '/search/artist?q=Adele&limit=1',
            (server) => server.reply(200, {
              'data': [
                {'id': 123, 'name': 'Adele'},
              ],
            }),
          )
          ..onGet(
            '/artist/123/related?limit=6',
            (server) => server.reply(200, {
              'data': [
                {'id': 10, 'name': 'Sia'},
              ],
            }),
          )
          ..onGet(
            '/artist/10/top?limit=3',
            (server) => server.reply(200, {
              'data': [
                {
                  'title': 'Chandelier',
                  'duration': 216,
                  'artist': {'name': 'Sia'},
                },
              ],
            }),
          );

        final fakeYt = _FakeInnertubeClient(
          matchedTracks: {
            'Chandelier': const Track(
              id: 'yt_chand',
              streamId: 'yt_chand',
              title: 'Chandelier',
              duration: 216,
              source: TrackSource.yt,
              artist: Artist(id: 'sia_ch', name: 'Sia'),
            ),
          },
        );

        final client = DeezerClientImpl(dio: dio, innertubeClient: fakeYt);

        final matched = await client.radio('Adele', 'Hello');
        expect(matched.length, equals(1));
        expect(matched.first.id, equals('yt_chand'));
        expect(matched.first.title, equals('Chandelier'));
        expect(matched.first.artist.name, equals('Sia'));
      },
    );
  });
}
