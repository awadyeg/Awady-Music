import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/artist_page.dart';
import 'package:awady_music/data/models/playlist_page.dart';
import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/search_results.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/catalog_providers.dart';
import 'package:awady_music/data/repositories/catalog_repository.dart';
import 'package:awady_music/data/sources/audius/audius_client.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:awady_music/data/sources/innertube/matcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeInnertubeClient extends InnertubeClient {
  bool shouldThrow = false;
  SearchResults searchResults = const SearchResults();
  ArtistPage? artistPage;
  PlaylistPage? albumPage;
  PlaylistPage? playlistPage;
  List<RemotePlaylist> homePlaylistsData = const [];
  List<Track> trendingData = const [];
  List<Track> chartsData = const [];
  List<RemotePlaylist> newReleasesData = const [];

  @override
  Future<SearchResults> search(String q) async {
    if (shouldThrow) throw Exception('YTM search down');
    return searchResults;
  }

  @override
  Future<ArtistPage> artist(String channelId, {String? nameHint}) async {
    if (shouldThrow) throw Exception('YTM artist down');
    return artistPage ??
        ArtistPage(
          artist: Artist(id: channelId, name: 'YT Artist'),
        );
  }

  @override
  Future<PlaylistPage> album(String browseId) async {
    if (shouldThrow) throw Exception('YTM album down');
    return albumPage ??
        PlaylistPage(
          playlist: RemotePlaylist(
            id: browseId,
            name: 'YT Album',
            owner: const Artist(id: 'a1', name: 'Art'),
          ),
        );
  }

  @override
  Future<PlaylistPage> playlist(String browseId) async {
    if (shouldThrow) throw Exception('YTM playlist down');
    return playlistPage ??
        PlaylistPage(
          playlist: RemotePlaylist(
            id: browseId,
            name: 'YT Playlist',
            owner: const Artist(id: 'a1', name: 'Art'),
          ),
        );
  }

  @override
  Future<List<RemotePlaylist>> homePlaylists() async {
    if (shouldThrow) throw Exception('YTM home down');
    return homePlaylistsData;
  }

  @override
  Future<List<Track>> trending() async {
    if (shouldThrow) throw Exception('YTM trending down');
    return trendingData;
  }

  @override
  Future<List<Track>> charts() async {
    if (shouldThrow) throw Exception('YTM charts down');
    return chartsData;
  }

  @override
  Future<List<RemotePlaylist>> newReleases({int limit = 20}) async {
    if (shouldThrow) throw Exception('YTM new releases down');
    return newReleasesData;
  }

  @override
  Future<List<Track?>> match(List<MatchQuery> items) async =>
      items.map((_) => null).toList();

  @override
  Future<List<Track>> upNext(String videoId, {int limit = 40}) async {
    if (shouldThrow) throw Exception('YTM upNext down');
    return trendingData;
  }
}

class _FakeAudiusClient implements AudiusClient {
  _FakeAudiusClient({
    this.tracks = const [],
    this.users = const [],
    this.playlists = const [],
  });

  List<Track> tracks;
  List<Artist> users;
  List<RemotePlaylist> playlists;

  @override
  Future<List<Track>> searchTracks(
    String query, {
    int limit = 40,
    int? offset,
  }) async => tracks;

  @override
  Future<List<Artist>> searchUsers(String query, {int limit = 12}) async =>
      users;

  @override
  Future<List<RemotePlaylist>> searchPlaylists(
    String query, {
    int limit = 12,
  }) async => playlists;

  @override
  Future<List<Track>> trendingTracks({
    String? genre,
    String? time,
    int? limit,
    int? offset,
  }) async => tracks;

  @override
  Future<List<RemotePlaylist>> trendingPlaylists({
    String? type,
    String? time,
    int? limit,
  }) async => playlists;

  @override
  Future<Artist?> user(String id) async =>
      users.firstWhere((u) => u.id == id, orElse: () => users.first);

  @override
  Future<List<Track>> userTracks(String id, {int limit = 50}) async => tracks;

  @override
  Future<List<RemotePlaylist>> userAlbums(String id) async => playlists;

  @override
  Future<RemotePlaylist?> playlist(String id) async =>
      playlists.firstWhere((p) => p.id == id, orElse: () => playlists.first);

  @override
  Future<List<Track>> playlistTracks(String id, {int limit = 100}) async =>
      tracks;

