// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lyrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LyricLine _$LyricLineFromJson(Map<String, dynamic> json) => _LyricLine(
  startMs: (json['startMs'] as num).toInt(),
  text: json['text'] as String,
);

Map<String, dynamic> _$LyricLineToJson(_LyricLine instance) =>
    <String, dynamic>{'startMs': instance.startMs, 'text': instance.text};
