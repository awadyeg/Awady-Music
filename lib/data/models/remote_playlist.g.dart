// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_playlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RemotePlaylist _$RemotePlaylistFromJson(Map<String, dynamic> json) =>
    _RemotePlaylist(
      id: json['id'] as String,
      name: _readName(json, 'name') as String,
      owner: Artist.fromJson(_readOwner(json, 'owner') as Map<String, dynamic>),
      isAlbum: _readIsAlbum(json, 'isAlbum') as bool? ?? false,
      description: json['description'] as String?,
      artwork: json['artwork'] == null
          ? null
          : Artwork.fromJson(json['artwork'] as Map<String, dynamic>),
      trackCount: (_readTrackCount(json, 'trackCount') as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RemotePlaylistToJson(_RemotePlaylist instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'owner': instance.owner.toJson(),
      'isAlbum': instance.isAlbum,
      'description': instance.description,
      'artwork': instance.artwork?.toJson(),
      'trackCount': instance.trackCount,
    };
