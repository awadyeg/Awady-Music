import 'dart:math' as math;

import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/sources/audius/audius_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  group('Audius originality and scoring logic', () {
    test('isNonOriginalQuery flags queries with remix or edit terms', () {
      expect(isNonOriginalQuery('Adele Easy On Me remix'), isTrue);
      expect(isNonOriginalQuery('Drake Hotline Bling (VIP)'), isTrue);
      expect(isNonOriginalQuery('Nightcore mix 2024'), isTrue);
      expect(isNonOriginalQuery('Bohemian Rhapsody (Acapella)'), isTrue);
      expect(isNonOriginalQuery('Taylor Swift (Live)'), isTrue);
      expect(isNonOriginalQuery('Taylor Swift - Acoustic'), isTrue);
      expect(isNonOriginalQuery('Billie Eilish bad guy'), isFalse);
      expect(isNonOriginalQuery('Ed Sheeran Shape of You'), isFalse);
    });

    test(
      'isNonOriginal flags tracks with remix tags, remix_of, or weak terms',
      () {
        expect(
          isNonOriginal({
            'title': 'Original Song',
            'remix_of': {'id': '123'},
          }),
          isTrue,
        );

        expect(
          isNonOriginal({'title': 'Song (Club Mix)', 'tags': 'dance'}),
          isTrue,
        );

        expect(
          isNonOriginal({'title': 'Song', 'tags': 'dubstep remix contest'}),
          isTrue,
        );

        expect(
          isNonOriginal({'title': 'Pure Studio Song', 'tags': 'pop indie'}),
          isFalse,
        );
      },
    );

    test('isLongForm detects tracks >= 600 seconds', () {
      expect(isLongForm(599), isFalse);
      expect(isLongForm(600), isTrue);
      expect(isLongForm(1200), isTrue);
    });

    test('scoreTrack gives higher rank to verified originals', () {
      final verifiedOriginal = {
        'id': '1',
        'title': 'Hit Song',
        'play_count': 100000,
        'duration': 210,
        'user': {'id': 'u1', 'name': 'Artist', 'is_verified': true},
        'is_streamable': true,
        'is_stream_gated': false,
      };

      final remix = {
        'id': '2',
        'title': 'Hit Song (Remix)',
        'play_count': 100000,
        'duration': 210,
        'user': {'id': 'u2', 'name': 'Remixer', 'is_verified': false},
        'is_streamable': true,
        'is_stream_gated': false,
      };

      final djSet = {
        'id': '3',
        'title': 'Club Live DJ Set',
        'play_count': 100000,
        'duration': 3600,
        'user': {'id': 'u3', 'name': 'DJ', 'is_verified': false},
        'is_streamable': true,
        'is_stream_gated': false,
      };

      final gated = {
        'id': '4',
        'title': 'Exclusive Song',
        'play_count': 100000,
        'duration': 200,
        'user': {'id': 'u4', 'name': 'Singer', 'is_verified': true},
        'is_streamable': true,
        'is_stream_gated': true,
      };

      final sOriginal = scoreTrack(verifiedOriginal);
      final sRemix = scoreTrack(remix);
      final sDjSet = scoreTrack(djSet);
      final sGated = scoreTrack(gated);

      expect(sOriginal > sRemix, isTrue);
      expect(sRemix > sDjSet, isTrue);
      expect(sOriginal > sGated, isTrue);
    });
  });

  group('cleanAndMap helpers', () {
    test(
      'cleanAndMapTracks filters invalid, duplicate, and unplayable tracks',
      () {
        final rawList = [
          {
            'id': 't1',
            'title': 'Track One',
            'duration': 180,
            'play_count': 500,
            'user': {'id': 'u1', 'name': 'Artist One'},
            'is_streamable': true,
            'is_stream_gated': false,
          },
          // Duplicate
          {
            'id': 't1',
            'title': 'Track One Duplicate',
            'duration': 180,
            'user': {'id': 'u1', 'name': 'Artist One'},
          },
          // Missing user
          {'id': 't2', 'title': 'Track Two', 'duration': 200},
          // Unstreamable
          {
            'id': 't3',
            'title': 'Track Three',
            'duration': 200,
            'user': {'id': 'u3', 'name': 'Artist Three'},
            'is_streamable': false,
          },
          // Stream gated
          {
            'id': 't4',
            'title': 'Track Four',
            'duration': 200,
            'user': {'id': 'u4', 'name': 'Artist Four'},
            'is_stream_gated': true,
          },
          // Valid second track
          {
            'id': 't5',
            'title': 'Track Five',
            'duration': 220,
            'user': {'id': 'u5', 'name': 'Artist Five'},
            'is_streamable': true,
            'is_stream_gated': false,
          },
        ];

        final tracks = cleanAndMapTracks(rawList);
        expect(tracks.length, equals(2));
        expect(tracks[0].id, equals('t1'));
        expect(tracks[0].title, equals('Track One'));
        expect(tracks[0].streamId, equals('t1'));
        expect(tracks[0].source, equals(TrackSource.audius));
        expect(tracks[0].artist.name, equals('Artist One'));
        expect(tracks[1].id, equals('t5'));
      },
    );

    test('cleanAndMapUsers maps valid artists and drops broken entries', () {
      final rawList = [
        {'id': 'u1', 'name': 'Adele', 'handle': 'adele', 'is_verified': true},
        {'id': 'u2'}, // Missing name
        {'name': 'No Id'}, // Missing id
        {'id': 'u3', 'name': 'Dua Lipa', 'handle': 'dualipa'},
      ];

      final users = cleanAndMapUsers(rawList);
      expect(users.length, equals(2));
      expect(users[0].name, equals('Adele'));
      expect(users[0].isVerified, isTrue);
      expect(users[1].name, equals('Dua Lipa'));
    });

    test('cleanAndMapPlaylists maps playlists and handles field aliases', () {
      final rawList = [
        {
          'id': 'p1',
          'playlist_name': 'Chill Vibes',
          'is_album': false,
          'track_count': 15,
          'user': {'id': 'u1', 'name': 'Curator'},
        },
        {
          'id': 'p2',
          'name': 'Album Title',
          'isAlbum': true,
          'trackCount': 10,
          'owner': {'id': 'u2', 'name': 'Singer'},
        },
        {
          'id': 'p3',
          // Missing name & owner
        },
      ];

      final playlists = cleanAndMapPlaylists(rawList);
      expect(playlists.length, equals(2));
      expect(playlists[0].name, equals('Chill Vibes'));
      expect(playlists[0].isAlbum, isFalse);
      expect(playlists[0].trackCount, equals(15));
      expect(playlists[0].owner.name, equals('Curator'));

      expect(playlists[1].name, equals('Album Title'));
      expect(playlists[1].isAlbum, isTrue);
      expect(playlists[1].trackCount, equals(10));
      expect(playlists[1].owner.name, equals('Singer'));
    });
  });

  group('AudiusClient host rotation and API requests', () {
    late Dio dio;
    late DioAdapter dioAdapter;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://api.audius.co'));
      dioAdapter = DioAdapter(dio: dio);
    });

    test('bootstraps discovery hosts from api.audius.co', () async {
      dioAdapter
        ..onGet(
          'https://api.audius.co',
          (server) => server.reply(200, {
            'data': ['https://node1.audius.co', 'https://node2.audius.co'],
          }),
        )
        ..onGet(
          'https://node1.audius.co/v1/tracks/trending',
          (server) => server.reply(200, {
            'data': [
              {
                'id': 't1',
                'title': 'Trending Song',
                'duration': 180,
                'user': {'id': 'u1', 'name': 'Artist'},
              },
            ],
          }),
          queryParameters: {
            'app_name': 'AwadyMusic',
            'time': 'week',
            'limit': 20,
          },
        )
        ..onGet(
          'https://node2.audius.co/v1/tracks/trending',
          (server) => server.reply(200, {
            'data': [
              {
                'id': 't1',
                'title': 'Trending Song',
                'duration': 180,
                'user': {'id': 'u1', 'name': 'Artist'},
              },
            ],
          }),
          queryParameters: {
            'app_name': 'AwadyMusic',
            'time': 'week',
            'limit': 20,
          },
        );

      final client = AudiusClientImpl(
        dio: dio,
        random: math.Random(42), // Seed for predictable host selection
      );

      final tracks = await client.trendingTracks();
      expect(tracks.length, equals(1));
      expect(tracks.first.title, equals('Trending Song'));
      expect(client.hosts.contains('https://node1.audius.co'), isTrue);
      expect(client.hosts.contains('https://node2.audius.co'), isTrue);
    });

    test(
      'rotates to next host when current host fails with 5xx or error',
      () async {
        final hosts = [
          'https://failing-node.audius.co',
          'https://working-node.audius.co',
        ];

        dioAdapter
          ..onGet(
            'https://failing-node.audius.co/v1/tracks/search',
            (server) => server.reply(500, {'error': 'Internal server error'}),
            queryParameters: {
              'app_name': 'AwadyMusic',
              'query': 'adele',
              'limit': 40,
            },
          )
          ..onGet(
            'https://working-node.audius.co/v1/tracks/search',
            (server) => server.reply(200, {
              'data': [
                {
                  'id': 'adele1',
                  'title': 'Hello',
                  'duration': 295,
                  'play_count': 500000,
                  'user': {
                    'id': 'u_adele',
                    'name': 'Adele',
                    'is_verified': true,
                  },
                },
              ],
            }),
            queryParameters: {
              'app_name': 'AwadyMusic',
              'query': 'adele',
              'limit': 40,
            },
          );

        // Start client at index 0 (failing node)
        final client = AudiusClientImpl(
          dio: dio,
          initialHosts: hosts,
          initialHostIndex: 0,
        );

        // Initial host points to failing node
        expect(client.currentHost, equals('https://failing-node.audius.co'));

        final results = await client.searchTracks('adele');
        expect(results.length, equals(1));
        expect(results.first.title, equals('Hello'));
        expect(results.first.artist.name, equals('Adele'));

        // Successfully rotated to working node!
        expect(client.currentHost, equals('https://working-node.audius.co'));
      },
    );

    test('deterministic 4xx throws immediately without rotating', () async {
      final hosts = ['https://node1.audius.co', 'https://node2.audius.co'];

      dioAdapter.onGet(
        'https://node1.audius.co/v1/tracks/nonexistent',
        (server) => server.reply(404, {'error': 'Not Found'}),
        queryParameters: {'app_name': 'AwadyMusic'},
      );

      final client = AudiusClientImpl(
        dio: dio,
        initialHosts: hosts,
        initialHostIndex: 0,
      );

      expect(client.currentHost, equals('https://node1.audius.co'));

      expect(
        () => client.track('nonexistent'),
        throwsA(
          isA<AudiusClientException>()
              .having((e) => e.statusCode, 'statusCode', 404)
              .having((e) => e.isFatal, 'isFatal', isTrue),
        ),
      );

      // Host index was NOT rotated on 4xx
      expect(client.currentHost, equals('https://node1.audius.co'));
    });

    test('streamUrl constructs correct URL with current host and app_name', () {
      final client = AudiusClientImpl(
        initialHosts: ['https://discoveryprovider.audius.co'],
      );

      final url = client.streamUrl('track123');
      expect(
        url,
        equals(
          'https://discoveryprovider.audius.co/v1/tracks/track123/stream?app_name=AwadyMusic',
        ),
      );
    });

    test('rotateHost advances host index manually', () {
      final client = AudiusClientImpl(
        initialHosts: [
          'https://host1.audius.co',
          'https://host2.audius.co',
          'https://host3.audius.co',
        ],
        random: math.Random(0),
      );

      final first = client.currentHost;
      client.rotateHost();
      final second = client.currentHost;
      expect(first != second, isTrue);
    });

    test(
      'fetches playlist, playlist tracks, user, user tracks, and albums',
      () async {
        final hosts = ['https://node1.audius.co'];

        dioAdapter
          ..onGet(
            'https://node1.audius.co/v1/playlists/p100',
            (server) => server.reply(200, {
              'data': [
                {
                  'id': 'p100',
                  'playlist_name': 'Summer Hits',
                  'is_album': false,
                  'track_count': 1,
                  'user': {'id': 'u1', 'name': 'DJ Summer'},
                },
              ],
            }),
            queryParameters: {'app_name': 'AwadyMusic'},
          )
          ..onGet(
            'https://node1.audius.co/v1/playlists/p100/tracks',
            (server) => server.reply(200, {
              'data': [
                {
                  'id': 't99',
                  'title': 'Sunshine',
                  'duration': 180,
                  'user': {'id': 'u1', 'name': 'DJ Summer'},
                },
              ],
            }),
            queryParameters: {'app_name': 'AwadyMusic', 'limit': 100},
          )
          ..onGet(
            'https://node1.audius.co/v1/users/u1',
            (server) => server.reply(200, {
              'data': [
                {
                  'id': 'u1',
                  'name': 'DJ Summer',
                  'handle': 'djsummer',
                  'is_verified': true,
                },
              ],
            }),
            queryParameters: {'app_name': 'AwadyMusic'},
          )
          ..onGet(
            'https://node1.audius.co/v1/users/u1/tracks',
            (server) => server.reply(200, {
              'data': [
                {
                  'id': 't99',
                  'title': 'Sunshine',
                  'duration': 180,
                  'user': {'id': 'u1', 'name': 'DJ Summer'},
                },
              ],
            }),
            queryParameters: {
              'app_name': 'AwadyMusic',
              'limit': 50,
              'sort_method': 'plays',
              'sort_direction': 'desc',
            },
          )
          ..onGet(
            'https://node1.audius.co/v1/users/u1/albums',
            (server) => server.reply(200, {
              'data': [
                {
                  'id': 'a1',
                  'playlist_name': 'Summer Album',
                  'is_album': true,
                  'track_count': 10,
                  'user': {'id': 'u1', 'name': 'DJ Summer'},
                },
              ],
            }),
            queryParameters: {'app_name': 'AwadyMusic', 'limit': 100},
          );

        final client = AudiusClientImpl(
          dio: dio,
          initialHosts: hosts,
          random: math.Random(0),
        );

        final pl = await client.playlist('p100');
        expect(pl, isNotNull);
        expect(pl!.name, equals('Summer Hits'));

        final plTracks = await client.playlistTracks('p100');
        expect(plTracks.length, equals(1));
        expect(plTracks.first.title, equals('Sunshine'));

        final usr = await client.user('u1');
        expect(usr, isNotNull);
        expect(usr!.name, equals('DJ Summer'));

        final uTracks = await client.userTracks('u1');
        expect(uTracks.length, equals(1));

        final uAlbums = await client.userAlbums('u1');
        expect(uAlbums.length, equals(1));
        expect(uAlbums.first.isAlbum, isTrue);
      },
    );
  });
}
