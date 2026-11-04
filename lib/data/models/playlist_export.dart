import 'package:freezed_annotation/freezed_annotation.dart';

part 'playlist_export.freezed.dart';
part 'playlist_export.g.dart';

@freezed
abstract class PlaylistExportTrack with _$PlaylistExportTrack {
  const factory PlaylistExportTrack({
    required String title,
    @Default('') String artist,
    @Default(0) int duration,
    @Default('audius') String source,
    String? streamId,
    String? album,
  }) = _PlaylistExportTrack;

  factory PlaylistExportTrack.fromJson(Map<String, dynamic> json) =>
      _$PlaylistExportTrackFromJson(json);
}

@freezed
abstract class PlaylistExport with _$PlaylistExport {
  const factory PlaylistExport({
    required String name,
    required String exportedAt,
    required List<PlaylistExportTrack> tracks,
    @Default('freebify') String app,
    @Default('playlist') String type,
    @Default(1) int version,
  }) = _PlaylistExport;

  factory PlaylistExport.fromJson(Map<String, dynamic> json) =>
      _$PlaylistExportFromJson(json);
}
