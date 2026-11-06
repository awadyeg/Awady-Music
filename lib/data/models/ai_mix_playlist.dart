import 'package:awady_music/data/models/track.dart';
import 'package:flutter/foundation.dart';

@immutable
class AiMixPlaylist {
  const AiMixPlaylist({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.category,
    required this.tracks,
    this.suggestedTrackIds = const <String>{},
  });

  final String id;
  final String title;
  final String subtitle;
  final String badge;
  final String category;
  final List<Track> tracks;
  final Set<String> suggestedTrackIds;

  int get likedCount => tracks.length - suggestedCount;
  int get suggestedCount =>
      tracks.where((t) => suggestedTrackIds.contains(t.id)).length;
}
