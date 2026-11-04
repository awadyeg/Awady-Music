import 'package:awady_music/data/models/track.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_item.freezed.dart';
part 'download_item.g.dart';

@freezed
abstract class DownloadItem with _$DownloadItem {
  const factory DownloadItem({
    required String trackId,
    required String filePath,
    required DateTime addedAt,
    required Track track,
  }) = _DownloadItem;

  factory DownloadItem.fromJson(Map<String, dynamic> json) =>
      _$DownloadItemFromJson(json);
}
