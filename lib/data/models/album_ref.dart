import 'package:freezed_annotation/freezed_annotation.dart';

part 'album_ref.freezed.dart';
part 'album_ref.g.dart';

@freezed
abstract class AlbumRef with _$AlbumRef {
  const factory AlbumRef({required String id, required String name}) =
      _AlbumRef;

  factory AlbumRef.fromJson(Map<String, dynamic> json) =>
      _$AlbumRefFromJson(json);
}
