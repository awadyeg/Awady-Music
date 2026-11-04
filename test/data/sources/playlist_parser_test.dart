import 'dart:convert';
import 'dart:io';

import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/sources/http.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:awady_music/data/sources/innertube/parsers/playlist_parser.dart';
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
  group('PlaylistParser tests', () {
    const parser = PlaylistParser();

    test('parseAlbum parses Adele 25 fixture correctly', () {
      final file = File('test/fixtures/innertube/album.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

      final page = parser.parseAlbum(json, 'MPREb_PiyfuVl6aYd');

      // Album metadata
      expect(page.playlist.id, 'ytalb-MPREb_PiyfuVl6aYd');
      expect(page.playlist.name, '25');
      expect(page.playlist.isAlbum, isTrue);
      expect(page.playlist.owner.name, 'Adele');
      expect(page.playlist.owner.id, 'yt-UCRw0x9_EfawqmgDI2IgQLLg');
      expect(page.playlist.artwork, isNotNull);
      expect(page.playlist.trackCount, 11);

      // Tracks
      expect(page.tracks.length, 11);
      final first = page.tracks.first;
      expect(first.title, 'Hello');
      expect(first.streamId, 'YQHsXMglC9A');
      expect(first.id, 'yt-YQHsXMglC9A');
      expect(first.source, TrackSource.yt);
      expect(first.artist.name, 'Adele');
      expect(first.album?.name, '25');
      expect(first.duration, 296); // 4:56
      expect(first.playCount, greaterThan(0));
      expect(first.artwork, isNotNull);
    });

    test('parsePlaylist parses Adele Cry playlist fixture correctly', () {
      final file = File('test/fixtures/innertube/playlist.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

      final page = parser.parsePlaylist(
        json,
        'VLPLxWkvkj3MUF9nih7I2YHwny7GU3Cd9WN0',
      );

      // Playlist metadata
      expect(page.playlist.id, 'ytpl-VLPLxWkvkj3MUF9nih7I2YHwny7GU3Cd9WN0');
      expect(page.playlist.name, 'adele songs to cry to');
      expect(page.playlist.isAlbum, isFalse);
      expect(page.playlist.description, isNotNull);
      expect(page.playlist.description!.toLowerCase(), contains('tunemymusic'));
      expect(page.playlist.trackCount, 15);
      expect(page.playlist.artwork, isNotNull);

      // Tracks
      expect(page.tracks.length, 15);
      final first = page.tracks.first;
      expect(first.title, 'All I Ask');
      expect(first.streamId, 'jb5g4UFHmfQ');
      expect(first.id, 'yt-jb5g4UFHmfQ');
      expect(first.source, TrackSource.yt);
      expect(first.artist.name, 'Adele');
      expect(first.album?.name, '25');
      expect(first.duration, 272); // 4:32
    });
  });

  group('InnertubeClient album and playlist integration & retry', () {
    test('album method fetches and parses album cleanly', () async {
      final file = File('test/fixtures/innertube/album.json');
      final raw = file.readAsStringSync();

      final dio = createDio()
        ..httpClientAdapter = DynamicMockAdapter((options) async {
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

      final page = await client.album('MPREb_PiyfuVl6aYd');
      expect(page.playlist.name, '25');
      expect(page.tracks.length, 11);
    });

    test(
      'playlist method retries with stripped VL prefix when VL candidate fails',
      () async {
        final file = File('test/fixtures/innertube/playlist.json');
        final raw = file.readAsStringSync();
        final requestedBrowseIds = <String>[];

        final dio = createDio()
          ..httpClientAdapter = DynamicMockAdapter((options) async {
            final data = options.data as Map<String, dynamic>? ?? {};
            final bid = data['browseId'] as String? ?? '';
            requestedBrowseIds.add(bid);

            if (bid.startsWith('VL')) {
              // Simulate 404 for VL prefix
              return ResponseBody.fromString(
                '{"error": "Not Found"}',
                404,
                headers: {
                  Headers.contentTypeHeader: [Headers.jsonContentType],
                },
              );
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
          ..session = const InnertubeSession(
            apiKey: 'KEY',
            clientVersion: '1.0',
          );

        final page = await client.playlist(
          'VLPLxWkvkj3MUF9nih7I2YHwny7GU3Cd9WN0',
        );
        expect(page.playlist.name, 'adele songs to cry to');
        expect(page.tracks.length, 15);
        expect(
          requestedBrowseIds,
          contains('VLPLxWkvkj3MUF9nih7I2YHwny7GU3Cd9WN0'),
        );
        expect(
          requestedBrowseIds,
          contains('PLxWkvkj3MUF9nih7I2YHwny7GU3Cd9WN0'),
        );
      },
    );
  });
}
