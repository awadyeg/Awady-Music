import 'package:awady_music/data/models/artwork.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'artist.freezed.dart';
part 'artist.g.dart';

Object? _readIsVerified(Map<dynamic, dynamic> json, String key) =>
    json['isVerified'] ?? json['is_verified'] ?? false;

Object? _readFollowerCount(Map<dynamic, dynamic> json, String key) =>
    json['followerCount'] ?? json['follower_count'] ?? 0;

Object? _readTrackCount(Map<dynamic, dynamic> json, String key) =>
    json['trackCount'] ?? json['track_count'] ?? 0;

Object? _readProfilePicture(Map<dynamic, dynamic> json, String key) =>
    json['profilePicture'] ?? json['profile_picture'];

Object? _readCoverPhoto(Map<dynamic, dynamic> json, String key) {
  final val = json['coverPhoto'] ?? json['cover_photo'];
  if (val is Map) {
    return val['2000x'] ?? val['640x'];
  }
  return val;
}

bool hasArtistPage(Artist? a) =>
    a != null && a.id.isNotEmpty && a.id != 'yt-va' && a.id != 'yt-';

@freezed
abstract class Artist with _$Artist {
  const factory Artist({
    required String id,
    required String name,
    String? streamId,
    @Default('') String handle,
    String? bio,
    @JsonKey(readValue: _readIsVerified) @Default(false) bool isVerified,
    @JsonKey(readValue: _readFollowerCount) @Default(0) int followerCount,
    @JsonKey(readValue: _readTrackCount) @Default(0) int trackCount,
    @JsonKey(readValue: _readProfilePicture) Artwork? profilePicture,
    @JsonKey(readValue: _readCoverPhoto) String? coverPhoto,
  }) = _Artist;

  const Artist._();

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);

  bool get hasPage => hasArtistPage(this);
}
