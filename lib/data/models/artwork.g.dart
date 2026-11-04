// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artwork.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Artwork _$ArtworkFromJson(Map<String, dynamic> json) => _Artwork(
  s150: json['150x150'] as String?,
  s480: json['480x480'] as String?,
  s1000: json['1000x1000'] as String?,
  mirrors:
      (json['mirrors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  fallback: json['fallback'] as String?,
);

Map<String, dynamic> _$ArtworkToJson(_Artwork instance) => <String, dynamic>{
  '150x150': instance.s150,
  '480x480': instance.s480,
  '1000x1000': instance.s1000,
  'mirrors': instance.mirrors,
  'fallback': instance.fallback,
};
