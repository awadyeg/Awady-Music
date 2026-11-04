import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/artwork.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_playlist.freezed.dart';
part 'remote_playlist.g.dart';

Object? _readName(Map<dynamic, dynamic> json, String key) =>
    json['name'] ?? json['playlist_name'] ?? '';

Object? _readIsAlbum(Map<dynamic, dynamic> json, String key) =>
    json['isAlbum'] ?? json['is_album'] ?? false;

Object? _readTrackCount(Map<dynamic, dynamic> json, String key) =>
    json['trackCount'] ?? json['track_count'] ?? 0;

Object? _readOwner(Map<dynamic, dynamic> json, String key) {
  final val = json['owner'] ?? json['user'];
  if (val is Artist) {
    return val.toJson();
  }
  return val;
}

@freezed
abstract class RemotePlaylist with _$RemotePlaylist {
  const factory RemotePlaylist({
    required String id,
    @JsonKey(readValue: _readName) required String name,
    @JsonKey(readValue: _readOwner) required Artist owner,
    @JsonKey(readValue: _readIsAlbum) @Default(false) bool isAlbum,
    String? description,
    Artwork? artwork,
    @JsonKey(readValue: _readTrackCount) @Default(0) int trackCount,
  }) = _RemotePlaylist;

  factory RemotePlaylist.fromJson(Map<String, dynamic> json) =>
      _$RemotePlaylistFromJson(json);
}
