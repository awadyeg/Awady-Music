// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DownloadItem _$DownloadItemFromJson(Map<String, dynamic> json) =>
    _DownloadItem(
      trackId: json['trackId'] as String,
      filePath: json['filePath'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
      track: Track.fromJson(json['track'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DownloadItemToJson(_DownloadItem instance) =>
    <String, dynamic>{
      'trackId': instance.trackId,
      'filePath': instance.filePath,
      'addedAt': instance.addedAt.toIso8601String(),
      'track': instance.track.toJson(),
    };
