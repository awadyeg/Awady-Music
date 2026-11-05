import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/playlist_page.dart';
import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:awady_music/data/sources/youtube/yt_playlist_importer.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeInnertubeClient extends Fake implements InnertubeClient {
  PlaylistPage? response;
  bool shouldThrow = false;

  @override
  Future<PlaylistPage> playlist(String browseId) async {
    if (shouldThrow) {
      throw Exception('Network error');
    }
    return response ??
        PlaylistPage(
          playlist: RemotePlaylist(
            id: browseId,
            name: 'Empty',
            owner: const Artist(id: 'test-artist', name: 'Test'),
          ),
        );
  }
}

void main() {
  group('YtPlaylistImporter - extractPlaylistId', () {
    test('extracts from music.youtube.com URL', () {
      expect(
        YtPlaylistImporter.extractPlaylistId(
          'https://music.youtube.com/playlist?list=PLrAXtmErZgOdP_8GztsuKi9upL79oz448',
        ),
        'PLrAXtmErZgOdP_8GztsuKi9upL79oz448',
      );
    });

    test('extracts from watch URL with list param and strips VL', () {
      expect(
        YtPlaylistImporter.extractPlaylistId(
          'https://www.youtube.com/watch?v=dQw4w9WgXcQ&list=VLPLrAXtmErZgOdP_8GztsuKi9upL79oz448',
        ),
        'PLrAXtmErZgOdP_8GztsuKi9upL79oz448',
      );
    });

    test('extracts from raw ID with VL prefix', () {
      expect(
        YtPlaylistImporter.extractPlaylistId('VLPLrAXtmErZgOdP'),
        'PLrAXtmErZgOdP',
      );
    });

    test('accepts raw playlist ID', () {
      expect(
        YtPlaylistImporter.extractPlaylistId(
          'PLrAXtmErZgOdP_8GztsuKi9upL79oz448',
        ),
        'PLrAXtmErZgOdP_8GztsuKi9upL79oz448',
      );
    });

    test('returns null for invalid strings', () {
      expect(YtPlaylistImporter.extractPlaylistId(''), isNull);
      expect(YtPlaylistImporter.extractPlaylistId('abc'), isNull);
    });
  });

  group('YtPlaylistImporter - importPlaylist', () {
    late _FakeInnertubeClient fakeInnertube;
    late YtPlaylistImporter importer;

    setUp(() {
      fakeInnertube = _FakeInnertubeClient();
      importer = YtPlaylistImporter(innertube: fakeInnertube);
    });

    test('imports successfully when innertube returns tracks', () async {
      fakeInnertube.response = const PlaylistPage(
        playlist: RemotePlaylist(
          id: 'PL1234567890123',
          name: 'My Cool Jams',
          owner: Artist(id: 'dj-awady', name: 'DJ Awady'),
        ),
        tracks: [
          Track(
            id: 'yt-track-1',
            title: 'Track One',
            artist: Artist(id: 'dj-awady', name: 'DJ Awady'),
            duration: 180,
            source: TrackSource.yt,
          ),
          Track(
            id: 'yt-track-2',
            title: 'Track Two',
            artist: Artist(id: 'dj-awady', name: 'DJ Awady'),
            duration: 210,
            source: TrackSource.yt,
          ),
        ],
      );

      final res = await importer.importPlaylist(
        'https://music.youtube.com/playlist?list=PL1234567890123',
      );

      expect(res.ok, isTrue);
      expect(res.id, 'PL1234567890123');
      expect(res.name, 'My Cool Jams');
      expect(res.tracks.length, 2);
      expect(res.tracks[0].title, 'Track One');
    });

    test('returns failed when innertube returns empty playlist', () async {
      fakeInnertube.response = const PlaylistPage(
        playlist: RemotePlaylist(
          id: 'PL1234567890123',
          name: 'Empty Playlist',
          owner: Artist(id: 'someone', name: 'Someone'),
        ),
      );

      final res = await importer.importPlaylist(
        'https://music.youtube.com/playlist?list=PL1234567890123',
      );

      expect(res.ok, isFalse);
    });

    test('returns failed when innertube throws', () async {
      fakeInnertube.shouldThrow = true;

      final res = await importer.importPlaylist(
        'https://music.youtube.com/playlist?list=PL1234567890123',
      );

      expect(res.ok, isFalse);
    });
  });
}
