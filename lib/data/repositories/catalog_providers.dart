import 'dart:async';

import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/artist_page.dart';
import 'package:awady_music/data/models/mood_models.dart';
import 'package:awady_music/data/models/playlist_page.dart';
import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/search_results.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/catalog_repository.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/data/sources/audius/audius_client.dart';
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
  return CatalogRepositoryImpl(
    innertubeClient: innertube,
    audiusClient: audius,
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
final moodCategoriesProvider = FutureProvider<List<MoodCategory>>((ref) {
  ref.keepAlive5Min();
  return ref.watch(catalogRepositoryProvider).moods();
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

/// Future provider for personalized recommendations based on the user's likes
/// and followed artists.
final recommendedForYouProvider = FutureProvider<CatalogList<Track>>((
  ref,
) async {
  ref.keepAlive5Min();
  final likedAsync = ref.watch(likedTracksStreamProvider);
  final followedAsync = ref.watch(followedArtistsStreamProvider);
  final lib = ref.watch(libraryRepositoryProvider);

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

  if (liked.isEmpty && followed.isEmpty) {
    return CatalogList(const []);
  }

  return await ref
      .watch(catalogRepositoryProvider)
      .recommendedFromLikes(
        liked,
        followedArtists: followed,
        recentTracks: recents,
      );
});
