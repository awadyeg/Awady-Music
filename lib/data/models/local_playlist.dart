import 'package:awady_music/data/models/track.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'local_playlist.freezed.dart';
part 'local_playlist.g.dart';

@freezed
abstract class LocalPlaylist with _$LocalPlaylist {
  const factory LocalPlaylist({
    required String id,
    required String name,
    required List<Track> tracks,
    required DateTime createdAt,
  }) = _LocalPlaylist;

  factory LocalPlaylist.fromJson(Map<String, dynamic> json) =>
      _$LocalPlaylistFromJson(json);
}
