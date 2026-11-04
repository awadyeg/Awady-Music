// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Artist _$ArtistFromJson(Map<String, dynamic> json) => _Artist(
  id: json['id'] as String,
  name: json['name'] as String,
  streamId: json['streamId'] as String?,
  handle: json['handle'] as String? ?? '',
  bio: json['bio'] as String?,
  isVerified: _readIsVerified(json, 'isVerified') as bool? ?? false,
  followerCount:
      (_readFollowerCount(json, 'followerCount') as num?)?.toInt() ?? 0,
  trackCount: (_readTrackCount(json, 'trackCount') as num?)?.toInt() ?? 0,
  profilePicture: _readProfilePicture(json, 'profilePicture') == null
      ? null
      : Artwork.fromJson(
          _readProfilePicture(json, 'profilePicture') as Map<String, dynamic>,
        ),
  coverPhoto: _readCoverPhoto(json, 'coverPhoto') as String?,
);

Map<String, dynamic> _$ArtistToJson(_Artist instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'streamId': instance.streamId,
  'handle': instance.handle,
  'bio': instance.bio,
  'isVerified': instance.isVerified,
  'followerCount': instance.followerCount,
  'trackCount': instance.trackCount,
  'profilePicture': instance.profilePicture?.toJson(),
  'coverPhoto': instance.coverPhoto,
};
