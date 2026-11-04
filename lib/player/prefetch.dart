import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/sources/ytstream/stream_resolver_impl.dart';
import 'package:awady_music/data/sources/ytstream/stream_resolver_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Prefetches top [count] tracks from a list (e.g. search results or home rows)
/// without needing VisibilityDetector.
void prefetchTopTracks(WidgetRef ref, List<Track> tracks, {int count = 3}) {
  final resolver = ref.read(streamResolverProvider);
  prefetchTracksWithResolver(resolver, tracks, count: count);
}

/// Standalone helper to prefetch tracks using a [StreamResolver].
void prefetchTracksWithResolver(
  StreamResolver resolver,
  List<Track> tracks, {
  int count = 3,
}) {
  final top = tracks.take(count);
  for (final track in top) {
    final vid =
        track.streamId ?? (track.id.startsWith('yt-') ? track.id : null);
    if (track.source == TrackSource.yt && vid != null) {
      resolver.prefetch(vid);
    }
  }
}
