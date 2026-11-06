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

  Map<String, dynamic> toJson();

  static Lyrics fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'synced' => SyncedLyrics(
        lines:
            (json['lines'] as List<dynamic>?)
                ?.map((e) => LyricLine.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        source: json['source'] as String? ?? '',
        fingerprint: json['fingerprint'] as String? ?? '',
        autoOffsetMs: (json['autoOffsetMs'] as num?)?.toInt() ?? 0,
      ),
      'plain' => PlainLyrics(
        text: json['text'] as String? ?? '',
        source: json['source'] as String? ?? '',
      ),
      _ => const NoLyrics(),
    };
  }
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

  @override
  Map<String, dynamic> toJson() => {
    'type': 'synced',
    'lines': lines.map((l) => l.toJson()).toList(),
    'source': source,
    'fingerprint': fingerprint,
    'autoOffsetMs': autoOffsetMs,
  };
}

class PlainLyrics extends Lyrics {
  const PlainLyrics({required this.text, this.source = ''});

  final String text;
  final String source;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'plain',
    'text': text,
    'source': source,
  };
}

class NoLyrics extends Lyrics {
  const NoLyrics();

  @override
  Map<String, dynamic> toJson() => {'type': 'none'};
}
