import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/track.dart';

/// Complete page data for an artist.
class ArtistPage {
  const ArtistPage({
    required this.artist,
    this.topSongs = const [],
    this.albums = const [],
    this.singles = const [],
    this.bio,
    this.fromFallback = false,
  });

  /// The artist profile details.
  final Artist artist;

  /// Top tracks for the artist.
  final List<Track> topSongs;

  /// Albums released by the artist.
  final List<RemotePlaylist> albums;

  /// Singles and EPs released by the artist.
  final List<RemotePlaylist> singles;

  /// Bio or biography summary if available.
  final String? bio;

  /// Whether this artist page was fetched from fallback (e.g. Audius).
  final bool fromFallback;
}
