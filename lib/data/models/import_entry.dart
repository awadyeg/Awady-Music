import 'package:flutter/foundation.dart';

@immutable
class ImportEntry {
  const ImportEntry({required this.title, required this.artist, this.duration});

  factory ImportEntry.fromJson(Map<String, dynamic> json) => ImportEntry(
    title: json['title'] as String? ?? '',
    artist: json['artist'] as String? ?? '',
    duration: json['duration'] as int?,
  );

  final String title;
  final String artist;
  final int? duration;

  Map<String, dynamic> toJson() => {
    'title': title,
    'artist': artist,
    if (duration != null) 'duration': duration,
  };

  @override
  String toString() =>
      'ImportEntry(title: $title, artist: $artist, duration: $duration)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImportEntry &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          artist == other.artist &&
          duration == other.duration;

  @override
  int get hashCode => Object.hash(title, artist, duration);
}
