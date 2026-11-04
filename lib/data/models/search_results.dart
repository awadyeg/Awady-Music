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
  });

  /// The top result (can be an [Artist], [Track], or [RemotePlaylist]).
  final Object? top;

  /// Track hits.
  final List<Track> songs;

  /// Artist hits.
  final List<Artist> artists;

  /// Album and playlist hits.
  final List<RemotePlaylist> playlists;
}