  @override
  Future<Track?> track(String id) async =>
      tracks.firstWhere((t) => t.id == id, orElse: () => tracks.first);

  @override
  String streamUrl(String trackId) => 'https://audius.co/stream/$trackId';

  @override
  void rotateHost() {}

  @override
  String get currentHost => 'https://api.audius.co';

  @override
  int get hostIndex => 0;

  @override
  List<String> get hosts => const ['https://api.audius.co'];
}

void main() {
  group('CatalogRepository with Innertube and Audius fallback', () {
    late _FakeInnertubeClient fakeYt;
    late _FakeAudiusClient fakeAudius;
    late CatalogRepository repo;

    setUp(() {
      fakeYt = _FakeInnertubeClient();
      fakeAudius = _FakeAudiusClient(
        tracks: [
          const Track(
            id: 'aud_track_1',
            title: 'Audius Hit',
            artist: Artist(id: 'aud_u1', name: 'Audius Singer'),
          ),
        ],
        users: [
          const Artist(
            id: 'aud_u1',
            name: 'Audius Singer',
            bio: 'Indie artist bio',
          ),
        ],
        playlists: [
          const RemotePlaylist(
            id: 'aud_p1',
            name: 'Audius Vibes',
            isAlbum: true,
            owner: Artist(id: 'aud_u1', name: 'Audius Singer'),
          ),
        ],
      );
      repo = CatalogRepositoryImpl(
        innertubeClient: fakeYt,
        audiusClient: fakeAudius,
      );
    });

    test('search returns YouTube results when available', () async {
      fakeYt.searchResults = const SearchResults(
        songs: [
          Track(
            id: 'yt1',
            title: 'YT Song',
            artist: Artist(id: 'y1', name: 'YT Singer'),
          ),
        ],
      );

      final res = await repo.search('adele');
      expect(res.fromFallback, isFalse);
      expect(res.tracks.length, equals(1));
      expect(res.tracks.first.title, equals('YT Song'));
    });

    test(
      'search falls back to Audius when Innertube fails or is empty',
      () async {
        fakeYt.shouldThrow = true;

        final res = await repo.search('indie vibes');
        expect(res.fromFallback, isTrue);
        expect(res.tracks.length, equals(1));
        expect(res.tracks.first.title, equals('Audius Hit'));
        expect(res.artists.length, equals(1));
        expect(res.artists.first.name, equals('Audius Singer'));
      },
    );

    test('search with audius: prefix forces Audius directly', () async {
      fakeYt.searchResults = const SearchResults(
        songs: [
          Track(
            id: 'yt1',
            title: 'YT Song',
            artist: Artist(id: 'y1', name: 'YT Singer'),
          ),
        ],
      );

      final res = await repo.search('audius:electronic');
      expect(res.fromFallback, isTrue);
      expect(res.tracks.first.title, equals('Audius Hit'));
    });

    test('artist returns YTM artist for UC channel id', () async {
      final res = await repo.artist('UC12345');
      expect(res.fromFallback, isFalse);
      expect(res.artist.name, equals('YT Artist'));
    });

    test(
      'artist returns YTM artist for prefixed yt-UC and yt-MPLA ids',
      () async {
        final res1 = await repo.artist('yt-UC12345');
        expect(res1.fromFallback, isFalse);
        expect(res1.artist.name, equals('YT Artist'));

        final res2 = await repo.artist('yt-MPLAUC12345');
        expect(res2.fromFallback, isFalse);
        expect(res2.artist.name, equals('YT Artist'));
      },
    );

    test(
      'album and playlist resolve prefixed ytalb- and ytpl- ids via YTM',
      () async {
        final alb = await repo.album('ytalb-MPREb_12345');
        expect(alb.fromFallback, isFalse);
        expect(alb.playlist.name, equals('YT Album'));

        final pl = await repo.playlist('ytpl-VLRDCLAK5uy_12345');
        expect(pl.fromFallback, isFalse);
        expect(pl.playlist.name, equals('YT Playlist'));
      },
    );

    test('artist falls back to Audius when YTM fails', () async {
      fakeYt.shouldThrow = true;

      final res = await repo.artist('UC12345', nameHint: 'Audius Singer');
      expect(res.fromFallback, isTrue);
      expect(res.artist.name, equals('Audius Singer'));
      expect(res.topSongs.length, equals(1));
      expect(res.albums.length, equals(1));
      expect(res.bio, equals('Indie artist bio'));
    });

    test('artist resolves Audius id directly', () async {
      final res = await repo.artist('aud_u1');
      expect(res.fromFallback, isTrue);
      expect(res.artist.name, equals('Audius Singer'));
      expect(res.topSongs.length, equals(1));
    });

    test('album falls back to Audius when YTM fails', () async {
      fakeYt.shouldThrow = true;

      final res = await repo.album('aud_p1');
      expect(res.fromFallback, isTrue);
      expect(res.playlist.name, equals('Audius Vibes'));
      expect(res.tracks.length, equals(1));
    });

    test('playlist falls back to Audius when YTM fails', () async {
      fakeYt.shouldThrow = true;

      final res = await repo.playlist('aud_p1');
      expect(res.fromFallback, isTrue);
      expect(res.playlist.name, equals('Audius Vibes'));
      expect(res.tracks.length, equals(1));
    });

    test(
      'homePlaylists, trending, charts, newReleases fallback to Audius',
      () async {
        fakeYt.shouldThrow = true;

        final home = await repo.homePlaylists();
        expect(home.fromFallback, isTrue);
        expect(home.length, equals(1));
        expect(home[0].name, equals('Audius Vibes'));

        final trending = await repo.trending();
        expect(trending.fromFallback, isTrue);
        expect(trending.length, equals(1));
        expect(trending[0].title, equals('Audius Hit'));

        final charts = await repo.charts();
        expect(charts.fromFallback, isTrue);
        expect(charts.length, equals(1));

        final releases = await repo.newReleases();
        expect(releases.fromFallback, isTrue);
        expect(releases.length, equals(1));
      },
    );

    test('CatalogList acts as standard list', () {
      final list = CatalogList<int>([10, 20, 30], fromFallback: true);
      expect(list.length, equals(3));
      expect(list[1], equals(20));
      expect(list.contains(30), isTrue);
      expect(list.map((x) => x * 2).toList(), equals([20, 40, 60]));
      expect(list.fromFallback, isTrue);
    });

    test('catalog_providers resolve via Riverpod container', () async {
      fakeYt
        ..trendingData = const [
          Track(
            id: 'yt1',
            title: 'YT Song',
            artist: Artist(id: 'y1', name: 'YT Singer'),
          ),
        ]
        ..searchResults = const SearchResults(
          songs: [
            Track(
              id: 'yt1',
              title: 'YT Song',
              artist: Artist(id: 'y1', name: 'YT Singer'),
            ),
          ],
        );

      final container = ProviderContainer(
        overrides: [catalogRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final trendingAsync = await container.read(trendingTracksProvider.future);
      expect(trendingAsync.fromFallback, isFalse);

      final searchAsync = await container.read(searchProvider('adele').future);
      expect(searchAsync.fromFallback, isFalse);

      final artistWithHint = await container.read(
        artistPageProvider('yt-UC12345\tAdele').future,
      );
      expect(artistWithHint.fromFallback, isFalse);
      expect(artistWithHint.artist.name, equals('YT Artist'));
    });

    test('recommendedFromLikes combines upNext and artist searches', () async {
      fakeYt
        ..trendingData = const [
          Track(
            id: 'yt-rec-1',
            title: 'Recommended Hit 1',
            artist: Artist(id: 'y1', name: 'Amr Diab'),
          ),
          Track(
            id: 'yt-liked-1',
            title: 'Already Liked Song',
            artist: Artist(id: 'y1', name: 'Amr Diab'),
          ),
        ]
        ..searchResults = const SearchResults(
          songs: [
            Track(
              id: 'yt-rec-2',
              title: 'Recommended Hit 2',
              artist: Artist(id: 'y2', name: 'Tamer Hosny'),
            ),
          ],
        );

      final res = await repo.recommendedFromLikes(
        const [
          Track(
            id: 'yt-liked-1',
            title: 'Already Liked Song',
            artist: Artist(id: 'y1', name: 'Amr Diab'),
          ),
        ],
        followedArtists: const [Artist(id: 'y2', name: 'Tamer Hosny')],
      );

      expect(res.fromFallback, isFalse);
      expect(res.length, greaterThanOrEqualTo(2));
      expect(res.first.id, equals('yt-rec-1'));
      expect(res.any((t) => t.id == 'yt-rec-2'), isTrue);
    });
  });
}
