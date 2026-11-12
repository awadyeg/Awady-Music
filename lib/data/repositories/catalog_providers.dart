import 'dart:async';

import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/artist_page.dart';
import 'package:awady_music/data/models/mood_models.dart';
import 'package:awady_music/data/models/playlist_page.dart';
import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/search_results.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/catalog_repository.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/data/repositories/stats_repository.dart';
import 'package:awady_music/data/sources/audius/audius_client.dart';
import 'package:awady_music/data/sources/claude/claude_ai_client.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension _KeepAlive5Min on Ref {
  void keepAlive5Min() {
    final link = keepAlive();
    final timer = Timer(const Duration(minutes: 5), link.close);
    onDispose(timer.cancel);
  }
}

/// Provider for [CatalogRepository].
final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final innertube = ref.watch(innertubeClientProvider);
  final audius = ref.watch(audiusClientProvider);
  final claudeAi = ref.watch(claudeAiClientProvider);
  return CatalogRepositoryImpl(
    innertubeClient: innertube,
    audiusClient: audius,
    claudeAiClient: claudeAi,
  );
});

/// Future provider family for catalog searches with 5 minute keepAlive.
final searchProvider = FutureProvider.family<SearchResults, String>((
  ref,
  query,
) {
  ref.keepAlive5Min();
  return ref.watch(catalogRepositoryProvider).search(query);
});

/// Future provider family for search query suggestions.
final suggestProvider = FutureProvider.family<List<String>, String>((
  ref,
  query,
) {
  ref.keepAlive5Min();
  return ref.watch(catalogRepositoryProvider).suggest(query);
});

/// Future provider family for artist detail page data.
final artistPageProvider = FutureProvider.family<ArtistPage, String>((
  ref,
  key,
) {
  ref.keepAlive5Min();
  final tabIdx = key.indexOf('\t');
  if (tabIdx >= 0) {
    final channelId = key.substring(0, tabIdx);
    final nameHint = key.substring(tabIdx + 1);
    return ref
        .watch(catalogRepositoryProvider)
        .artist(channelId, nameHint: nameHint.isNotEmpty ? nameHint : null);
  }
  return ref.watch(catalogRepositoryProvider).artist(key);
});

/// Future provider family for playlist page data.
final playlistPageProvider = FutureProvider.family<PlaylistPage, String>((
  ref,
  browseId,
) {
  ref.keepAlive5Min();
  return ref.watch(catalogRepositoryProvider).playlist(browseId);
});

/// Future provider family for album page data.
final albumPageProvider = FutureProvider.family<PlaylistPage, String>((
  ref,
  browseId,
) {
  ref.keepAlive5Min();
  return ref.watch(catalogRepositoryProvider).album(browseId);
});

/// Future provider for home screen playlists carousel.
final homePlaylistsProvider = FutureProvider<CatalogList<RemotePlaylist>>((
  ref,
) {
  ref.keepAlive5Min();
  return ref.watch(catalogRepositoryProvider).homePlaylists();
});

/// Future provider for trending tracks.
final trendingTracksProvider = FutureProvider<CatalogList<Track>>((ref) {
  ref.keepAlive5Min();
  return ref.watch(catalogRepositoryProvider).trending();
});

/// Future provider for charts tracks.
final chartsProvider = FutureProvider<CatalogList<Track>>((ref) {
  ref.keepAlive5Min();
  return ref.watch(catalogRepositoryProvider).charts();
});

/// Future provider for new release albums/playlists.
final newReleasesProvider = FutureProvider<CatalogList<RemotePlaylist>>((ref) {
  ref.keepAlive5Min();
  return ref.watch(catalogRepositoryProvider).newReleases();
});

/// Future provider for mood categories directory.
final moodCategoriesProvider = FutureProvider<List<MoodCategory>>((ref) async {
  ref.keepAlive5Min();
  final countryCode = ref.watch(settingsProvider.select((s) => s.countryCode));
  final likedAsync = ref.watch(likedTracksStreamProvider);
  final likes = likedAsync.asData?.value ?? const [];
  final country = findMusicCountry(countryCode);

  final personalized = <MoodCategory>[];
  if (likes.isNotEmpty) {
    personalized.addAll(const [
      MoodCategory(
        name: 'My Likes Vibe',
        params: 'custom:My Likes Vibe|best liked songs mix',
      ),
      MoodCategory(
        name: 'Chill from Likes',
        params: 'custom:Chill from Likes|chill acoustic relaxing hits',
      ),
      MoodCategory(
        name: 'Upbeat Likes Mix',
        params: 'custom:Upbeat Likes Mix|upbeat workout dance party hits',
      ),
    ]);
  }

  final countryName = country.nameEn;
  personalized.add(
    MoodCategory(
      name: '${country.flag} $countryName Hits',
      params: 'custom:${country.flag} $countryName Hits|top music $countryName',
    ),
  );

  final isArabic = [
    'EG',
    'SA',
    'AE',
    'MA',
    'DZ',
    'IQ',
    'KW',
    'QA',
    'LB',
    'JO',
    'TN',
    'OM',
    'BH',
    'YE',
    'SY',
    'SD',
    'LY',
    'PS',
  ].contains(countryCode.toUpperCase());

  if (isArabic) {
    personalized.addAll(const [
      MoodCategory(
        name: 'Arabic Tarab & Classics',
        params: 'custom:Arabic Tarab & Classics|arabic classic tarab songs',
      ),
      MoodCategory(
        name: 'Arabic Chill & Oud',
        params: 'custom:Arabic Chill & Oud|arabic chill acoustic oud relaxing',
      ),
      MoodCategory(
        name: 'Shaabi & Party Vibes',
        params: 'custom:Shaabi & Party Vibes|egyptian shaabi dance party hits',
      ),
    ]);
  }

  final remoteMoods = await ref.watch(catalogRepositoryProvider).moods();

  final seenNames = <String>{};
  final combined = <MoodCategory>[];

  for (final m in [...personalized, ...remoteMoods]) {
    final lower = m.name.toLowerCase().trim();
    if (seenNames.add(lower)) {
      combined.add(m);
    }
  }

  return combined;
});

