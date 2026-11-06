import 'dart:async';
import 'dart:collection';

import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/data/models/ai_mix_playlist.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/artist_page.dart';
import 'package:awady_music/data/models/mood_models.dart';
import 'package:awady_music/data/models/playlist_page.dart';
import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/search_results.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/sources/audius/audius_client.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:awady_music/data/sources/innertube/matcher.dart';

export 'package:awady_music/data/models/ai_mix_playlist.dart';

/// A [List] implementation that retains an optional [fromFallback]
/// metadata flag.
class CatalogList<E> extends ListBase<E> {
  CatalogList(this.items, {this.fromFallback = false});

  final List<E> items;
  final bool fromFallback;

  @override
  int get length => items.length;

  @override
  set length(int newLength) => items.length = newLength;

  @override
  E operator [](int index) => items[index];

  @override
  void operator []=(int index, E value) => items[index] = value;
}

/// Unified catalog repository bridging YouTube Music (Innertube) and Audius.
abstract interface class CatalogRepository {
  Future<SearchResults> search(String q);

  Future<List<String>> suggest(String q);

  Future<ArtistPage> artist(String channelId, {String? nameHint});

  Future<PlaylistPage> album(String browseId);

  Future<PlaylistPage> playlist(String browseId);

  Future<CatalogList<RemotePlaylist>> homePlaylists();

  Future<CatalogList<Track>> trending();

  Future<CatalogList<Track>> charts();

  Future<CatalogList<RemotePlaylist>> newReleases();

  Future<List<MoodCategory>> moods();

  Future<MoodPageData> mood(String params);

  Future<List<Track>> upNext(String videoId, {int limit = 40});

  Future<List<Track?>> match(List<MatchQuery> items);

  Future<CatalogList<Track>> recommendedFromLikes(
    List<Track> likedTracks, {
    List<Artist> followedArtists = const [],
    List<Track> recentTracks = const [],
  });

  Future<List<AiMixPlaylist>> aiMixesFromLikes(
    List<Track> likedTracks, {
    List<Artist> followedArtists = const [],
  });
}

