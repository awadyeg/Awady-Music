import 'dart:convert';
import 'dart:io';

import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/sources/http.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:awady_music/data/sources/innertube/parsers/browse_parser.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class DynamicMockAdapter implements HttpClientAdapter {
  DynamicMockAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('BrowseParser tests', () {
    const parser = BrowseParser();

    test('parseHomePlaylists parses home and explore fixtures correctly', () {
      final homeFile = File('test/fixtures/innertube/home.json');
      final homeJson =
          jsonDecode(homeFile.readAsStringSync()) as Map<String, dynamic>;
      final homePlaylists = parser.parseHomePlaylists(homeJson);
      expect(homePlaylists, isNotEmpty);
      for (final pl in homePlaylists) {
        expect(pl.id, startsWith('yt'));
        expect(pl.name.isNotEmpty, isTrue);
      }

      final exploreFile = File('test/fixtures/innertube/explore.json');
      final exploreJson =
          jsonDecode(exploreFile.readAsStringSync()) as Map<String, dynamic>;
      final explorePlaylists = parser.parseHomePlaylists(exploreJson);
      expect(explorePlaylists.length, greaterThan(10));
    });

    test('parseNewReleases parses new_releases fixture correctly', () {
      final file = File('test/fixtures/innertube/new_releases.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final releases = parser.parseNewReleases(json, limit: 16);
      expect(releases.length, lessThanOrEqualTo(16));
      expect(releases, isNotEmpty);
      for (final r in releases) {
        expect(r.id, startsWith('yt'));
        expect(r.name.isNotEmpty, isTrue);
      }
    });

    test('parseCharts parses chart playlist IDs from charts fixture', () {
      final file = File('test/fixtures/innertube/charts.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final result = parser.parseCharts(json);
      expect(result.chartPlaylistIds, isNotEmpty);
      expect(
        result.chartPlaylistIds.first,
        'VLPL4fGSI1pDJn4NCd11e_ojTI-hjP8BZ3P2',
      );
    });

    test('parseMoods parses categories with name, params, and stripeColor', () {
      final file = File('test/fixtures/innertube/moods.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final moods = parser.parseMoods(json);
      expect(moods.length, 34);
      final first = moods.first;
      expect(first.name, 'Chill');
      expect(first.params, 'ggMPOg1uX1JOQWZFeDByc2Jm');
      expect(first.stripeColor, isNotNull);
    });

    test('parseMoodPage parses mood category page fixture', () {
      final file = File('test/fixtures/innertube/mood_page.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final page = parser.parseMoodPage(json);
      expect(page.name, 'Chill');
      expect(page.playlists, isNotEmpty);
      expect(page.playlists.length, lessThanOrEqualTo(24));
    });

    test('parseUpNext maps playlistPanelVideoRenderer from next fixture', () {
      final file = File('test/fixtures/innertube/next.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final tracks = parser.parseUpNext(json);
      expect(tracks, isNotEmpty);
      final track = tracks.first;
      expect(track.streamId, 'jb5g4UFHmfQ');
      expect(track.id, 'yt-jb5g4UFHmfQ');
      expect(track.source, TrackSource.yt);
      expect(track.title, 'All I Ask');
      expect(track.artist.name, 'Adele');
      expect(track.album?.name, '25');
      expect(track.duration, 272);
      expect(track.artwork, isNotNull);
    });
  });

  group('InnertubeClient browse integration', () {
    test('moods, mood, newReleases, and upNext integrate cleanly', () async {
      final moodsRaw = File('test/fixtures/innertube/moods.json')
          .readAsStringSync();
      final moodPageRaw = File('test/fixtures/innertube/mood_page.json')
          .readAsStringSync();
      final nrRaw = File('test/fixtures/innertube/new_releases.json')
          .readAsStringSync();
      final nextRaw = File('test/fixtures/innertube/next.json')
          .readAsStringSync();

      final dio = createDio()
        ..httpClientAdapter = DynamicMockAdapter((options) async {
          final path = options.path;
          final data = options.data as Map<String, dynamic>? ?? {};
          final bid = data['browseId'] as String? ?? '';

          String raw;
          if (path.contains('next')) {
            raw = nextRaw;
          } else if (bid == 'FEmusic_moods_and_genres') {
            raw = moodsRaw;
          } else if (bid == 'FEmusic_moods_and_genres_category') {
            raw = moodPageRaw;
          } else if (bid == 'FEmusic_new_releases') {
            raw = nrRaw;
          } else {
            raw = '{}';
          }

          return ResponseBody.fromString(
            raw,
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

      final client = InnertubeClient(dio: dio)
        ..session = const InnertubeSession(apiKey: 'KEY', clientVersion: '1.0');

      final moods = await client.moods();
      expect(moods.length, 34);

      final moodPage = await client.mood('ggMPOg1uX1JOQWZFeDByc2Jm');
      expect(moodPage.name, 'Chill');
      expect(moodPage.playlists, isNotEmpty);

      final releases = await client.newReleases();
      expect(releases, isNotEmpty);

      final nextTracks = await client.upNext('jb5g4UFHmfQ');
      expect(nextTracks, isNotEmpty);
      expect(nextTracks.first.title, 'All I Ask');
    });
  });
}
