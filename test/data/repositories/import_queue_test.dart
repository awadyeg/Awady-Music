import 'package:awady_music/data/db/app_database.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/local_playlist.dart';
import 'package:awady_music/data/models/search_results.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/import_queue.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLibraryRepository extends Fake implements LibraryRepository {
  List<LocalPlaylist> _playlistsList = [];
  final Map<String, Track> resolved = {};
  final List<String> dropped = [];

  @override
  List<LocalPlaylist> get playlists => _playlistsList;

  @override
  void resolveTracks(Map<String, Track> hits) {
    resolved.addAll(hits);
  }

  @override
  void dropTracks(List<String> ids) {
    dropped.addAll(ids);
  }
}

class _FakeInnertubeClient extends Fake implements InnertubeClient {
  final Map<String, List<Track>> searchHits = {};

  @override
  Future<SearchResults> search(String query) async {
    final hits = searchHits[query] ?? const [];
    return SearchResults(songs: hits);
  }
}

void main() {
  late AppDatabase db;
  late _FakeLibraryRepository libraryRepo;
  late _FakeInnertubeClient innertube;
  late ImportQueue queue;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    libraryRepo = _FakeLibraryRepository();
    innertube = _FakeInnertubeClient();
    queue = ImportQueue(
      libraryRepo: libraryRepo,
      innertubeClient: innertube,
      db: db,
    );
  });

  tearDown(() async {
    queue.dispose();
    await db.close();
  });

  const pendingTrack1 = Track(
    id: 'placeholder-1',
    title: 'Hello',
    artist: Artist(id: 'adele', name: 'Adele'),
    duration: 300,
    source: TrackSource.yt,
    pending: true,
  );

  const pendingTrack2 = Track(
    id: 'placeholder-2',
    title: 'Easy On Me',
    artist: Artist(id: 'adele', name: 'Adele'),
    duration: 224,
    source: TrackSource.yt,
    pending: true,
  );

  const realHit1 = Track(
    id: 'yt-real-1',
    title: 'Hello',
    artist: Artist(id: 'adele', name: 'Adele'),
    duration: 300,
    source: TrackSource.yt,
  );

  const realHit2 = Track(
    id: 'yt-real-2',
    title: 'Easy On Me',
    artist: Artist(id: 'adele', name: 'Adele'),
    duration: 224,
    source: TrackSource.yt,
  );

  group('ImportQueue', () {
    test('enqueues pending tracks and resolves them via Innertube', () async {
      innertube.searchHits['Adele Hello'] = [realHit1];
      innertube.searchHits['Adele Easy On Me'] = [realHit2];

      queue.enqueuePending('playlist-1', [pendingTrack1, pendingTrack2]);

      // Wait for pump to process
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(libraryRepo.resolved.containsKey('placeholder-1'), isTrue);
      expect(libraryRepo.resolved['placeholder-1']!.id, 'yt-real-1');
      expect(libraryRepo.resolved.containsKey('placeholder-2'), isTrue);
      expect(libraryRepo.resolved['placeholder-2']!.id, 'yt-real-2');
      expect(queue.currentProgress.isEmpty, isTrue);
    });

    test(
      'caches matches in database and uses cache on subsequent calls',
      () async {
        innertube.searchHits['Adele Hello'] = [realHit1];

        queue.enqueuePending('playlist-1', [pendingTrack1]);
        await Future<void>.delayed(const Duration(milliseconds: 300));

        // Verify cached in database
        final key = ImportQueue.cacheKey('Hello', 'Adele', 300);
        final cachedJson = await db.cacheDao.getSongMatch(key);
        expect(cachedJson, isNotNull);
        expect(cachedJson!.contains('yt-real-1'), isTrue);

        // Now clear innertube hits - resolving again should hit cache!
        innertube.searchHits.clear();
        libraryRepo.resolved.clear();

        queue.enqueuePending('playlist-2', [pendingTrack1]);
        await Future<void>.delayed(const Duration(milliseconds: 300));

        expect(libraryRepo.resolved.containsKey('placeholder-1'), isTrue);
        expect(libraryRepo.resolved['placeholder-1']!.id, 'yt-real-1');
      },
    );

    test('drops dead tracks when no match found after retries', () async {
      // Innertube returns no hits
      queue.enqueuePending('playlist-1', [pendingTrack1]);
      await Future<void>.delayed(const Duration(milliseconds: 400));

      expect(libraryRepo.dropped.contains('placeholder-1'), isTrue);
    });

    test('resolveNow resolves track immediately '
        'out-of-band and removes from queue', () async {
      innertube.searchHits['Adele Hello'] = [realHit1];

      queue.enqueuePending('playlist-1', [pendingTrack1, pendingTrack2]);
      final hit = await queue.resolveNow(pendingTrack1);

      expect(hit, isNotNull);
      expect(hit!.id, 'yt-real-1');
      expect(libraryRepo.resolved['placeholder-1']!.id, 'yt-real-1');
    });

    test(
      'resumePending enqueues pending tracks from library playlists',
      () async {
        innertube.searchHits['Adele Hello'] = [realHit1];

        libraryRepo._playlistsList = [
          LocalPlaylist(
            id: 'p1',
            name: 'My Playlist',
            tracks: const [pendingTrack1],
            createdAt: DateTime.now(),
          ),
        ];

        queue.resumePending();
        expect(queue.queuedCount, 1);

        await Future<void>.delayed(const Duration(milliseconds: 300));
        expect(libraryRepo.resolved.containsKey('placeholder-1'), isTrue);
      },
    );
  });
}