/// Implementation of [CatalogRepository] with automatic Audius fallback.
class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl({
    required this.innertubeClient,
    required this.audiusClient,
  });

  final InnertubeClient innertubeClient;
  final AudiusClient audiusClient;

  @override
  Future<SearchResults> search(String q) async {
    final query = q.trim();
    if (query.isEmpty) {
      return const SearchResults();
    }

    if (!query.startsWith('audius:')) {
      try {
        final ytResults = await innertubeClient.search(query);
        if (ytResults.tracks.isNotEmpty ||
            ytResults.artists.isNotEmpty ||
            ytResults.playlists.isNotEmpty) {
          return ytResults;
        }
      } on Object catch (e) {
        Log.w(
          'Innertube search failed for "$query", falling back to Audius: $e',
        );
      }
    }

    final cleanQuery = query.startsWith('audius:')
        ? query.substring(7).trim()
        : query;

    try {
      final results = await Future.wait([
        audiusClient.searchTracks(cleanQuery),
        audiusClient.searchUsers(cleanQuery),
        audiusClient.searchPlaylists(cleanQuery),
      ]);

      final tracks = results[0] as List<Track>;
      final artists = results[1] as List<dynamic>;
      final playlists = results[2] as List<RemotePlaylist>;

      Object? top;
      if (tracks.isNotEmpty) {
        top = tracks.first;
      } else if (artists.isNotEmpty) {
        top = artists.first;
      } else if (playlists.isNotEmpty) {
        top = playlists.first;
      }

      return SearchResults(
        top: top,
        songs: tracks,
        artists: artists.cast(),
        playlists: playlists,
        fromFallback: true,
      );
    } on Object catch (e) {
      Log.w('Audius search fallback failed for "$cleanQuery": $e');
      return const SearchResults(fromFallback: true);
    }
  }

  @override
  Future<List<String>> suggest(String q) async {
    try {
      return await innertubeClient.suggest(q);
    } on Object catch (e) {
      Log.w('Suggest failed for "$q": $e');
      return const [];
    }
  }

  @override
  Future<ArtistPage> artist(String channelId, {String? nameHint}) async {
    final cleanId = channelId
        .replaceFirst(RegExp('^yt-'), '')
        .replaceFirst(RegExp('^MPLA'), '')
        .trim();
    final isYtChannel =
        channelId.startsWith('yt-') ||
        cleanId.startsWith('UC') ||
        cleanId.startsWith('MPRE');

    if (isYtChannel) {
      try {
        return await innertubeClient.artist(channelId, nameHint: nameHint);
      } on Object catch (e) {
        Log.w(
          'Innertube artist failed for $channelId ($nameHint), '
          'falling back to Audius: $e',
        );
      }
    }

    try {
      Artist? user;
      if (!isYtChannel) {
        try {
          user = await audiusClient.user(channelId);
        } on Object catch (e) {
          Log.w('Audius direct user lookup failed for $channelId: $e');
        }
      }

      if (user == null && !isYtChannel) {
        try {
          return await innertubeClient.artist(channelId, nameHint: nameHint);
        } on Object catch (e) {
          Log.w('Innertube artist lookup failed for $channelId: $e');
        }
      }

      if (user == null) {
        final searchQuery = (nameHint != null && nameHint.trim().isNotEmpty)
            ? nameHint.trim()
            : (!cleanId.startsWith('UC') ? cleanId : '');
        if (searchQuery.isNotEmpty) {
          final searchHits = await audiusClient.searchUsers(searchQuery);
          if (searchHits.isNotEmpty) {
            user = searchHits.first;
          }
        }
      }

      if (user != null) {
        final tracksFuture = audiusClient.userTracks(user.id);
        final albumsFuture = audiusClient.userAlbums(user.id);

        final tracks = await tracksFuture;
        final albums = await albumsFuture;

        return ArtistPage(
          artist: user,
          topSongs: tracks,
          albums: albums.where((a) => a.isAlbum).toList(),
          singles: albums.where((a) => !a.isAlbum).toList(),
          bio: user.bio,
          fromFallback: true,
        );
      }
    } on Object catch (e) {
      Log.w('Audius artist fallback failed for $channelId: $e');
    }

    throw StateError('Artist not found for $channelId');
  }

  @override
  Future<PlaylistPage> album(String browseId) async {
    final cleanId = browseId.replaceFirst(RegExp('^(ytalb-|ytpl-|yt-)'), '');
    final isYtBrowse =
        browseId.startsWith('ytalb-') ||
        browseId.startsWith('ytpl-') ||
        cleanId.startsWith('MPRE') ||
        cleanId.startsWith('VL') ||
        cleanId.startsWith('PL') ||
        cleanId.startsWith('RD') ||
        cleanId.startsWith('OLAK');

    if (isYtBrowse) {
      try {
        return await innertubeClient.album(browseId);
      } on Object catch (e) {
        Log.w(
          'Innertube album failed for $browseId, falling back to Audius: $e',
        );
      }
    }

    try {
      final pl = await audiusClient.playlist(browseId);
      if (pl != null) {
        final tracks = await audiusClient.playlistTracks(browseId);
        return PlaylistPage(playlist: pl, tracks: tracks, fromFallback: true);
      }
    } on Object catch (e) {
      Log.w('Audius album fallback failed for $browseId: $e');
    }

    throw StateError('Album not found for $browseId');
  }

  @override
  Future<PlaylistPage> playlist(String browseId) async {
    final cleanId = browseId.replaceFirst(RegExp('^(ytpl-|ytalb-|yt-)'), '');
    final isYtPlaylist =
        browseId.startsWith('ytpl-') ||
        browseId.startsWith('ytalb-') ||
        cleanId.startsWith('VL') ||
        cleanId.startsWith('PL') ||
        cleanId.startsWith('RD') ||
        cleanId.startsWith('OLAK') ||
        cleanId.startsWith('MPRE');

    if (isYtPlaylist) {
      try {
        return await innertubeClient.playlist(browseId);
      } on Object catch (e) {
        Log.w(
          'Innertube playlist failed for $browseId, falling back to Audius: $e',
        );
      }
    }

    try {
      final pl = await audiusClient.playlist(browseId);
      if (pl != null) {
        final tracks = await audiusClient.playlistTracks(browseId);
        return PlaylistPage(playlist: pl, tracks: tracks, fromFallback: true);
      }
    } on Object catch (e) {
      Log.w('Audius playlist fallback failed for $browseId: $e');
    }

    throw StateError('Playlist not found for $browseId');
  }

  @override
  Future<CatalogList<RemotePlaylist>> homePlaylists() async {
    try {
      final ytPlaylists = await innertubeClient.homePlaylists();
      if (ytPlaylists.isNotEmpty) {
        return CatalogList(ytPlaylists);
      }
    } on Object catch (e) {
      Log.w('Innertube homePlaylists failed, falling back to Audius: $e');
    }

    try {
      final audiusPlaylists = await audiusClient.trendingPlaylists(
        type: 'playlist',
      );
      return CatalogList(audiusPlaylists, fromFallback: true);
    } on Object catch (e) {
      Log.w('Audius homePlaylists fallback failed: $e');
      return CatalogList(const [], fromFallback: true);
    }
  }

  @override
  Future<CatalogList<Track>> trending() async {
    try {
      final ytTrending = await innertubeClient.trending();
      if (ytTrending.isNotEmpty) {
        return CatalogList(ytTrending);
      }
    } on Object catch (e) {
      Log.w('Innertube trending failed, falling back to Audius: $e');
    }

    try {
      final audiusTrending = await audiusClient.trendingTracks(time: 'week');
      return CatalogList(audiusTrending, fromFallback: true);
    } on Object catch (e) {
      Log.w('Audius trending fallback failed: $e');
      return CatalogList(const [], fromFallback: true);
    }
  }

  @override
  Future<CatalogList<Track>> charts() async {
    try {
      final ytCharts = await innertubeClient.charts();
      if (ytCharts.isNotEmpty) {
        return CatalogList(ytCharts);
      }
    } on Object catch (e) {
      Log.w('Innertube charts failed, falling back to Audius: $e');
    }

    try {
      final audiusCharts = await audiusClient.trendingTracks(time: 'week');
      return CatalogList(audiusCharts, fromFallback: true);
    } on Object catch (e) {
      Log.w('Audius charts fallback failed: $e');
      return CatalogList(const [], fromFallback: true);
    }
  }

  @override
  Future<CatalogList<RemotePlaylist>> newReleases() async {
    try {
      final ytNew = await innertubeClient.newReleases();
      if (ytNew.isNotEmpty) {
        return CatalogList(ytNew);
      }
    } on Object catch (e) {
      Log.w('Innertube newReleases failed, falling back to Audius: $e');
    }

    try {
      final audiusNew = await audiusClient.trendingPlaylists(
        type: 'album',
        time: 'week',
      );
      return CatalogList(audiusNew, fromFallback: true);
    } on Object catch (e) {
      Log.w('Audius newReleases fallback failed: $e');
      return CatalogList(const [], fromFallback: true);
    }
  }

  @override
  Future<List<MoodCategory>> moods() => innertubeClient.moods();

  @override
  Future<MoodPageData> mood(String params) => innertubeClient.mood(params);

  @override
  Future<List<Track>> upNext(String videoId, {int limit = 40}) =>
      innertubeClient.upNext(videoId, limit: limit);

  @override
  Future<List<Track?>> match(List<MatchQuery> items) =>
      innertubeClient.match(items);

  @override
  Future<CatalogList<Track>> recommendedFromLikes(
    List<Track> likedTracks, {
    List<Artist> followedArtists = const [],
    List<Track> recentTracks = const [],
  }) async {
    final seedTracks = <Track>[
      ...likedTracks.take(3),
      if (likedTracks.length < 2) ...recentTracks.take(2),
    ];

    final artistCounts = <String, ({Artist artist, int score})>{};
    for (final a in followedArtists) {
      final key = a.name.trim().toLowerCase();
      if (key.isEmpty || key == 'unknown artist') continue;
      final prev = artistCounts[key];
      artistCounts[key] = (artist: a, score: (prev?.score ?? 0) + 3);
    }
    for (final t in likedTracks) {
      final key = t.artist.name.trim().toLowerCase();
      if (key.isEmpty || key == 'unknown artist') continue;
      final prev = artistCounts[key];
      artistCounts[key] = (artist: t.artist, score: (prev?.score ?? 0) + 2);
    }
    for (final t in recentTracks.take(5)) {
      final key = t.artist.name.trim().toLowerCase();
      if (key.isEmpty || key == 'unknown artist') continue;
      final prev = artistCounts[key];
      artistCounts[key] = (artist: t.artist, score: (prev?.score ?? 0) + 1);
    }

    final sortedArtists = artistCounts.values.toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    final topArtists = sortedArtists.take(3).map((e) => e.artist).toList();

    final buckets = <List<Track>>[];
    final futures = <Future<List<Track>>>[];

    var ytSeedCount = 0;
    for (final seed in seedTracks) {
      final vid =
          seed.streamId ??
          (seed.id.startsWith('yt-') ? seed.id.substring(3) : '');
      if (vid.isNotEmpty && ytSeedCount < 2) {
        ytSeedCount++;
        futures.add(
          upNext(vid, limit: 12).catchError((Object _) => const <Track>[]),
        );
      }
    }

    for (final artist in topArtists.take(2)) {
      futures.add(
        search(artist.name)
            .then((res) => res.songs)
            .catchError((Object _) => const <Track>[]),
      );
    }

    if (futures.isEmpty) {
      return CatalogList(const []);
    }

    final resolved = await Future.wait(futures);
    for (final list in resolved) {
      if (list.isNotEmpty) {
        buckets.add(list);
      }
    }

    final likedIds = likedTracks.map((t) => t.id).toSet();
    final fresh = <Track>[];
    final familiar = <Track>[];
    final seen = <String>{};

    var maxLen = 0;
    for (final b in buckets) {
      if (b.length > maxLen) maxLen = b.length;
    }

    for (var i = 0; i < maxLen; i++) {
      for (final b in buckets) {
        if (i < b.length) {
          final track = b[i];
          if (seen.add(track.id)) {
            if (likedIds.contains(track.id)) {
              familiar.add(track);
            } else {
              fresh.add(track);
            }
          }
        }
      }
    }

    final combined = [...fresh, ...familiar];
    return CatalogList(
      combined.length > 24 ? combined.sublist(0, 24) : combined,
    );
  }

  @override
  Future<List<AiMixPlaylist>> aiMixesFromLikes(
    List<Track> likedTracks, {
    List<Artist> followedArtists = const [],
  }) async {
    if (likedTracks.isEmpty) return const [];

    final likedSet = likedTracks.map((t) => t.id).toSet();
    final mixes = <AiMixPlaylist>[];

    Future<List<Track>> getSuggestions(Track seed, int count) async {
      final vid =
          seed.streamId ??
          (seed.id.startsWith('yt-') ? seed.id.substring(3) : '');
      if (vid.isNotEmpty) {
        try {
          final res = await upNext(vid, limit: count + 8);
          final filtered = res
              .where((t) => !likedSet.contains(t.id))
              .take(count)
              .toList();
          if (filtered.isNotEmpty) return filtered;
        } on Object catch (_) {}
      }
      try {
        final res = await search(seed.artist.name);
        return res.songs
            .where((t) => !likedSet.contains(t.id))
            .take(count)
            .toList();
      } on Object catch (_) {
        return const [];
      }
    }

    // 1. Overall Mix: All Likes AI Mix
    final overallHalf = (likedTracks.length / 2).ceil();
    final overallFirst = likedTracks.take(overallHalf).toList();
    final overallSecond = likedTracks.skip(overallHalf).toList();
    final overallSuggested = await getSuggestions(likedTracks.first, 8);
    final overallTracks = [
      ...overallFirst,
      ...overallSuggested,
      ...overallSecond,
    ];
    mixes.add(
      AiMixPlaylist(
        id: 'ai-mix-overall',
        title: 'All Likes AI Mix',
        subtitle: 'Your liked tracks + fresh discoveries woven in the middle',
        badge: 'Overall Mix',
        category: 'All Likes',
        tracks: overallTracks,
        suggestedTrackIds: overallSuggested.map((t) => t.id).toSet(),
      ),
    );

    // 2. Partition by category/genre/artist for Mix 1, Mix 2, Mix 3
    final arabicTracks = likedTracks.where((t) {
      final text = '${t.title} ${t.artist.name}';
      return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    }).toList();
    final nonArabicTracks = likedTracks.where((t) {
      final text = '${t.title} ${t.artist.name}';
      return !RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    }).toList();

    final categories = <String, List<Track>>{};
    if (arabicTracks.isNotEmpty) {
      categories['Arabic & Tarab'] = arabicTracks;
    }
    final artistGroups = <String, List<Track>>{};
    for (final t in (categories.isEmpty ? likedTracks : nonArabicTracks)) {
      artistGroups.putIfAbsent(t.artist.name, () => []).add(t);
    }
    final sortedArtistGroups = artistGroups.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    for (final entry in sortedArtistGroups) {
      if (categories.length >= 3) break;
      categories['${entry.key} & Similar'] = entry.value;
    }

    if (categories.length < 3 && likedTracks.length >= 4) {
      final chill = likedTracks.where((t) => t.duration >= 220).toList();
      final upbeat = likedTracks.where((t) => t.duration < 220).toList();
      if (chill.isNotEmpty && !categories.containsKey('Chill & Slow')) {
        categories['Chill & Slow'] = chill;
      }
      if (categories.length < 3 &&
          upbeat.isNotEmpty &&
          !categories.containsKey('Upbeat Energy')) {
        categories['Upbeat Energy'] = upbeat;
      }
    }

    var mixIndex = 1;
    for (final entry in categories.entries) {
      if (mixIndex > 3) break;
      final catTracks = entry.value;
      final catHalf = (catTracks.length / 2).ceil();
      final catFirst = catTracks.take(catHalf).toList();
      final catSecond = catTracks.skip(catHalf).toList();
      final catSuggested = await getSuggestions(catTracks.first, 6);
      final woven = [...catFirst, ...catSuggested, ...catSecond];

      mixes.add(
        AiMixPlaylist(
          id: 'ai-mix-$mixIndex',
          title: '${entry.key} Mix',
          subtitle:
              '${entry.value.length} liked · '
              '${catSuggested.length} suggested in middle',
          badge: 'Mix $mixIndex',
          category: entry.key,
          tracks: woven,
          suggestedTrackIds: catSuggested.map((t) => t.id).toSet(),
        ),
      );
      mixIndex++;
    }

    return mixes;
  }
}
