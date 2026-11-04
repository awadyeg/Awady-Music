import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/track.dart';

/// Represents a mood or genre category pill / tile.
class MoodCategory {
  const MoodCategory({
    required this.name,
    required this.params,
    this.stripeColor,
  });

  /// Category display name (e.g. "Chill", "Energy Boost").
  final String name;

  /// Opaque params token required to browse this category.
  final String params;

  /// Optional accent stripe color.
  final int? stripeColor;
}

/// Represents the contents of a specific mood / genre category page.
class MoodPageData {
  const MoodPageData({
    required this.name,
    this.playlists = const [],
    this.tracks = const [],
  });

  /// Name of the category.
  final String name;

  /// Playlists and albums in this mood category.
  final List<RemotePlaylist> playlists;

  /// Featured tracks in this mood category.
  final List<Track> tracks;
}
