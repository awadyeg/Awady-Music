import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/track.dart';

/// Complete page data for a remote playlist or album.
class PlaylistPage {
  const PlaylistPage({required this.playlist, this.tracks = const []});

  /// The playlist or album metadata.
  final RemotePlaylist playlist;

  /// The list of tracks in the playlist or album.
  final List<Track> tracks;
}
