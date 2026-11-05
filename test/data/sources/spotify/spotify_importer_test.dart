import 'dart:io';

import 'package:awady_music/data/sources/spotify/spotify_importer.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  group('SpotifyImporter - extractPlaylistId', () {
    test('extracts from web URL', () {
      expect(
        SpotifyImporter.extractPlaylistId(
          'https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M?si=123',
        ),
        '37i9dQZF1DXcBWIGoYBM5M',
      );
    });

    test('extracts from uri', () {
      expect(
        SpotifyImporter.extractPlaylistId(
          'spotify:playlist:37i9dQZF1DXcBWIGoYBM5M',
        ),
        '37i9dQZF1DXcBWIGoYBM5M',
      );
    });

    test('accepts raw valid ID', () {
      expect(
        SpotifyImporter.extractPlaylistId('37i9dQZF1DXcBWIGoYBM5M'),
        '37i9dQZF1DXcBWIGoYBM5M',
      );
    });

    test('returns null on invalid input', () {
      expect(SpotifyImporter.extractPlaylistId('invalid-url-here'), isNull);
      expect(SpotifyImporter.extractPlaylistId(''), isNull);
    });
  });

  group('SpotifyImporter - parseEmbed fixture', () {
    test('parses embed HTML correctly', () {
      final html = File('test/fixtures/spotify_embed.html').readAsStringSync();
      final parsed = SpotifyImporter.parseEmbed(html);

      expect(parsed, isNotNull);
      expect(parsed!.name, "Today's Top Hits");
      expect(parsed.total, 50);
      expect(parsed.token, 'mock_spotify_token_12345');
      expect(parsed.tracks.length, 3);
      expect(parsed.tracks[0].title, 'Espresso');
      expect(parsed.tracks[0].artist, 'Sabrina Carpenter');
      expect(parsed.tracks[1].title, 'Birds of a Feather');
      expect(parsed.tracks[1].artist, 'Billie Eilish');
      expect(parsed.tracks[2].title, 'Good Luck, Babe!');
      expect(parsed.tracks[2].artist, 'Chappell Roan');
    });

    test('returns null on malformed HTML', () {
      expect(
        SpotifyImporter.parseEmbed('<html><body>No data</body></html>'),
        isNull,
      );
    });
  });

  group('SpotifyImporter - mapItem', () {
    test('maps Track item with duration and multiple artists', () {
      final raw = {
        'itemV2': {
          'data': {
            '__typename': 'Track',
            'name': 'Stay',
            'artists': {
              'items': [
                {
                  'profile': {'name': 'The Kid LAROI'},
                },
                {
                  'profile': {'name': 'Justin Bieber'},
                },
              ],
            },
            'trackDuration': {'totalMilliseconds': 141806},
          },
        },
      };

      final entry = SpotifyImporter.mapItem(raw);
      expect(entry, isNotNull);
      expect(entry!.title, 'Stay');
      expect(entry.artist, 'The Kid LAROI, Justin Bieber');
      expect(entry.duration, 142);
    });

    test('ignores non-Track items like episodes', () {
      final raw = {
        'itemV2': {
          'data': {'__typename': 'Episode', 'name': 'Podcast Episode 1'},
        },
      };

      expect(SpotifyImporter.mapItem(raw), isNull);
    });
  });

  group('SpotifyImporter - full import flow', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late SpotifyImporter importer;

    setUp(() {
      dio = Dio();
      dioAdapter = DioAdapter(dio: dio);
      importer = SpotifyImporter(dio: dio);
    });

    test(
      'imports via pathfinder when token available and pathfinder succeeds',
      () async {
        final html = File('test/fixtures/spotify_embed.html')
            .readAsStringSync();
        const playlistId = '37i9dQZF1DXcBWIGoYBM5M';

        dioAdapter
          ..onGet(
            'https://open.spotify.com/embed/playlist/$playlistId',
            (server) => server.reply(200, html),
          )
          ..onPost(
            SpotifyImporter.pathfinderUrl,
            (server) => server.reply(200, {
              'data': {
                'playlistV2': {
                  'name': "Today's Top Hits (Pathfinder)",
                  'content': {
                    'totalCount': 3,
                    'items': [
                      {
                        'itemV2': {
                          'data': {
                            '__typename': 'Track',
                            'name': 'Espresso',
                            'artists': {
                              'items': [
                                {
                                  'profile': {'name': 'Sabrina Carpenter'},
                                },
                              ],
                            },
                            'trackDuration': {'totalMilliseconds': 175000},
                          },
                        },
                      },
                      {
                        'itemV2': {
                          'data': {
                            '__typename': 'Track',
                            'name': 'Birds of a Feather',
                            'artists': {
                              'items': [
                                {
                                  'profile': {'name': 'Billie Eilish'},
                                },
                              ],
                            },
                            'trackDuration': {'totalMilliseconds': 192000},
                          },
                        },
                      },
                      {
                        'itemV2': {
                          'data': {
                            '__typename': 'Track',
                            'name': 'Good Luck, Babe!',
                            'artists': {
                              'items': [
                                {
                                  'profile': {'name': 'Chappell Roan'},
                                },
                              ],
                            },
                            'trackDuration': {'totalMilliseconds': 218000},
                          },
                        },
                      },
                    ],
                  },
                },
              },
            }),
            data: Matchers.any,
          );

        final res = await importer.importPlaylist(playlistId);
        expect(res.ok, isTrue);
        expect(res.source, 'pathfinder');
        expect(res.name, "Today's Top Hits (Pathfinder)");
        expect(res.tracks.length, 3);
        expect(res.tracks[0].title, 'Espresso');
        expect(res.tracks[0].duration, 175);
        expect(res.limited, isFalse);
      },
    );

    test('falls back to embed when pathfinder fails', () async {
      final html = File('test/fixtures/spotify_embed.html').readAsStringSync();
      const playlistId = '37i9dQZF1DXcBWIGoYBM5M';

      dioAdapter
        ..onGet(
          'https://open.spotify.com/embed/playlist/$playlistId',
          (server) => server.reply(200, html),
        )
        ..onPost(
          SpotifyImporter.pathfinderUrl,
          (server) => server.reply(500, {'error': 'Internal server error'}),
        );

      final res = await importer.importPlaylist(playlistId);
      expect(res.ok, isTrue);
      expect(res.source, 'embed');
      expect(res.name, "Today's Top Hits");
      expect(res.tracks.length, 3);
      expect(res.limited, isTrue);
    });
  });
}
