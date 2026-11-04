import 'package:freezed_annotation/freezed_annotation.dart';

part 'artwork.freezed.dart';
part 'artwork.g.dart';

@freezed
abstract class Artwork with _$Artwork {
  const factory Artwork({
    @JsonKey(name: '150x150') String? s150,
    @JsonKey(name: '480x480') String? s480,
    @JsonKey(name: '1000x1000') String? s1000,
    @Default(<String>[]) List<String> mirrors,
    String? fallback,
  }) = _Artwork;

  factory Artwork.fromJson(Map<String, dynamic> json) =>
      _$ArtworkFromJson(json);
}
