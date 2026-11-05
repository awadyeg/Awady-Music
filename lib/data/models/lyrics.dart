import 'package:freezed_annotation/freezed_annotation.dart';

part 'lyrics.freezed.dart';
part 'lyrics.g.dart';

@freezed
abstract class LyricLine with _$LyricLine {
  const factory LyricLine({required int startMs, required String text}) =
      _LyricLine;

  factory LyricLine.fromJson(Map<String, dynamic> json) =>
      _$LyricLineFromJson(json);
}

sealed class Lyrics {
  const Lyrics();
}

class SyncedLyrics extends Lyrics {
  const SyncedLyrics({
    required this.lines,
    required this.source,
    required this.fingerprint,
    this.autoOffsetMs = 0,
  });

  final List<LyricLine> lines;
  final String source;
  final String fingerprint;
  final int autoOffsetMs;
}

class PlainLyrics extends Lyrics {
  const PlainLyrics({required this.text, this.source = ''});

  final String text;
  final String source;
}

class NoLyrics extends Lyrics {
  const NoLyrics();
}
