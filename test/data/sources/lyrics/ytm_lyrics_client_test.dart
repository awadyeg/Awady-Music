import 'dart:convert';
import 'dart:io';

import 'package:awady_music/data/models/lyrics.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:awady_music/data/sources/lyrics/ytm_lyrics_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mocktail/mocktail.dart';

class MockInnertubeClient extends Mock implements InnertubeClient;

void main() {
  late MockInnertubeClient mockInnertube;
  late Dio dio;
  late DioAdapter dioAdapter;
  late YtmLyricsClient client;

  setUp(() {
    mockInnertube = MockInnertubeClient();
    dio = Dio(BaseOptions());
    dioAdapter = DioAdapter(dio: dio);
    client = YtmLyricsClient(innertube: mockInnertube, dio: dio);
  });

  group('YtmLyricsClient', () {
    test(
      'resolveBrowseId correctly extracts browseId from next.json fixture',
      () {
        final file = File('test/fixtures/innertube/next.json');
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

        final browseId = client.resolveBrowseId(json);
        expect(browseId, equals('MPLYt_PiyfuVl6aYd-10'));
      },
    );

    test('parseBrowseLyrics parses timed lyrics accurately', () {
      final browsePayload = {
        'contents': {
          'sectionListRenderer': {
            'contents': [
              {
                'musicDescriptionShelfRenderer': {
                  'header': {
                    'runs': [
                      {'text': 'Lyrics'},
                    ],
                  },
                },
              },
            ],
          },
        },
        'timedLyricsModel': [
          {
            'lyricsData': {
              'timedLyricsData': [
                {
                  'lyricLine': 'Hello, it is me',
                  'cueRange': {'startTimeMilliseconds': 12000},
                },
                {
                  'lyricLine': 'I was wondering if after all these years',
                  'cueRange': {'startTimeMilliseconds': 18500},
                },
                {
                  'lyricLine': 'You would like to meet',
                  'cueRange': {'startTimeMilliseconds': 24000},
                },
              ],
            },
          },
        ],
      };

      final lyrics = client.parseBrowseLyrics(browsePayload);
      expect(lyrics, isA<SyncedLyrics>());
      final synced = lyrics! as SyncedLyrics;
      expect(synced.source, equals('ytm'));
      expect(synced.lines.length, equals(3));
      expect(synced.lines[0].startMs, equals(12000));
      expect(synced.lines[0].text, equals('Hello, it is me'));
      expect(synced.lines[1].startMs, equals(18500));
      expect(synced.lines[2].startMs, equals(24000));
      expect(synced.fingerprint, isNotEmpty);
    });

    test(
      'parseBrowseLyrics falls back to plain lyrics when timed data is missing',
      () {
        final plainPayload = {
          'contents': {
            'sectionListRenderer': {
              'contents': [
                {
                  'musicDescriptionShelfRenderer': {
                    'description': {
                      'runs': [
                        {'text': 'First line of untimed lyrics\n'},
                        {'text': 'Second line of untimed lyrics'},
                      ],
                    },
                  },
                },
              ],
            },
          },
        };

        final lyrics = client.parseBrowseLyrics(plainPayload);
        expect(lyrics, isA<PlainLyrics>());
        final plain = lyrics! as PlainLyrics;
        expect(
          plain.text,
          equals('First line of untimed lyrics\nSecond line of untimed lyrics'),
        );
      },
    );

    test('timed executes 2-hop sequence end-to-end', () async {
      when(() => mockInnertube.post('/next', {'videoId': 'vid123'})).thenAnswer(
        (_) async => {
          'contents': {
            'tabRenderer': {
              'endpoint': {
                'browseEndpoint': {
                  'browseId': 'MPLYt_sample123',
                  'browseEndpointContextSupportedConfigs': {
                    'browseEndpointContextMusicConfig': {
                      'pageType': 'MUSIC_PAGE_TYPE_TRACK_LYRICS',
                    },
                  },
                },
              },
            },
          },
        },
      );

      dioAdapter.onPost(
        YtmLyricsClient.browseUrl,
        (server) => server.reply(200, {
          'timedLyricsModel': [
            {
              'lyricsData': {
                'timedLyricsData': [
                  {
                    'lyricLine': 'Test timed line',
                    'cueRange': {'startTimeMilliseconds': 5000},
                  },
                ],
              },
            },
          ],
        }),
        data: Matchers.any,
      );

      final result = await client.timed('vid123');
      expect(result, isA<SyncedLyrics>());
      final synced = result! as SyncedLyrics;
      expect(synced.lines.length, equals(1));
      expect(synced.lines.first.text, equals('Test timed line'));
    });
  });
}
