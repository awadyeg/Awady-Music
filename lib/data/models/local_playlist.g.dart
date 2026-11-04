// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_playlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocalPlaylist _$LocalPlaylistFromJson(Map<String, dynamic> json) =>
    _LocalPlaylist(
      id: json['id'] as String,
      name: json['name'] as String,
      tracks: (json['tracks'] as List<dynamic>)
          .map((e) => Track.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$LocalPlaylistToJson(_LocalPlaylist instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'tracks': instance.tracks.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
