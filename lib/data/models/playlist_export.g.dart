// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_export.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlaylistExportTrack _$PlaylistExportTrackFromJson(Map<String, dynamic> json) =>
    _PlaylistExportTrack(
      title: json['title'] as String,
      artist: json['artist'] as String? ?? '',
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      source: json['source'] as String? ?? 'audius',
      streamId: json['streamId'] as String?,
      album: json['album'] as String?,
    );

Map<String, dynamic> _$PlaylistExportTrackToJson(
  _PlaylistExportTrack instance,
) => <String, dynamic>{
  'title': instance.title,
  'artist': instance.artist,
  'duration': instance.duration,
  'source': instance.source,
  'streamId': instance.streamId,
  'album': instance.album,
};

_PlaylistExport _$PlaylistExportFromJson(Map<String, dynamic> json) =>
    _PlaylistExport(
      name: json['name'] as String,
      exportedAt: json['exportedAt'] as String,
      tracks: (json['tracks'] as List<dynamic>)
          .map((e) => PlaylistExportTrack.fromJson(e as Map<String, dynamic>))
          .toList(),
      app: json['app'] as String? ?? 'freebify',
      type: json['type'] as String? ?? 'playlist',
      version: (json['version'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$PlaylistExportToJson(_PlaylistExport instance) =>
    <String, dynamic>{
      'name': instance.name,
      'exportedAt': instance.exportedAt,
      'tracks': instance.tracks.map((e) => e.toJson()).toList(),
      'app': instance.app,
      'type': instance.type,
      'version': instance.version,
    };
