import 'dart:async';
import 'dart:math' as math;

import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/data/models/lyrics.dart';
import 'package:awady_music/data/sources/http.dart';
import 'package:awady_music/data/sources/innertube/matcher.dart' show fold;
import 'package:awady_music/data/sources/lyrics/lrc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for LrclibClient
final lrclibClientProvider = Provider<LrclibClient>((ref) {
  return LrclibClient();
});

/// Candidate record returned by LRCLIB API.
class LrclibRecord {
  const LrclibRecord({
    required this.id,
    required this.trackName,
    required this.artistName,
    required this.duration,
    this.albumName,
    this.plainLyrics,
    this.syncedLyrics,
  });

  factory LrclibRecord.fromJson(Map<String, dynamic> json) {
    final rawDur = json['duration'];
    final dur = (rawDur is num)
        ? rawDur.toDouble()
        : double.tryParse(rawDur?.toString() ?? '0') ?? 0.0;

    return LrclibRecord(
      id: (json['id'] is int)
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      trackName: (json['trackName'] ?? json['name'] ?? '').toString(),
      artistName: (json['artistName'] ?? '').toString(),
      albumName: json['albumName']?.toString(),
      duration: dur,
      plainLyrics: json['plainLyrics']?.toString(),
      syncedLyrics: json['syncedLyrics']?.toString(),
    );
  }

  final int id;
  final String trackName;
  final String artistName;
  final String? albumName;
  final double duration;
  final String? plainLyrics;
  final String? syncedLyrics;
}

final _titleNoiseRegex = RegExp(
  r'video|oficial|official|lyric|letra|\baudio\b|visual|\bhd\b|\b4k\b|\bmv\b|explicit|live\b|cover\b|remaster',
  caseSensitive: false,
);

/// Strips up to 4 trailing bracket/parenthesis/pipe groups matching noise words.
String cleanTitle(String s) {
  var t = s.trim();
  for (var i = 0; i < 4; i++) {
    final match = RegExp(r'\s*(\([^(]*\)|\[[^\]]*\]|\|.*)$').firstMatch(t);
    if (match == null) break;
    final groupContent = match.group(1) ?? '';
    if (!_titleNoiseRegex.hasMatch(groupContent)) break;
    t = t.substring(0, match.start).trim();
  }
  return t;
}

/// Drops all bracket groups and pipe tails for a bare-title fallback query.
String stripGroups(String s) {
  return s
      .replaceAll(RegExp(r'\s*(\([^(]*\)|\[[^\]]*\])'), '')
      .replaceAll(RegExp(r'\s*\|.*$'), '')
      .trim();
}

/// Cleans artist name by stripping channel suffixes like "- Topic", "VEVO".
String cleanArtist(String s) {
  return s
      .replaceAll(
        RegExp(
          r'\s*[-–]\s*(vevo|official|oficial|topic)\b.*$',
          caseSensitive: false,
        ),
        '',
      )
      .replaceAll(RegExp(r'VEVO\s*$', caseSensitive: false), '')
      .trim();
}

