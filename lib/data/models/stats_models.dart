import 'package:awady_music/data/models/track.dart';

class TrackAgg {
  TrackAgg({required this.track, this.plays = 0, this.ms = 0});

  factory TrackAgg.fromJson(Map<String, dynamic> json) => TrackAgg(
    track: Track.fromJson(json['track'] as Map<String, dynamic>),
    plays: json['plays'] as int? ?? 0,
    ms: json['ms'] as int? ?? 0,
  );

  Track track;
  int plays;
  int ms;

  Map<String, dynamic> toJson() => {
    'track': track.toJson(),
    'plays': plays,
    'ms': ms,
  };
}

class ArtistAgg {
  ArtistAgg({required this.name, this.art, this.plays = 0, this.ms = 0});

  factory ArtistAgg.fromJson(Map<String, dynamic> json) => ArtistAgg(
    name: json['name'] as String,
    art: json['art'] as String?,
    plays: json['plays'] as int? ?? 0,
    ms: json['ms'] as int? ?? 0,
  );

  String name;
  String? art;
  int plays;
  int ms;

  Map<String, dynamic> toJson() => {
    'name': name,
    'art': art,
    'plays': plays,
    'ms': ms,
  };
}

class MonthAgg {
  MonthAgg({
    this.ms = 0,
    this.plays = 0,
    Map<String, TrackAgg>? tracks,
    Map<String, ArtistAgg>? artists,
  }) : tracks = tracks ?? {},
       artists = artists ?? {};

  factory MonthAgg.fromJson(Map<String, dynamic> json) => MonthAgg(
    ms: json['ms'] as int? ?? 0,
    plays: json['plays'] as int? ?? 0,
    tracks:
        (json['tracks'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, TrackAgg.fromJson(v as Map<String, dynamic>)),
        ) ??
        {},
    artists:
        (json['artists'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, ArtistAgg.fromJson(v as Map<String, dynamic>)),
        ) ??
        {},
  );

  int ms;
  int plays;
  Map<String, TrackAgg> tracks;
  Map<String, ArtistAgg> artists;

  Map<String, dynamic> toJson() => {
    'ms': ms,
    'plays': plays,
    'tracks': tracks.map((k, v) => MapEntry(k, v.toJson())),
    'artists': artists.map((k, v) => MapEntry(k, v.toJson())),
  };
}

class RewindData {
  RewindData({
    required this.key,
    required this.label,
    required this.full,
    required this.partial,
    required this.ms,
    required this.plays,
    required this.tracks,
    required this.artists,
    required this.trackCount,
    required this.artistCount,
  });

  final String key; // YYYY-MM
  final String label;
  final String full;
  final bool partial;
  final int ms;
  final int plays;
  final List<TrackAgg> tracks; // top 5
  final List<ArtistAgg> artists; // top 5
  final int trackCount;
  final int artistCount;
}
