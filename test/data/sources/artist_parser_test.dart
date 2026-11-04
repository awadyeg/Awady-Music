import 'dart:convert';
import 'dart:io';

import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/sources/http.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:awady_music/data/sources/innertube/parsers/artist_parser.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class ArtistMockAdapter implements HttpClientAdapter {
  ArtistMockAdapter(this.browseResponse);

  final String browseResponse;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return Future.value(
      ResponseBody.fromString(
        browseResponse,
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('ArtistParser with recorded Adele fixture', () {
    const parser = ArtistParser();

    test('parseArtistPage parses profile, top songs, albums, and singles', () {
      final file = File('test/fixtures/innertube/artist_adele.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

      final page = parser.parseArtistPage(
        json,
        channelId: 'UCRw0x9_EfawqmgDI2IgQLLg',
      );

      // 1. Profile metadata
      expect(page.artist.name, 'Adele');
      expect(page.artist.id, 'yt-UCRw0x9_EfawqmgDI2IgQLLg');
      // Adele's raw browse fixture does not have verified badge in
      // immersive header.
      expect(page.artist.isVerified, isFalse);
      expect(page.artist.followerCount, greaterThan(0));
      expect(page.artist.profilePicture, isNotNull);
      expect(page.artist.coverPhoto, isNotNull);

      // 2. Top songs
      expect(page.topSongs, isNotEmpty);
      for (final song in page.topSongs) {
        expect(song.source, TrackSource.yt);
        expect(song.streamId?.length, 11);
        expect(song.artist.name, 'Adele');
        expect(song.id, startsWith('yt-'));
      }

      // Check first top song
      final firstSong = page.topSongs.first;
      expect(firstSong.title.isNotEmpty, isTrue);
      expect(firstSong.playCount, greaterThan(0));

      // 3. Albums
      expect(page.albums, isNotEmpty);
      for (final album in page.albums) {
        expect(album.isAlbum, isTrue);
        expect(album.id, startsWith('ytalb-'));
        expect(album.name.isNotEmpty, isTrue);
      }

      // 4. Singles
      expect(page.singles, isNotEmpty);
      for (final single in page.singles) {
        expect(single.isAlbum, isFalse);
        expect(single.id, startsWith('ytalb-'));
        expect(single.name.isNotEmpty, isTrue);
      }

      // 5. Bio
      expect(page.bio, isNotNull);
      expect(page.bio!.toLowerCase(), contains('adele'));
    });

    test('detects verified badge in header', () {
      final headerWithBadge = {
        'header': {
          'musicImmersiveHeaderRenderer': {
            'title': {
              'runs': [
                {'text': 'Verified Artist'},
              ],
            },
            'badges': [
              {
                'musicInlineBadgeRenderer': {
                  'icon': {'iconType': 'MUSIC_VERIFIED_ARTIST'},
                  'accessibilityData': {
                    'accessibilityData': {'label': 'Official Artist Channel'},
                  },
                },
              },
            ],
          },
        },
      };
      final page = parser.parseArtistPage(headerWithBadge, channelId: 'UC123');
      expect(page.artist.isVerified, isTrue);
    });

    test('parseMpadDiscography walks and separates albums and singles', () {
      final mpadFixture = {
        'contents': [
          {
            'musicTwoRowItemRenderer': {
              'title': {
                'runs': [
                  {'text': '30'},
                ],
              },
              'subtitle': {
                'runs': [
                  {'text': 'Album • 2021'},
                ],
              },
              'navigationEndpoint': {
                'browseEndpoint': {'browseId': 'MPREb_30'},
              },
            },
          },
          {
            'musicTwoRowItemRenderer': {
              'title': {
                'runs': [
                  {'text': 'Easy On Me'},
                ],
              },
              'subtitle': {
                'runs': [
                  {'text': 'Single • 2021'},
                ],
              },
              'navigationEndpoint': {
                'browseEndpoint': {'browseId': 'MPREb_single'},
              },
            },
          },
        ],
      };

      final result = parser.parseMpadDiscography(mpadFixture, 'Adele');
      expect(result.albums.length, 1);
      expect(result.albums.first.name, '30');
      expect(result.albums.first.isAlbum, isTrue);

      expect(result.singles.length, 1);
      expect(result.singles.first.name, 'Easy On Me');
      expect(result.singles.first.isAlbum, isFalse);
    });

    test(
      'InnertubeClient.artist integrates cleanly with artist parser',
      () async {
        final file = File('test/fixtures/innertube/artist_adele.json');
        final raw = file.readAsStringSync();

        final dio = createDio()..httpClientAdapter = ArtistMockAdapter(raw);
        final client = InnertubeClient(dio: dio)
          ..session = const InnertubeSession(
            apiKey: 'TEST_KEY',
            clientVersion: '1.2.3',
          );

        final page = await client.artist('UCRw0x9_EfawqmgDI2IgQLLg');
        expect(page.artist.name, 'Adele');
        expect(page.topSongs, isNotEmpty);
        expect(page.albums, isNotEmpty);
      },
    );
  });
}
