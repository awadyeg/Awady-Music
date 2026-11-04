// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StreamInfo _$StreamInfoFromJson(Map<String, dynamic> json) => _StreamInfo(
  url: Uri.parse(json['url'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  mimeType: json['mimeType'] as String?,
  bitrate: (json['bitrate'] as num?)?.toInt(),
  loudnessDb: (json['loudnessDb'] as num?)?.toDouble(),
);

Map<String, dynamic> _$StreamInfoToJson(_StreamInfo instance) =>
    <String, dynamic>{
      'url': instance.url.toString(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'mimeType': instance.mimeType,
      'bitrate': instance.bitrate,
      'loudnessDb': instance.loudnessDb,
    };
