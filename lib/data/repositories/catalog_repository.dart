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
import 'package:awady_music/data/sources/claude/claude_ai_client.dart';
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

  Future<List<Track>> similarToSearch(
    String query, {
    Track? seedTrack,
    List<Track>? excludeTracks,
  });
}

/// Implementation of [CatalogRepository] with automatic Audius fallback.
class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl({
    required this.innertubeClient,
    required this.audiusClient,
    this.claudeAiClient,
  });

  final InnertubeClient innertubeClient;
  final AudiusClient audiusClient;
  final ClaudeAiClient? claudeAiClient;

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
  Future<MoodPageData> mood(String params) async {
    if (params.startsWith('custom:')) {
      final rest = params.substring('custom:'.length);
      final parts = rest.split('|');
      final title = parts.first;
      final query = parts.length > 1 ? parts[1] : title;
      try {
        final res = await search(query);
        return MoodPageData(
          name: title,
          playlists: res.playlists,
          tracks: res.songs,
        );
      } on Object {
        return MoodPageData(name: title);
      }
    }

    final data = await innertubeClient.mood(params);
    if (data.tracks.isEmpty && data.playlists.isNotEmpty) {
      try {
        final query = data.name.isNotEmpty ? data.name : 'mood music';
        final res = await search(query);
        if (res.songs.isNotEmpty) {
          return MoodPageData(
            name: data.name,
            playlists: data.playlists,
            tracks: res.songs,
          );
        }
      } on Object {
        // Fall back to original data
      }
    }
    return data;
  }

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
    var claudeFuture = Future.value(const <Track>[]);
    if (claudeAiClient != null && claudeAiClient!.enabled) {
      claudeFuture = claudeAiClient!
          .suggestRecommendations(
            likedTracks: likedTracks,
            followedArtists: followedArtists,
            recentTracks: recentTracks,
          )
          .then((s) => resolveClaudeSuggestions(s, excludeIds: likedIds))
          .catchError((Object _) => const <Track>[]);
    }

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

    final claudeTracks = await claudeFuture;
    final combined = [...claudeTracks, ...fresh, ...familiar];
    final interleaved = interleaveByArtist(combined);
    return CatalogList(
      interleaved.length > 24 ? interleaved.sublist(0, 24) : interleaved,
    );
  }

  /// Normalizes an artist name for grouping and mixing.
  /// Lowercases, trims, and strips feat/collab/topic tokens.
  static String normalizeArtist(String name) {
    var cleaned = name.toLowerCase().trim();
    if (cleaned.isEmpty) return '';
    cleaned = cleaned
        .replaceAll(RegExp(r'\s*-\s*topic\b'), '')
        .replaceAll(RegExp(r'\s*official\b'), '')
        .replaceAll(RegExp(r'\s*vevo\b'), '');
    final splitIndex = cleaned.indexOf(
      RegExp(r'\s+(feat\.?|ft\.?|and|&|x)\s+|,\s*', caseSensitive: false),
    );
    if (splitIndex > 0) {
      cleaned = cleaned.substring(0, splitIndex);
    }
    return cleaned.trim();
  }

  /// Interleaves a list of tracks so that no two adjacent tracks share the
  /// same normalized artist name whenever another artist is available.
  static List<Track> interleaveByArtist(List<Track> tracks) {
    if (tracks.length <= 1) return tracks;

    // Deduplicate by track ID while maintaining first seen order
    final seenIds = <String>{};
    final unique = <Track>[];
    for (final t in tracks) {
      if (seenIds.add(t.id)) {
        unique.add(t);
      }
    }
    if (unique.length <= 1) return unique;

    // Group tracks by normalized artist key (preserving internal track order)
    final groups = <String, List<Track>>{};
    for (final t in unique) {
      final key = normalizeArtist(t.artist.name);
      groups.putIfAbsent(key, () => []).add(t);
    }

    final result = <Track>[];
    String? lastArtistKey;

    while (groups.isNotEmpty) {
      // Find candidate groups with artist != lastArtistKey
      final eligible = groups.entries
          .where((e) => e.key != lastArtistKey && e.value.isNotEmpty)
          .toList();

      if (eligible.isNotEmpty) {
        // Pick group with largest remaining count
        eligible.sort((a, b) => b.value.length.compareTo(a.value.length));
        final chosen = eligible.first;
        final track = chosen.value.removeAt(0);
        result.add(track);
        lastArtistKey = chosen.key;

        if (chosen.value.isEmpty) {
          groups.remove(chosen.key);
        }
      } else {
        // Only groups matching lastArtistKey remain
        final remainingTracks = <Track>[];
        groups.values.forEach(remainingTracks.addAll);
        groups.clear();

        // For each remaining track, try to insert into an earlier
        // non-adjacent slot
        for (final track in remainingTracks) {
          final key = normalizeArtist(track.artist.name);
          var inserted = false;
          for (var i = 0; i <= result.length; i++) {
            final prevKey = i > 0
                ? normalizeArtist(result[i - 1].artist.name)
                : null;
            final nextKey = i < result.length
                ? normalizeArtist(result[i].artist.name)
                : null;
            if (prevKey != key && nextKey != key) {
              result.insert(i, track);
              inserted = true;
              break;
            }
          }
          if (!inserted) {
            result.add(track);
          }
        }
        break;
      }
    }

    return result;
  }

  @override
  Future<List<AiMixPlaylist>> aiMixesFromLikes(
    List<Track> likedTracks, {
    List<Artist> followedArtists = const [],
  }) async {
    if (likedTracks.isEmpty) return const [];

    final likedSet = likedTracks.map((t) => t.id).toSet();
    final mixes = <AiMixPlaylist>[];

    Future<List<Track>> getDiverseSuggestions(
      List<Track> seeds,
      int count, {
      String? fallbackGenreQuery,
    }) async {
      final futures = <Future<List<Track>>>[];
      final distinctSeedArtists = <String>{};
      final chosenSeeds = <Track>[];

      for (final s in seeds) {
        final key = normalizeArtist(s.artist.name);
        if (key.isNotEmpty && distinctSeedArtists.add(key)) {
          chosenSeeds.add(s);
          if (chosenSeeds.length >= 3) break;
        }
      }

      for (final seed in chosenSeeds) {
        final vid =
            seed.streamId ??
            (seed.id.startsWith('yt-') ? seed.id.substring(3) : '');
        if (vid.isNotEmpty) {
          futures.add(
            upNext(vid, limit: 12)
                .then(
                  (res) => res.where((t) => !likedSet.contains(t.id)).toList(),
                )
                .catchError((Object _) => const <Track>[]),
          );
        } else {
          futures.add(
            search('${seed.artist.name} mix')
                .then(
                  (res) =>
                      res.songs.where((t) => !likedSet.contains(t.id)).toList(),
                )
                .catchError((Object _) => const <Track>[]),
          );
        }
      }

      if (followedArtists.isNotEmpty) {
        for (final fa in followedArtists) {
          final faKey = normalizeArtist(fa.name);
          if (faKey.isNotEmpty && distinctSeedArtists.add(faKey)) {
            futures.add(
              search('${fa.name} mix')
                  .then(
                    (res) => res.songs
                        .where((t) => !likedSet.contains(t.id))
                        .toList(),
                  )
                  .catchError((Object _) => const <Track>[]),
            );
            if (distinctSeedArtists.length >= 5) break;
          }
        }
      }

      if (fallbackGenreQuery != null && futures.length < 3) {
        futures.add(
          search(fallbackGenreQuery)
              .then(
                (res) =>
                    res.songs.where((t) => !likedSet.contains(t.id)).toList(),
              )
              .catchError((Object _) => const <Track>[]),
        );
      }

      if (claudeAiClient != null &&
          claudeAiClient!.enabled &&
          seeds.isNotEmpty) {
        futures.add(
          claudeAiClient!
              .suggestForMix(seedTracks: seeds, mixTheme: fallbackGenreQuery)
              .then((s) => resolveClaudeSuggestions(s, excludeIds: likedSet))
              .catchError((Object _) => const <Track>[]),
        );
      }

      if (futures.isEmpty && seeds.isNotEmpty) {
        futures.add(
          search(seeds.first.artist.name)
              .then(
                (res) =>
                    res.songs.where((t) => !likedSet.contains(t.id)).toList(),
              )
              .catchError((Object _) => const <Track>[]),
        );
      }

      final resolved = await Future.wait(futures);
      final rawCandidates = <Track>[];
      final artistCapped = <String, int>{};

      for (final list in resolved) {
        for (final track in list) {
          final aKey = normalizeArtist(track.artist.name);
          final current = artistCapped[aKey] ?? 0;
          if (current < 2) {
            artistCapped[aKey] = current + 1;
            rawCandidates.add(track);
          }
        }
      }

      final interleaved = interleaveByArtist(rawCandidates);
      return interleaved.length > count
          ? interleaved.sublist(0, count)
          : interleaved;
    }

    List<Track> weaveAndInterleave(List<Track> liked, List<Track> suggested) {
      if (suggested.isEmpty) return interleaveByArtist(liked);
      if (liked.isEmpty) return interleaveByArtist(suggested);

      final interleavedLiked = interleaveByArtist(liked);
      final interleavedSuggested = interleaveByArtist(suggested);

      final half = (interleavedLiked.length / 2).ceil();
      final firstHalf = interleavedLiked.take(half).toList();
      final secondHalf = interleavedLiked.skip(half).toList();
      final combined = [...firstHalf, ...interleavedSuggested, ...secondHalf];

      for (var i = 0; i < combined.length - 1; i++) {
        final a1 = normalizeArtist(combined[i].artist.name);
        final a2 = normalizeArtist(combined[i + 1].artist.name);
        if (a1 == a2) {
          var swapped = false;
          final afterTarget = (i + 2 < combined.length)
              ? normalizeArtist(combined[i + 2].artist.name)
              : null;
          for (var j = i + 2; j < combined.length; j++) {
            final cand = normalizeArtist(combined[j].artist.name);
            final prevCand = normalizeArtist(combined[j - 1].artist.name);
            final nextCand = (j + 1 < combined.length)
                ? normalizeArtist(combined[j + 1].artist.name)
                : null;
            if (cand != a1 &&
                cand != afterTarget &&
                prevCand != a1 &&
                nextCand != a1) {
              final temp = combined[i + 1];
              combined[i + 1] = combined[j];
              combined[j] = temp;
              swapped = true;
              break;
            }
          }
          if (!swapped) {
            return interleaveByArtist(combined);
          }
        }
      }

      return combined;
    }

    // 1. Overall Mix: All Likes AI Mix
    final overallSuggested = await getDiverseSuggestions(likedTracks, 8);
    final overallTracks = weaveAndInterleave(likedTracks, overallSuggested);
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

    // 2. Multi-artist category partitions
    final arabicTracks = likedTracks.where((t) {
      final text = '${t.title} ${t.artist.name}';
      return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    }).toList();
    final nonArabicTracks = likedTracks.where((t) {
      final text = '${t.title} ${t.artist.name}';
      return !RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    }).toList();
    final chillTracks = likedTracks.where((t) => t.duration >= 210).toList();
    final upbeatTracks = likedTracks
        .where((t) => t.duration > 0 && t.duration < 210)
        .toList();

    // Group liked tracks by artist to create a multi-artist favorites mix
    final artistGroups = <String, List<Track>>{};
    for (final t in likedTracks) {
      final aKey = normalizeArtist(t.artist.name);
      if (aKey.isNotEmpty) {
        artistGroups.putIfAbsent(aKey, () => []).add(t);
      }
    }
    final sortedArtistGroups = artistGroups.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    final favoritesMulti = <Track>[];
    for (final entry in sortedArtistGroups) {
      favoritesMulti.addAll(entry.value.take(2));
    }

    final categories = <String, ({List<Track> tracks, String fallbackQuery})>{};
    if (arabicTracks.isNotEmpty) {
      categories['Arabic & Tarab'] = (
        tracks: arabicTracks,
        fallbackQuery: 'Arabic Tarab mix',
      );
    }
    if (nonArabicTracks.isNotEmpty) {
      categories['Global & Pop Vibes'] = (
        tracks: nonArabicTracks,
        fallbackQuery: 'Global pop hits mix',
      );
    }
    if (chillTracks.length >= 2) {
      categories['Chill & Late Night'] = (
        tracks: chillTracks,
        fallbackQuery: 'Chill acoustic evening mix',
      );
    }
    if (upbeatTracks.length >= 2 && categories.length < 3) {
      categories['Upbeat & Energy'] = (
        tracks: upbeatTracks,
        fallbackQuery: 'Upbeat workout dance mix',
      );
    }
    if (favoritesMulti.length >= 2 && categories.length < 3) {
      categories['Favorites Discovery'] = (
        tracks: favoritesMulti,
        fallbackQuery: 'Popular hits mix',
      );
    }

    var mixIndex = 1;
    for (final entry in categories.entries) {
      if (mixIndex > 3) break;
      final catTracks = entry.value.tracks;
      final catSuggested = await getDiverseSuggestions(
        catTracks,
        6,
        fallbackGenreQuery: entry.value.fallbackQuery,
      );
      final woven = weaveAndInterleave(catTracks, catSuggested);

      mixes.add(
        AiMixPlaylist(
          id: 'ai-mix-$mixIndex',
          title: '${entry.key} Mix',
          subtitle:
              '${catTracks.length} liked · '
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

  Future<List<Track>> resolveClaudeSuggestions(
    List<TrackSuggestion> suggestions, {
    Set<String>? excludeIds,
  }) async {
    if (suggestions.isEmpty) return const [];
    final seen = <String>{...?excludeIds};
    final resolved = <Track>[];

    final searches = suggestions.map((s) async {
      try {
        final query = '${s.title} ${s.artist}'.trim();
        final res = await innertubeClient.search(query);
        if (res.songs.isNotEmpty) {
          return res.songs.first;
        } else if (res.tracks.isNotEmpty) {
          return res.tracks.first;
        }
      } on Object catch (_) {}
      return null;
    });

    final results = await Future.wait(searches);
    for (final track in results) {
      if (track != null && seen.add(track.id)) {
        resolved.add(track);
      }
    }
    return resolved;
  }

  @override
  Future<List<Track>> similarToSearch(
    String query, {
    Track? seedTrack,
    List<Track>? excludeTracks,
  }) async {
    final excludeSet = excludeTracks?.map((t) => t.id).toSet() ?? <String>{};
    if (seedTrack != null) excludeSet.add(seedTrack.id);

    if (claudeAiClient != null && claudeAiClient!.enabled) {
      try {
        final suggestions = await claudeAiClient!.suggestSimilarForSearch(
          query: query,
          topTrack: seedTrack,
          limit: 10,
        );
        if (suggestions.isNotEmpty) {
          final tracks = await resolveClaudeSuggestions(
            suggestions,
            excludeIds: excludeSet,
          );
          if (tracks.isNotEmpty) {
            return tracks;
          }
        }
      } on Object catch (e) {
        Log.w('Claude AI similarToSearch failed: $e');
      }
    }

    final vid =
        seedTrack?.streamId ??
        (seedTrack?.id.startsWith('yt-') == true
            ? seedTrack!.id.substring(3)
            : null);
    if (vid != null && vid.isNotEmpty) {
      try {
        final upNextTracks = await upNext(vid, limit: 10);
        final filtered = upNextTracks
            .where((t) => !excludeSet.contains(t.id))
            .take(8)
            .toList();
        if (filtered.isNotEmpty) return filtered;
      } on Object catch (_) {}
    }

    return const [];
  }
}
