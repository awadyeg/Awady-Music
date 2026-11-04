import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/track.dart';

/// Aggregated search results returned by the search parser.
class SearchResults {
  const SearchResults({
    this.top,
    this.songs = const [],
    this.artists = const [],
    this.playlists = const [],
    this.fromFallback = false,
  });

  /// The top result (can be an [Artist], [Track], or [RemotePlaylist]).
  final Object? top;

  /// Track hits.
  final List<Track> songs;

  /// Alias for songs.
  List<Track> get tracks => songs;

  /// Artist hits.
  final List<Artist> artists;

  /// Album and playlist hits.
  final List<RemotePlaylist> playlists;

  /// Whether the results came from fallback (e.g. Audius).
  final bool fromFallback;
}