/// Future provider family for individual mood page data.
final moodPageProvider = FutureProvider.family<MoodPageData, String>((
  ref,
  params,
) {
  ref.keepAlive5Min();
  return ref.watch(catalogRepositoryProvider).mood(params);
});

/// Future provider family for up next / radio tracks.
final upNextTracksProvider = FutureProvider.family<List<Track>, String>((
  ref,
  videoId,
) {
  ref.keepAlive5Min();
  return ref.watch(catalogRepositoryProvider).upNext(videoId);
});

/// Merges explicit likes with most-played tracks (implicit favorites)
/// and recent listening history, deduplicated in order of relevance.
List<Track> getEffectiveFavoriteTracks({
  required List<Track> likedTracks,
  required List<Track> mostPlayedTracks,
  required List<Track> recentTracks,
}) {
  final seen = <String>{};
  final effective = <Track>[];

  for (final t in likedTracks) {
    if (seen.add(t.id)) {
      effective.add(t);
    }
  }

  for (final t in mostPlayedTracks.take(25)) {
    if (seen.add(t.id)) {
      effective.add(t);
    }
  }

  for (final t in recentTracks.take(15)) {
    if (seen.add(t.id)) {
      effective.add(t);
    }
  }

  return effective;
}

/// Future provider for personalized recommendations based on the user's likes,
/// most played songs (implicit favorites), and followed artists.
final recommendedForYouProvider = FutureProvider<CatalogList<Track>>((
  ref,
) async {
  ref.keepAlive5Min();
  final likedAsync = ref.watch(likedTracksStreamProvider);
  final followedAsync = ref.watch(followedArtistsStreamProvider);
  final lib = ref.watch(libraryRepositoryProvider);
  final stats = ref.watch(statsRepositoryProvider);

  var liked = likedAsync.asData?.value ?? const <Track>[];
  var followed = followedAsync.asData?.value ?? const <Artist>[];
  var recents = const <Track>[];

  try {
    if (liked.isEmpty) {
      liked = lib.likedTracks;
    }
  } on Object catch (_) {}
  try {
    if (followed.isEmpty) {
      followed = lib.followedArtists;
    }
  } on Object catch (_) {}
  try {
    recents = lib.recents;
  } on Object catch (_) {}

  var mostPlayed = const <Track>[];
  try {
    mostPlayed = stats.mostPlayedTracks;
  } on Object catch (_) {}

  final effectiveFavorites = getEffectiveFavoriteTracks(
    likedTracks: liked,
    mostPlayedTracks: mostPlayed,
    recentTracks: recents,
  );

  if (liked.isEmpty && mostPlayed.isEmpty && followed.isEmpty) {
    return CatalogList(const []);
  }

  return await ref
      .watch(catalogRepositoryProvider)
      .recommendedFromLikes(
        effectiveFavorites,
        followedArtists: followed,
        recentTracks: recents,
      );
});

/// Future provider for AI-generated mixes based on user's liked and
/// most-played tracks.
final aiMixesProvider = FutureProvider<List<AiMixPlaylist>>((ref) async {
  ref.keepAlive5Min();
  final likedAsync = ref.watch(likedTracksStreamProvider);
  final followedAsync = ref.watch(followedArtistsStreamProvider);
  final lib = ref.watch(libraryRepositoryProvider);
  final stats = ref.watch(statsRepositoryProvider);

  var liked = likedAsync.asData?.value ?? const <Track>[];
  var followed = followedAsync.asData?.value ?? const <Artist>[];

  try {
    if (liked.isEmpty) {
      liked = lib.likedTracks;
    }
  } on Object catch (_) {}
  try {
    if (followed.isEmpty) {
      followed = lib.followedArtists;
    }
  } on Object catch (_) {}

  var mostPlayed = const <Track>[];
  try {
    mostPlayed = stats.mostPlayedTracks;
  } on Object catch (_) {}

  var recents = const <Track>[];
  try {
    recents = lib.recents;
  } on Object catch (_) {}

  final effectiveFavorites = getEffectiveFavoriteTracks(
    likedTracks: liked,
    mostPlayedTracks: mostPlayed,
    recentTracks: recents,
  );

  if (liked.isEmpty && mostPlayed.isEmpty) {
    return const [];
  }

  return await ref
      .watch(catalogRepositoryProvider)
      .aiMixesFromLikes(effectiveFavorites, followedArtists: followed);
});

/// Future provider family for similar tracks on search results powered
/// by Claude AI.
final similarSearchTracksProvider =
    FutureProvider.family<List<Track>, ({String query, Track? topTrack})>((
      ref,
      arg,
    ) {
      ref.keepAlive5Min();
      return ref
          .watch(catalogRepositoryProvider)
          .similarToSearch(arg.query, seedTrack: arg.topTrack);
    });
