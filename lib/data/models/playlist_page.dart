import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/track.dart';

/// Complete page data for a remote playlist or album.
class PlaylistPage {
  const PlaylistPage({
    required this.playlist,
    this.tracks = const [],
    this.fromFallback = false,
  });

  /// The playlist or album metadata.
  final RemotePlaylist playlist;

  /// The list of tracks in the playlist or album.
  final List<Track> tracks;

  /// Whether this playlist was resolved from fallback (e.g. Audius).
  final bool fromFallback;
}
