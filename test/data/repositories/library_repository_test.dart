import 'dart:convert';

import 'package:awady_music/data/db/app_database.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

Track mkTrack(
  String id, {
  String? title,
  String? artistName,
  int duration = 200,
}) {
  return Track(
    id: id,
    title: title ?? 'Song $id',
    duration: duration,
    artist: Artist(id: 'u_$id', name: artistName ?? 'Artist $id'),
  );
}

void main() {
  group('LibraryRepository (ported from library.test.ts)', () {
    late LibraryRepository repo;

    setUp(() {
      repo = LibraryRepositoryImpl();
    });

    group('toggleLike', () {
      test('adds then removes a track', () {
        final t = mkTrack('t1');
        repo.toggleLike(t);
        expect(repo.isLiked('t1'), isTrue);
        expect(repo.likedTracks.length, equals(1));
        expect(repo.likedTracks.first.id, equals('t1'));

        repo.toggleLike(t);
        expect(repo.isLiked('t1'), isFalse);
        expect(repo.likedTracks, isEmpty);
        expect(repo.likedOrder, isEmpty);
      });

      test('keeps likedOrder deduped and newest-first', () {
        repo
          ..toggleLike(mkTrack('t1'))
          ..toggleLike(mkTrack('t2'))
          ..toggleLike(mkTrack('t3'));
        expect(repo.likedOrder, equals(['t3', 't2', 't1']));

        // Re-liking after remove puts it back on top, never duplicated
        repo
          ..toggleLike(mkTrack('t1'))
          ..toggleLike(mkTrack('t1'));
        expect(repo.likedOrder, equals(['t1', 't3', 't2']));
        expect(repo.likedOrder.length, equals(3));
      });
    });

    group('playlists', () {
      test("auto-names 'My Playlist #N' with the lowest free N", () {
        final first = repo.createPlaylist();
        final second = repo.createPlaylist();
        List<String> names() => repo.playlists.map((p) => p.name).toList();

        expect(names(), equals(['My Playlist #2', 'My Playlist #1']));

        repo
          ..deletePlaylist(first)
          ..createPlaylist();

        // #1 was freed by the delete - reused instead of climbing to #3
        expect(names(), equals(['My Playlist #1', 'My Playlist #2']));
        expect(
          repo.playlists.firstWhere((p) => p.id == second).name,
          equals('My Playlist #2'),
        );
      });

      test('uses an explicit name when given one', () {
        repo.createPlaylist('  Gym Mix  ');
        expect(repo.playlists.first.name, equals('Gym Mix'));
      });

      test('addToPlaylist dedupes by track.id', () {
        final id = repo.createPlaylist('P');
        repo
          ..addToPlaylist(id, mkTrack('t1'))
          ..addToPlaylist(id, mkTrack('t1', title: 'Same id, new title'))
          ..addToPlaylist(id, mkTrack('t2'));

        final tracks = repo.playlists.first.tracks;
        expect(tracks.map((t) => t.id).toList(), equals(['t1', 't2']));
        expect(tracks[0].title, equals('Song t1'));
      });

      test('addTracksToPlaylist bulk-dedupes against existing tracks', () {
        final id = repo.createPlaylist('P');
        repo
          ..addToPlaylist(id, mkTrack('t1'))
          ..addTracksToPlaylist(id, [
            mkTrack('t1'),
            mkTrack('t2'),
            mkTrack('t3'),
            mkTrack('t2'), // In-list duplicate
          ]);

        final tracks = repo.playlists.first.tracks;
        expect(tracks.map((t) => t.id).toList(), equals(['t1', 't2', 't3']));
      });

      test('moveInPlaylist reorders and ignores out-of-bounds moves', () {
        final id = repo.createPlaylist('P');
        repo
          ..addTracksToPlaylist(id, [mkTrack('a'), mkTrack('b'), mkTrack('c')])
          ..moveInPlaylist(id, 0, 2)
          ..moveInPlaylist(id, 0, 9);
        expect(
          repo.playlists.first.tracks.map((t) => t.id).toList(),
          equals(['b', 'c', 'a']),
        );
      });

      test('removeFromPlaylist removes the track', () {
        final id = repo.createPlaylist('P');
        repo
          ..addTracksToPlaylist(id, [mkTrack('a'), mkTrack('b')])
          ..removeFromPlaylist(id, 'a');

        expect(
          repo.playlists.first.tracks.map((t) => t.id).toList(),
          equals(['b']),
        );
      });

      test('renamePlaylist renames, deletePlaylist deletes', () {
        final id = repo.createPlaylist();
        repo
          ..renamePlaylist(id, 'Renamed')
          ..deletePlaylist(id);
        expect(repo.playlists, isEmpty);
      });

      test('sortPlaylist sorts by title, artist, and duration', () {
        final id = repo.createPlaylist('Sort Test');
        repo
          ..addTracksToPlaylist(id, [
            mkTrack('1', title: 'Zebra', artistName: 'Adele', duration: 300),
            mkTrack('2', title: 'Apple', artistName: 'Zara', duration: 150),
            mkTrack('3', title: 'Mango', artistName: 'Bruno', duration: 240),
          ])
          ..sortPlaylist(id, PlaylistSortMode.title);
        expect(
          repo.playlists.first.tracks.map((t) => t.title).toList(),
          equals(['Apple', 'Mango', 'Zebra']),
        );

        repo.sortPlaylist(id, PlaylistSortMode.artist);
        expect(
          repo.playlists.first.tracks.map((t) => t.artist.name).toList(),
          equals(['Adele', 'Bruno', 'Zara']),
        );

        repo.sortPlaylist(id, PlaylistSortMode.duration);
        expect(
          repo.playlists.first.tracks.map((t) => t.duration).toList(),
          equals([150, 240, 300]),
        );
      });

      test('resolveTracks swaps placeholders in place preserving position', () {
        final id = repo.createPlaylist('Resolve Test');
        final resolvedP1 = mkTrack('p1', title: 'Resolved 1');
        final resolvedP2 = mkTrack('p2', title: 'Resolved 2');

        repo
          ..addTracksToPlaylist(id, [
            mkTrack('p1', title: 'Pending 1'),
            mkTrack('keep', title: 'Keep'),
            mkTrack('p2', title: 'Pending 2'),
          ])
          ..resolveTracks({
            'p1': resolvedP1,
            'p2': resolvedP2,
            'unrelated': mkTrack('unrelated'),
          });

        final tracks = repo.playlists.first.tracks;
        expect(tracks[0].title, equals('Resolved 1'));
        expect(tracks[1].title, equals('Keep'));
        expect(tracks[2].title, equals('Resolved 2'));
      });

      test('dropTracks removes unresolvable tracks', () {
        final id = repo.createPlaylist('Drop Test');
        repo
          ..addTracksToPlaylist(id, [
            mkTrack('a'),
            mkTrack('bad1'),
            mkTrack('b'),
            mkTrack('bad2'),
          ])
          ..dropTracks(['bad1', 'bad2', 'nonexistent']);
        expect(
          repo.playlists.first.tracks.map((t) => t.id).toList(),
          equals(['a', 'b']),
        );
      });

      test('playlistExportJson generates valid .freebify.json structure', () {
        final id = repo.createPlaylist('Export Me');
        repo.addTracksToPlaylist(id, [
          mkTrack(
            't1',
            title: 'First Song',
            artistName: 'Singer 1',
            duration: 210,
          ),
        ]);

        final pl = repo.playlists.first;
        final jsonStr = playlistExportJson(pl);
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

        expect(decoded['app'], equals('freebify'));
        expect(decoded['type'], equals('playlist'));
        expect(decoded['version'], equals(1));
        expect(decoded['name'], equals('Export Me'));
        expect(decoded['tracks'] is List, isTrue);

        final trackItem =
            (decoded['tracks'] as List).first as Map<String, dynamic>;
        expect(trackItem['title'], equals('First Song'));
        expect(trackItem['artist'], equals('Singer 1'));
        expect(trackItem['duration'], equals(210));
      });
    });

    group('addRecent', () {
      test('dedupes by id and keeps newest first, capped at 50', () {
        repo
          ..addRecent(mkTrack('a'))
          ..addRecent(mkTrack('b'))
          ..addRecent(mkTrack('a'));
        expect(repo.recents.map((t) => t.id).toList(), equals(['a', 'b']));

        // Add 60 tracks
        for (var i = 0; i < 60; i++) {
          repo.addRecent(mkTrack('r$i'));
        }
        expect(repo.recents.length, equals(50));
        expect(repo.recents.first.id, equals('r59'));
      });
    });

    group('toggleFollow', () {
      test('follows and unfollows artists, newest first, capped at 500', () {
        const a1 = Artist(id: 'art1', name: 'Adele');
        const a2 = Artist(id: 'art2', name: 'Sia');

        repo.toggleFollow(a1);
        expect(repo.isFollowing('art1'), isTrue);
        expect(repo.followedArtists.length, equals(1));
        expect(repo.followedArtists.first.name, equals('Adele'));

        repo.toggleFollow(a2);
        expect(
          repo.followedArtists.map((a) => a.id).toList(),
          equals(['art2', 'art1']),
        );

        repo.toggleFollow(a1);
        expect(repo.isFollowing('art1'), isFalse);
        expect(
          repo.followedArtists.map((a) => a.id).toList(),
          equals(['art2']),
        );
      });
    });

    group('database persistence and hydration', () {
      test('hydrates state from SQLite database on init()', () async {
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);

        final repo1 = LibraryRepositoryImpl(db: db);
        final pid = repo1.createPlaylist('Persisted Playlist');
        repo1
          ..toggleLike(mkTrack('t1', title: 'Song One'))
          ..addRecent(mkTrack('r1', title: 'Recent One'))
          ..toggleFollow(const Artist(id: 'u1', name: 'Artist One'))
          ..addToPlaylist(pid, mkTrack('pt1', title: 'Playlist Track 1'));

        // Allow unawaited DB transactions to complete
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Create second repo instance pointing to the same DB and hydrate
        final repo2 = LibraryRepositoryImpl(db: db);
        await repo2.init();

        expect(repo2.isLiked('t1'), isTrue);
        expect(repo2.likedTracks.first.title, equals('Song One'));
        expect(repo2.recents.first.title, equals('Recent One'));
        expect(repo2.isFollowing('u1'), isTrue);
        expect(repo2.playlists.length, equals(1));
        expect(repo2.playlists.first.name, equals('Persisted Playlist'));
        expect(repo2.playlists.first.tracks.length, equals(1));
        expect(
          repo2.playlists.first.tracks.first.title,
          equals('Playlist Track 1'),
        );
      });
    });
  });
}