/// Normalizes a string to lower-case alphanumeric with folded diacritics.
String norm(String s) {
  return fold(s)
      .replaceAll(RegExp('[^a-z0-9]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Unicode-aware words tokenizer for non-Latin script fallback.
List<String> simTokens(String s) {
  final matches = RegExp(r'[\p{L}\p{N}]+', unicode: true).allMatches(fold(s));
  return matches.map((m) => m.group(0)!).toList();
}

bool _starts(String a, String b) {
  return a.startsWith(b) || a.startsWith('$b ');
}

/// Evaluates artist similarity between track candidate and reference artist.
/// Returns 2 for exact/prefix match, 1 for word overlap, 0 otherwise.
int artistSim(String candidateArtist, String targetArtist) {
  final na = norm(targetArtist);
  final nr = norm(candidateArtist);
  if (na.isEmpty || nr.isEmpty) return 0;
  if (na == nr || _starts(na, nr) || _starts(nr, na)) return 2;
  final wa = na.split(' ').toSet();
  final wordsInNr = nr.split(' ');
  for (final w in wordsInNr) {
    if (wa.contains(w)) return 1;
  }
  return 0;
}

/// Determines if candidate title is close enough to reference title.
bool titleLike(String a, String b) {
  final na = norm(a);
  final nb = norm(b);
  if (na.isEmpty || nb.isEmpty) {
    final ta = simTokens(a).join(' ');
    final tb = simTokens(b).join(' ');
    return ta.isNotEmpty &&
        tb.isNotEmpty &&
        (ta.contains(tb) || tb.contains(ta));
  }
  if (_starts(na, nb) || _starts(nb, na)) return true;
  final wa = na.split(' ').toSet();
  final wb = nb.split(' ').where((w) => w.length > 1).toList();
  if (wb.isEmpty) return false;
  final overlap = wb.where(wa.contains).length;
  return (overlap / wb.length) >= 0.7;
}

/// Calculates auto intro offset in milliseconds.
/// Ported from NowPlaying.tsx:introOff.
int introOffMs(List<LyricLine> synced, double? recDurSec, int? trackDurSec) {
  if (synced.isEmpty) return 0;
  final selfEst = (synced.last.startMs / 1000.0) + 12.0;
  final estRecDur = (recDurSec != null && (recDurSec - selfEst).abs() <= 25)
      ? math.max(recDurSec, selfEst)
      : selfEst;

  final dur = trackDurSec ?? 0;
  final g = (dur > 0 && estRecDur > 0)
      ? math.max(-2, math.min(dur - selfEst - 5, dur - estRecDur))
      : 0;

  if (g.abs() < 2.5) return 0;
  final roundedSec = (g * 2).round() / 2.0;
  return (roundedSec * 1000).round();
}

/// Selects the best synced or plain lyrics candidate from a pool.
/// Ported from NowPlaying.tsx:pickLrc.
Lyrics? pickLrc({
  required String refTitle,
  required List<LrclibRecord> pool,
  required String artist,
  int? trackDurationSec,
}) {
  final dur = trackDurationSec ?? 0;

  double closeDiff(LrclibRecord r) {
    return (dur > 0 && r.duration > 0) ? (r.duration - dur).abs() : 999.0;
  }

  bool artistOk(LrclibRecord r) {
    if (artist.isEmpty) return true;
    if (artistSim(r.artistName, artist) > 0) return true;
    return dur > 0 && r.duration > 0 && (r.duration - dur).abs() <= 5;
  }

  final candidates = pool
      .where((r) => titleLike(r.trackName, refTitle) && artistOk(r))
      .toList();

  int compareRecs(LrclibRecord a, LrclibRecord b) {
    final simDiff =
        artistSim(b.artistName, artist) - artistSim(a.artistName, artist);
    if (simDiff != 0) return simDiff;
    return closeDiff(a).compareTo(closeDiff(b));
  }

  // Modal duration check: avoid outlier lying records
  final durBuckets = <int, List<LrclibRecord>>{};
  for (final r in candidates) {
    if ((r.syncedLyrics?.trim().isNotEmpty ?? false) && r.duration > 0) {
      final bucket = r.duration.round();
      durBuckets.putIfAbsent(bucket, () => []).add(r);
    }
  }

  int? modalDuration;
  var maxBucketCount = 0;
  for (final entry in durBuckets.entries) {
    if (entry.value.length > maxBucketCount) {
      maxBucketCount = entry.value.length;
      modalDuration = entry.key;
    }
  }

  final withSynced =
      candidates
          .where((r) => r.syncedLyrics?.trim().isNotEmpty ?? false)
          .toList()
        ..sort(compareRecs);
  final closestRec = withSynced.isNotEmpty ? withSynced.first : null;

  final useModal =
      modalDuration != null &&
      maxBucketCount >= 3 &&
      closestRec != null &&
      (closestRec.duration - modalDuration).abs() > 3 &&
      dur > modalDuration;

  final ordered =
      (useModal
            ? withSynced
                  .where((r) => r.duration.round() == modalDuration)
                  .toList()
            : withSynced)
        ..sort(compareRecs);

  // Check synced candidates
  for (final rec in ordered) {
    final rawLrc = rec.syncedLyrics;
    if (rawLrc == null || rawLrc.isEmpty) continue;
    final lines = parseLrc(rawLrc);
    // Sanity check: at least 4 lines, last line not drifting 20s past track
    if (lines.length >= 4 &&
        (dur == 0 || (lines.last.startMs / 1000.0) <= dur + 20)) {
      final autoOff = introOffMs(lines, rec.duration, dur);
      return SyncedLyrics(
        lines: lines,
        source: 'lrclib',
        fingerprint: sheetFingerprint(lines),
        autoOffsetMs: autoOff,
      );
    }
  }

  // Fallback to plain lyrics
  final withPlain =
      candidates
          .where((r) => r.plainLyrics?.trim().isNotEmpty ?? false)
          .toList()
        ..sort(compareRecs);
  if (withPlain.isNotEmpty) {
    return PlainLyrics(
      text: withPlain.first.plainLyrics!.trim(),
      source: 'lrclib',
    );
  }

  return null;
}

/// Client for LRCLIB API (https://lrclib.net).
/// Searches in parallel across track_name+artist_name, q, and track_name,
/// then /api/get. Implements candidate pooling and pickLrc selection.
class LrclibClient {
  LrclibClient({Dio? dio}) : _dio = dio ?? createDio();

  final Dio _dio;

  static const String baseUrl = 'https://lrclib.net';
  static const String userAgent =
      'AwadyMusic/1.0.0 (https://github.com/awadyeg/Awady-Music)';
  static const Duration requestTimeout = Duration(seconds: 8);

  Future<List<LrclibRecord>> _fetch(
    String path,
    Map<String, dynamic> query,
  ) async {
    try {
      final res = await _dio.get<dynamic>(
        '$baseUrl$path',
        queryParameters: query,
        options: Options(
          headers: {'User-Agent': userAgent},
          sendTimeout: requestTimeout,
          receiveTimeout: requestTimeout,
        ),
      );

      final data = res.data;
      if (data is List) {
        final list = <LrclibRecord>[];
        for (final item in data) {
          if (item is Map) {
            list.add(LrclibRecord.fromJson(Map<String, dynamic>.from(item)));
          }
        }
        return list;
      } else if (data is Map) {
        return [LrclibRecord.fromJson(Map<String, dynamic>.from(data))];
      }
    } on Object catch (e) {
      Log.w('LRCLIB $path failed ($query): $e');
    }
    return const [];
  }

  /// Resolves synced or plain lyrics from LRCLIB for the specified track.
  Future<Lyrics?> getLyrics(
    String rawTitle,
    String rawArtist, {
    int? durationSec,
  }) async {
    final title = cleanTitle(rawTitle);
    final stripped = stripGroups(title);
    final titles = (stripped.isNotEmpty && stripped != title)
        ? [title, stripped]
        : [title];
    final artist = cleanArtist(rawArtist);

    final pool = <LrclibRecord>[];
    final seenIds = <int>{};

    void addToPool(List<LrclibRecord> records) {
      for (final r in records) {
        if (r.id != 0 && seenIds.contains(r.id)) continue;
        if (r.id != 0) seenIds.add(r.id);
        pool.add(r);
      }
    }

    for (final t in titles) {
      final results = await Future.wait([
        _fetch('/api/search', {'track_name': t, 'artist_name': artist}),
        _fetch('/api/search', {'q': '$artist $t'.trim()}),
        _fetch('/api/search', {'track_name': t}),
      ]);

      results.forEach(addToPool);

      final hit = pickLrc(
        refTitle: t,
        pool: pool,
        artist: artist,
        trackDurationSec: durationSec,
      );
      if (hit is SyncedLyrics) {
        return hit;
      }
    }

    // Try /api/get with primary title
    if (titles.isNotEmpty) {
      final exactList = await _fetch('/api/get', {
        'track_name': titles.first,
        'artist_name': artist,
      });
      addToPool(exactList);
    }

    for (final t in titles) {
      final hit = pickLrc(
        refTitle: t,
        pool: pool,
        artist: artist,
        trackDurationSec: durationSec,
      );
      if (hit != null) return hit;
    }

    return null;
  }
}
