import 'dart:math';

import 'package:awady_music/data/models/lyrics.dart';

/// Parses LRC formatted lyrics string into a list of [LyricLine]s
/// sorted by start time.
List<LyricLine> parseLrc(String src) {
  final out = <LyricLine>[];
  var metaOffsetMs = 0;

  final lines = src.split('\n');
  final offsetRegex = RegExp(
    r'^\[offset:\s*([+-]?\d+)\s*\]',
    caseSensitive: false,
  );
  final stampRegex = RegExp(
    r'^\[(?:(\d{1,2}):)?(\d{1,2}):(\d{2})(?:[.:](\d{1,3}))?\]',
  );
  final inlineWordRegex = RegExp(r'<\d{1,2}:\d{2}(?::\d{2})?(?:[.:]\d{1,3})?>');
  final inlineTagRegex = RegExp(
    r'\[\d{1,2}:\d{2}(?::\d{2})?(?:[.:]\d{1,3})?\]',
  );

  for (final rawLine in lines) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;

    // Check for [offset:±ms] metadata tag
    final offsetMatch = offsetRegex.firstMatch(line);
    if (offsetMatch != null) {
      metaOffsetMs = int.tryParse(offsetMatch.group(1) ?? '0') ?? 0;
      continue;
    }

    // Skip other metadata tags like [ar:Artist], [ti:Title], [al:Album], etc.
    if (RegExp(r'^\[[a-zA-Z]{2,8}:.*\]$').hasMatch(line)) {
      continue;
    }

    var rest = line;
    final stampMsList = <int>[];

    // Extract all leading timestamp tags
    while (true) {
      final match = stampRegex.firstMatch(rest);
      if (match == null) break;

      final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
      final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
      final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
      final fracStr = match.group(4);

      var fracMs = 0;
      if (fracStr != null && fracStr.isNotEmpty) {
        final fracVal = int.tryParse(fracStr) ?? 0;
        fracMs = (fracVal * 1000 / pow(10, fracStr.length)).round();
      }

      final totalMs = (hours * 3600 + minutes * 60 + seconds) * 1000 + fracMs;
      stampMsList.add(totalMs);

      rest = rest.substring(match.end).trim();
    }

    // Strip inline enhanced LRC word markers <mm:ss.xx> and mid-line stamps
    rest = rest
        .replaceAll(inlineWordRegex, '')
        .replaceAll(inlineTagRegex, '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (stampMsList.isEmpty || rest.isEmpty) continue;

    for (final t in stampMsList) {
      final adjustedMs = max(0, t + metaOffsetMs);
      out.add(LyricLine(startMs: adjustedMs, text: rest));
    }
  }

  out.sort((a, b) => a.startMs.compareTo(b.startMs));
  return out;
}

/// Computes sheet fingerprint from the tail lines of the lyrics sheet.
/// Uses the last 3 non-musical marker lines normalized to unicode tokens.
String sheetFingerprint(List<LyricLine> lines) {
  final contentLines = lines.where((l) => l.text.trim() != '♪').toList();
  if (contentLines.isEmpty) return '';

  final tail = contentLines.length <= 3
      ? contentLines
      : contentLines.sublist(contentLines.length - 3);

  final joinedText = tail.map((l) => l.text).join(' ');
  final tokens = _simTokens(joinedText);
  final fp = tokens.join(' ');
  return fp.length <= 64 ? fp : fp.substring(0, 64).trim();
}

/// Tokenizes string using Unicode letters and numbers, lowercasing and
/// stripping diacritics.
List<String> _simTokens(String s) {
  final decomposed = _stripDiacritics(s.toLowerCase());
  final matches = RegExp(
    r'[\p{L}\p{N}]+',
    unicode: true,
  ).allMatches(decomposed);
  return matches.map((m) => m.group(0)!).toList();
}

/// Basic diacritic stripping for common Latin accents
String _stripDiacritics(String s) {
  var res = s;
  const withAccents =
      'àáâãäåāăąèéêëēĕėęěìíîïīĭįıòóôõöøōŏőùúûüũūŭůűųñńņňçćĉċčýÿŷ';
  const withoutAccents =
      'aaaaaaaaaeeeeeeeeeiiiiiiiiooooooooouuuuuuuuuunnnncccccyyy';
  for (var i = 0; i < withAccents.length; i++) {
    res = res.replaceAll(withAccents[i], withoutAccents[i]);
  }
  return res;
}

/// Formats a list of [LyricLine]s back into standard LRC string.
String formatLrc(List<LyricLine> lines) {
  final buffer = StringBuffer();
  for (final line in lines) {
    final totalSec = line.startMs / 1000.0;
    final minutes = (totalSec ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSec % 60).toInt().toString().padLeft(2, '0');
    final hundredths = ((line.startMs % 1000) ~/ 10).toString().padLeft(2, '0');
    buffer.writeln('[$minutes:$seconds.$hundredths] ${line.text}');
  }
  return buffer.toString().trim();
}
