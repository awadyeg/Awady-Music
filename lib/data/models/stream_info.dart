import 'package:freezed_annotation/freezed_annotation.dart';

part 'stream_info.freezed.dart';
part 'stream_info.g.dart';

@freezed
abstract class StreamInfo with _$StreamInfo {
  const factory StreamInfo({
    required Uri url,
    required DateTime expiresAt,
    String? mimeType,
    int? bitrate,
    double? loudnessDb,
  }) = _StreamInfo;

  factory StreamInfo.fromJson(Map<String, dynamic> json) =>
      _$StreamInfoFromJson(json);
}
