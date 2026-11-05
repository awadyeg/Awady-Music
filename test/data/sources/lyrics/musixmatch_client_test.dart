import 'package:awady_music/data/models/lyrics.dart';
import 'package:awady_music/data/sources/lyrics/musixmatch_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late MusixmatchClient client;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dio = Dio(BaseOptions());
    dioAdapter = DioAdapter(dio: dio);
    client = MusixmatchClient(dio: dio);
  });

  group('MusixmatchClient', () {
    test('getToken fetches guest token and caches in prefs', () async {
      final prefs = await SharedPreferences.getInstance();
      client.prefs = prefs;

      dioAdapter.onGet(
        '${MusixmatchClient.baseUrl}/token.get',
        (server) => server.reply(200, {
          'message': {
            'header': {'status_code': 200},
            'body': {'user_token': 'test_token_12345'},
          },
        }),
        queryParameters: {
          'app_id': MusixmatchClient.appId,
          'user_language': 'en',
        },
      );

      final token = await client.getToken();
      expect(token, equals('test_token_12345'));
      expect(
        prefs.getString(MusixmatchClient.tokenPrefsKey),
        equals('test_token_12345'),
      );

      // Subsequent call uses cache, no network hit
      final cachedToken = await client.getToken();
      expect(cachedToken, equals('test_token_12345'));
    });

    test(
      'searchLyrics handles 401 token expiry by refreshing token once',
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          MusixmatchClient.tokenPrefsKey,
          'old_expired_token',
        );
        client.prefs = prefs;

        // 1. Initial search with expired token returns 401
        dioAdapter
          ..onGet(
            '${MusixmatchClient.baseUrl}/track.search',
            (server) => server.reply(200, {
              'message': {
                'header': {'status_code': 401},
              },
            }),
            queryParameters: {
              'q_track': 'Hello',
              'q_artist': 'Adele',
              'app_id': MusixmatchClient.appId,
              'usertoken': 'old_expired_token',
              'page_size': 4,
              's_track_rating': 'desc',
            },
          )
          // 2. Client refreshes token
          ..onGet(
            '${MusixmatchClient.baseUrl}/token.get',
            (server) => server.reply(200, {
              'message': {
                'header': {'status_code': 200},
                'body': {'user_token': 'new_fresh_token'},
              },
            }),
            queryParameters: {
              'app_id': MusixmatchClient.appId,
              'user_language': 'en',
            },
          )
          // 3. Retry search succeeds with new token
          ..onGet(
            '${MusixmatchClient.baseUrl}/track.search',
            (server) => server.reply(200, {
              'message': {
                'header': {'status_code': 200},
                'body': {
                  'track_list': [
                    {
                      'track': {
                        'track_id': 99123,
                        'track_name': 'Hello',
                        'artist_name': 'Adele',
                        'track_length': 295,
                        'has_subtitles': 1,
                      },
                    },
                  ],
                },
              },
            }),
            queryParameters: {
              'q_track': 'Hello',
              'q_artist': 'Adele',
              'app_id': MusixmatchClient.appId,
              'usertoken': 'new_fresh_token',
              'page_size': 4,
              's_track_rating': 'desc',
            },
          )
          // 4. Subtitle fetch succeeds
          ..onGet(
            '${MusixmatchClient.baseUrl}/track.subtitle.get',
            (server) => server.reply(200, {
              'message': {
                'header': {'status_code': 200},
                'body': {
                  'subtitle': {
                    'subtitle_body':
                        '[00:10.00] Hello from the other side\n'
                        '[00:15.00] I must have called',
                  },
                },
              },
            }),
            queryParameters: {
              'track_id': '99123',
              'subtitle_format': 'lrc',
              'app_id': MusixmatchClient.appId,
              'usertoken': 'new_fresh_token',
            },
          );

        final candidates = await client.searchLyrics('Hello', 'Adele');
        expect(candidates.length, equals(1));
        expect(candidates.first.trackName, equals('Hello'));
        expect(candidates.first.durationSec, equals(295));
        expect(candidates.first.lrc, contains('Hello from the other side'));
      },
    );

    test(
      'getLyrics selects closest duration and returns SyncedLyrics',
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(MusixmatchClient.tokenPrefsKey, 'valid_token');
        client.prefs = prefs;

        dioAdapter
          ..onGet(
            '${MusixmatchClient.baseUrl}/track.search',
            (server) => server.reply(200, {
              'message': {
                'header': {'status_code': 200},
                'body': {
                  'track_list': [
                    {
                      'track': {
                        'track_id': 101,
                        'track_name': 'Song (Short Radio Edit)',
                        'artist_name': 'Band',
                        'track_length': 180,
                        'has_subtitles': 1,
                      },
                    },
                    {
                      'track': {
                        'track_id': 102,
                        'track_name': 'Song (Album Version)',
                        'artist_name': 'Band',
                        'track_length': 240,
                        'has_subtitles': 1,
                      },
                    },
                  ],
                },
              },
            }),
            queryParameters: {
              'q_track': 'Song',
              'q_artist': 'Band',
              'app_id': MusixmatchClient.appId,
              'usertoken': 'valid_token',
              'page_size': 4,
              's_track_rating': 'desc',
            },
          )
          ..onGet(
            '${MusixmatchClient.baseUrl}/track.subtitle.get',
            (server) => server.reply(200, {
              'message': {
                'header': {'status_code': 200},
                'body': {
                  'subtitle': {'subtitle_body': '[00:05.00] Radio edit line'},
                },
              },
            }),
            queryParameters: {
              'track_id': '101',
              'subtitle_format': 'lrc',
              'app_id': MusixmatchClient.appId,
              'usertoken': 'valid_token',
            },
          )
          ..onGet(
            '${MusixmatchClient.baseUrl}/track.subtitle.get',
            (server) => server.reply(200, {
              'message': {
                'header': {'status_code': 200},
                'body': {
                  'subtitle': {
                    'subtitle_body': '[00:05.00] Album version line',
                  },
                },
              },
            }),
            queryParameters: {
              'track_id': '102',
              'subtitle_format': 'lrc',
              'app_id': MusixmatchClient.appId,
              'usertoken': 'valid_token',
            },
          );

        // Expected duration 242 seconds -> should pick track 102 (240s)
        // over track 101 (180s)
        final lyrics = await client.getLyrics(
          'Song',
          'Band',
          expectedDurationSec: 242,
        );
        expect(lyrics, isA<SyncedLyrics>());
        final synced = lyrics!;
        expect(synced.source, equals('musixmatch'));
        expect(synced.lines.first.text, equals('Album version line'));
      },
    );
  });
}
