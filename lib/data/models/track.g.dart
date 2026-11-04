// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Track _$TrackFromJson(Map<String, dynamic> json) => _Track(
  id: json['id'] as String,
  title: json['title'] as String,
  artist: Artist.fromJson(_readArtist(json, 'artist') as Map<String, dynamic>),
  source:
      $enumDecodeNullable(_$TrackSourceEnumMap, json['source']) ??
      TrackSource.audius,
  streamId: json['streamId'] as String?,
  pending: json['pending'] as bool? ?? false,
  duration: (json['duration'] as num?)?.toInt() ?? 0,
  genre: json['genre'] as String?,
  playCount: (_readPlayCount(json, 'playCount') as num?)?.toInt() ?? 0,
  album: _readAlbum(json, 'album') == null
      ? null
      : AlbumRef.fromJson(_readAlbum(json, 'album') as Map<String, dynamic>),
  artwork: json['artwork'] == null
      ? null
      : Artwork.fromJson(json['artwork'] as Map<String, dynamic>),
  isStreamable: _readIsStreamable(json, 'isStreamable') as bool? ?? true,
);

Map<String, dynamic> _$TrackToJson(_Track instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'artist': instance.artist.toJson(),
  'source': _$TrackSourceEnumMap[instance.source]!,
  'streamId': instance.streamId,
  'pending': instance.pending,
  'duration': instance.duration,
  'genre': instance.genre,
  'playCount': instance.playCount,
  'album': instance.album?.toJson(),
  'artwork': instance.artwork?.toJson(),
  'isStreamable': instance.isStreamable,
};

const _$TrackSourceEnumMap = {
  TrackSource.audius: 'audius',
  TrackSource.yt: 'yt',
};
