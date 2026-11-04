import 'package:awady_music/data/models/album_ref.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/artwork.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'track.freezed.dart';
part 'track.g.dart';

Object? _readArtist(Map<dynamic, dynamic> json, String key) {
  final val = json['artist'] ?? json['user'];
  if (val is Artist) {
    return val.toJson();
  }
  return val;
}

Object? _readPlayCount(Map<dynamic, dynamic> json, String key) =>
    json['playCount'] ?? json['play_count'] ?? 0;

Object? _readIsStreamable(Map<dynamic, dynamic> json, String key) =>
    json['isStreamable'] ?? json['is_streamable'] ?? true;

Object? _readAlbum(Map<dynamic, dynamic> json, String key) {
  final alb = json['album'];
  if (alb is AlbumRef) {
    return alb.toJson();
  }
  if (alb is String) {
    return {'id': '', 'name': alb};
  }
  return alb;
}

@freezed
abstract class Track with _$Track {
  const factory Track({
    required String id,
    required String title,
    @JsonKey(readValue: _readArtist) required Artist artist,
    @Default(TrackSource.audius) TrackSource source,
    String? streamId,
    @Default(false) bool pending,
    @Default(0) int duration,
    String? genre,
    @JsonKey(readValue: _readPlayCount) @Default(0) int playCount,
    @JsonKey(readValue: _readAlbum) AlbumRef? album,
    Artwork? artwork,
    @JsonKey(readValue: _readIsStreamable) @Default(true) bool isStreamable,
  }) = _Track;

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);
}
