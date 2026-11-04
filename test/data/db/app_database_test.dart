import 'package:awady_music/data/db/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late LibraryDao libraryDao;
  late PlaylistDao playlistDao;
  late DownloadsDao downloadsDao;
  late StatsDao statsDao;
  late CacheDao cacheDao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    libraryDao = LibraryDao(db);
    playlistDao = PlaylistDao(db);
    downloadsDao = DownloadsDao(db);
    statsDao = StatsDao(db);
    cacheDao = CacheDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('LibraryDao tests', () {
    test('upsertTrack and getTrackJson', () async {
      await libraryDao.upsertTrack('yt-1', '{"title": "Song 1"}');
      final json = await libraryDao.getTrackJson('yt-1');
      expect(json, '{"title": "Song 1"}');

      // Update
      await libraryDao.upsertTrack('yt-1', '{"title": "Song 1 Updated"}');
      final updated = await libraryDao.getTrackJson('yt-1');
      expect(updated, '{"title": "Song 1 Updated"}');
    });

    test('like and unlike tracks', () async {
      final now = DateTime.utc(2026, 11, 4, 12);
      await libraryDao.likeTrack('yt-1', now);
      expect(await libraryDao.isLiked('yt-1'), isTrue);
      expect(await libraryDao.isLiked('yt-2'), isFalse);

      final liked = await libraryDao.getLikedTrackIds();
      expect(liked, ['yt-1']);

      await libraryDao.unlikeTrack('yt-1');
      expect(await libraryDao.isLiked('yt-1'), isFalse);
      expect(await libraryDao.getLikedTrackIds(), isEmpty);
    });

    test('addRecent and cap at 50', () async {
      final baseTime = DateTime.utc(2026, 11, 4, 10);
      for (var i = 1; i <= 60; i++) {
        await libraryDao.addRecent('yt-$i', baseTime.add(Duration(minutes: i)));
      }

      final recents = await libraryDao.getRecentTrackIds(100);
      // Most recent first: yt-60 down to yt-11 (50 total)
      expect(recents.length, 50);
      expect(recents.first, 'yt-60');
      expect(recents.last, 'yt-11');
    });

    test('follow and unfollow artists', () async {
      final now = DateTime.utc(2026, 11, 4, 12);
      await libraryDao.followArtist('yt-art1', '{"name": "Adele"}', now);
      expect(await libraryDao.isFollowed('yt-art1'), isTrue);
      expect(await libraryDao.isFollowed('yt-art2'), isFalse);

      final jsons = await libraryDao.getFollowedArtistJsons();
      expect(jsons, ['{"name": "Adele"}']);

      await libraryDao.unfollowArtist('yt-art1');
      expect(await libraryDao.isFollowed('yt-art1'), isFalse);
    });
  });

  group('PlaylistDao tests', () {
    test('create, rename, delete playlist and manage tracks', () async {
      final now = DateTime.utc(2026, 11, 4, 12);
      await playlistDao.createPlaylist('p1', 'Workout', now);

      var playlists = await playlistDao.getAllPlaylists();
      expect(playlists.length, 1);
      expect(playlists.first.name, 'Workout');

      await playlistDao.renamePlaylist('p1', 'Gym Workout');
      playlists = await playlistDao.getAllPlaylists();
      expect(playlists.first.name, 'Gym Workout');

      // Add tracks
      await playlistDao.addTrackToPlaylist('p1', 'yt-1', 0);
      await playlistDao.addTrackToPlaylist('p1', 'yt-2', 1, pending: true);
      await playlistDao.addTrackToPlaylist('p1', 'yt-3', 2);

      var tracks = await playlistDao.getPlaylistTracks('p1');
      expect(tracks.length, 3);
      expect(tracks[0].trackId, 'yt-1');
      expect(tracks[1].pending, isTrue);

      // Remove middle track (yt-2 at pos 1) -> re-compacts
      await playlistDao.removeTrackFromPlaylist('p1', 1);
      tracks = await playlistDao.getPlaylistTracks('p1');
      expect(tracks.length, 2);
      expect(tracks[0].trackId, 'yt-1');
      expect(tracks[0].position, 0);
      expect(tracks[1].trackId, 'yt-3');
      expect(tracks[1].position, 1);

      // Set new playlist tracks
      await playlistDao.setPlaylistTracks('p1', [
        (trackId: 'yt-10', pending: false),
        (trackId: 'yt-20', pending: false),
      ]);
      tracks = await playlistDao.getPlaylistTracks('p1');
      expect(tracks.length, 2);
      expect(tracks[0].trackId, 'yt-10');
      expect(tracks[1].trackId, 'yt-20');

      // Delete playlist
      await playlistDao.deletePlaylist('p1');
      expect(await playlistDao.getAllPlaylists(), isEmpty);
      expect(await playlistDao.getPlaylistTracks('p1'), isEmpty);
    });
  });

  group('DownloadsDao tests', () {
    test('insert, get, and delete downloads', () async {
      final now = DateTime.utc(2026, 11, 4, 12);
      await downloadsDao.insertDownload('yt-1', '/storage/yt-1.m4a', now);

      final dl = await downloadsDao.getDownload('yt-1');
      expect(dl, isNotNull);
      expect(dl!.filePath, '/storage/yt-1.m4a');

      final all = await downloadsDao.getAllDownloads();
      expect(all.length, 1);

      await downloadsDao.deleteDownload('yt-1');
      expect(await downloadsDao.getDownload('yt-1'), isNull);
    });
  });

  group('StatsDao tests', () {
    test('recordPlay accumulates plays and ms', () async {
      await statsDao.recordPlay(
        trackId: 'yt-1',
        artistId: 'art-1',
        artistName: 'Adele',
        ms: 120000,
        dayKey: '2026-11-04',
        artistArt: 'https://example.com/art.jpg',
      );
      await statsDao.recordPlay(
        trackId: 'yt-1',
        artistId: 'art-1',
        artistName: 'Adele',
        ms: 80000,
        dayKey: '2026-11-04',
      );

      final topTracks = await statsDao.getTopTracks(5);
      expect(topTracks.first.trackId, 'yt-1');
      expect(topTracks.first.plays, 2);
      expect(topTracks.first.ms, 200000);

      final topArtists = await statsDao.getTopArtists(5);
      expect(topArtists.first.artistId, 'art-1');
      expect(topArtists.first.plays, 2);
      expect(topArtists.first.ms, 200000);

      final dayMs = await statsDao.getDayMs('2026-11-04');
      expect(dayMs, 200000);

      await statsDao.upsertMonth('2026-11', '{"ms": 200000}');
      final monthJson = await statsDao.getMonthJson('2026-11');
      expect(monthJson, '{"ms": 200000}');
    });
  });

  group('CacheDao tests', () {
    test('stream url cache and expiry', () async {
      final futureExpiry = DateTime.now().add(const Duration(hours: 4));
      await cacheDao.putStreamUrl('vid-1', 'https://video.url/1', futureExpiry);

      final cachedUrl = await cacheDao.getStreamUrl('vid-1');
      expect(cachedUrl, 'https://video.url/1');

      // Expired url
      final pastExpiry = DateTime.now().subtract(const Duration(hours: 1));
      await cacheDao.putStreamUrl('vid-2', 'https://video.url/2', pastExpiry);
      expect(await cacheDao.getStreamUrl('vid-2'), isNull);
    });

    test('song match cache', () async {
      await cacheDao.putSongMatch('adele|hello', '{"title": "Hello"}');
      final match = await cacheDao.getSongMatch('adele|hello');
      expect(match, '{"title": "Hello"}');
    });

    test('queue state persistence', () async {
      await cacheDao.saveQueueState('{"index": 2, "pos": 45}');
      final state = await cacheDao.getQueueState();
      expect(state, '{"index": 2, "pos": 45}');
    });

    test('lyric offset persistence', () async {
      await cacheDao.putLyricOffset('yt-1-fp', 250, manual: true);
      final offset = await cacheDao.getLyricOffset('yt-1-fp');
      expect(offset?.ms, 250);
      expect(offset?.manual, isTrue);
    });
  });
}
