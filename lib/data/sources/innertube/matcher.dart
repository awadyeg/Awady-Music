import 'dart:async';

import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';

const _diacriticsMap = {
  'À': 'A',
  'Á': 'A',
  'Â': 'A',
  'Ã': 'A',
  'Ä': 'A',
  'Å': 'A',
  'Æ': 'AE',
  'Ç': 'C',
  'È': 'E',
  'É': 'E',
  'Ê': 'E',
  'Ë': 'E',
  'Ì': 'I',
  'Í': 'I',
  'Î': 'I',
  'Ï': 'I',
  'Ð': 'D',
  'Ñ': 'N',
  'Ò': 'O',
  'Ó': 'O',
  'Ô': 'O',
  'Õ': 'O',
  'Ö': 'O',
  'Ø': 'O',
  'Ù': 'U',
  'Ú': 'U',
  'Û': 'U',
  'Ü': 'U',
  'Ý': 'Y',
  'Þ': 'TH',
  'ß': 'ss',
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'å': 'a',
  'æ': 'ae',
  'ç': 'c',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ð': 'd',
  'ñ': 'n',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ø': 'o',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ý': 'y',
  'þ': 'th',
  'ÿ': 'y',
  'Ā': 'A',
  'ā': 'a',
  'Ă': 'A',
  'ă': 'a',
  'Ą': 'A',
  'ą': 'a',
  'Ć': 'C',
  'ć': 'c',
  'Ĉ': 'C',
  'ĉ': 'c',
  'Ċ': 'C',
  'ċ': 'c',
  'Č': 'C',
  'č': 'c',
  'Ď': 'D',
  'ď': 'd',
  'Đ': 'D',
  'đ': 'd',
  'Ē': 'E',
  'ē': 'e',
  'Ĕ': 'E',
  'ĕ': 'e',
  'Ė': 'E',
  'ė': 'e',
  'Ę': 'E',
  'ę': 'e',
  'Ě': 'E',
  'ě': 'e',
  'Ĝ': 'G',
  'ĝ': 'g',
  'Ğ': 'G',
  'ğ': 'g',
  'Ġ': 'G',
  'ġ': 'g',
  'Ģ': 'G',
  'ģ': 'g',
  'Ĥ': 'H',
  'ĥ': 'h',
  'Ħ': 'H',
  'ħ': 'h',
  'Ĩ': 'I',
  'ĩ': 'i',
  'Ī': 'I',
  'ī': 'i',
  'Ĭ': 'I',
  'ĭ': 'i',
  'Į': 'I',
  'į': 'i',
  'İ': 'I',
  'ı': 'i',
  'Ĳ': 'IJ',
  'ĳ': 'ij',
  'Ĵ': 'J',
  'ĵ': 'j',
  'Ķ': 'K',
  'ķ': 'k',
  'ĸ': 'k',
  'Ĺ': 'L',
  'ĺ': 'l',
  'Ļ': 'L',
  'ļ': 'l',
  'Ľ': 'L',
  'ľ': 'l',
  'Ŀ': 'L',
  'ŀ': 'l',
  'Ł': 'L',
  'ł': 'l',
  'Ń': 'N',
  'ń': 'n',
  'Ņ': 'N',
  'ņ': 'n',
  'Ň': 'N',
  'ň': 'n',
  'ŉ': 'n',
  'Ŋ': 'N',
  'ŋ': 'n',
  'Ō': 'O',
  'ō': 'o',
  'Ŏ': 'O',
  'ŏ': 'o',
  'Ő': 'O',
  'ő': 'o',
  'Œ': 'OE',
  'œ': 'oe',
  'Ŕ': 'R',
  'ŕ': 'r',
  'Ŗ': 'R',
  'ŗ': 'r',
  'Ř': 'R',
  'ř': 'r',
  'Ś': 'S',
  'ś': 's',
  'Ŝ': 'S',
  'ŝ': 's',
  'Ş': 'S',
  'ş': 's',
  'Š': 'S',
  'š': 's',
  'Ţ': 'T',
  'ţ': 't',
  'Ť': 'T',
  'ť': 't',
  'Ŧ': 'T',
  'ŧ': 't',
  'Ũ': 'U',
  'ũ': 'u',
  'Ū': 'U',
  'ū': 'u',
  'Ŭ': 'U',
  'ŭ': 'u',
  'Ů': 'U',
  'ů': 'u',
  'Ű': 'U',
  'ű': 'u',
  'Ų': 'U',
  'ų': 'u',
  'Ŵ': 'W',
  'ŵ': 'w',
  'Ŷ': 'Y',
  'ŷ': 'y',
  'Ÿ': 'Y',
  'Ź': 'Z',
  'ź': 'z',
  'Ż': 'Z',
  'ż': 'z',
  'Ž': 'Z',
  'ž': 'z',
};

/// Folds diacritics and accents into plain ASCII and lowercases the text.
String fold(String? s) {
  if (s == null || s.isEmpty) return '';
  final buf = StringBuffer();
  for (final char in s.split('')) {
    buf.write(_diacriticsMap[char] ?? char);
  }
  return buf.toString().toLowerCase();
}

final _junkWordRegex = RegExp(
  r'\b(feat\.?|ft\.?|featuring|remaster(?:ed)?|mono|stereo|explicit|deluxe|anniversary|bonus track|with)\b',
  caseSensitive: false,
);

final _tailJunkRegex = RegExp(
  r'\s+-\s+(?:\d{4}\s+)?(?:remaster(?:ed)?(?:\s+\d{4})?|album version|single version)\s*$',
  caseSensitive: false,
);

/// Cleans song title by folding accents, stripping junk words in parentheses
/// and brackets, dropping trailing remaster indicators, and normalizing spaces.
///
/// Example: "Song (feat. X) [Remastered 2011] - Remastered" -> "song"
String cleanText(String? s) {
  if (s == null || s.isEmpty) return '';
  var text = fold(s);

  text = text.replaceAllMapped(RegExp(r'\(([^)]*)\)'), (m) {
    final inner = m.group(1) ?? '';
    return _junkWordRegex.hasMatch(inner) ? ' ' : m.group(0)!;
  });

  text = text.replaceAllMapped(RegExp(r'\[([^\]]*)\]'), (m) {
    final inner = m.group(1) ?? '';
    return _junkWordRegex.hasMatch(inner) ? ' ' : m.group(0)!;
  });

  text = text.replaceAll(_tailJunkRegex, ' ');
  text = text.replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ');

  return text.trim();
}

/// Extracts the first artist name from multi-artist strings.
///
/// Example: "Queen & David Bowie" -> "queen"
String firstArtist(String? artist) {
  if (artist == null || artist.isEmpty) return '';
  final folded = fold(artist);
  final split = folded.split(
    RegExp(r'\s*(?:,|&|/|;)\s*|\s+(?:feat\.?|ft\.?|with|x)\s+'),
  );
  return cleanText(split.isNotEmpty ? split[0] : '');
}

/// Generates a normalized match key for caching (e.g. "artist title").
String matchKey(String title, String artist) {
  final a = firstArtist(artist);
  final t = cleanText(title);
  return a.isNotEmpty ? '$a $t'.trim() : t;
}

/// Scores a candidate [track] against target [wantTitle], [wantArtist], and
/// [wantDuration].
///
/// Ported exactly from upstream `youtube.cjs:matchScore`.
double matchScore({
  required Track track,
  required String wantTitle,
  required String wantArtist,
  int wantDuration = 0,
}) {
  var score = 0.0;
  final want = cleanText(wantTitle);
  final got = cleanText(track.title);
  if (want.isNotEmpty && got.isNotEmpty) {
    if (got == want) {
      score += 3.0;
    } else if (got.contains(want) || want.contains(got)) {
      score += 1.5;
    }
  }

  final wantA = firstArtist(wantArtist);
  final gotA = cleanText(track.artist.name);
  if (wantA.isNotEmpty &&
      gotA.isNotEmpty &&
      (gotA.contains(wantA) || wantA.contains(gotA))) {
    score += 1.5;
  }

  if (wantDuration > 0 && track.duration > 0) {
    final d = (track.duration - wantDuration).abs();
    if (d <= 3) {
      score += 3.0;
    } else if (d <= 8) {
      score += 1.5;
    } else if (d > 30) {
      score -= 1.5;
    }
  }

  return score;
}

/// Represents an item query for batch track matching.
class MatchQuery {
  const MatchQuery({
    required this.title,
    required this.artist,
    this.duration = 0,
  });

  final String title;
  final String artist;
  final int duration;
}

/// Resolves a single [MatchQuery] against YouTube Music using scored candidate
/// ranking.
Future<Track?> matchSingleTrack(
  InnertubeClient client,
  MatchQuery query,
) async {
  final queries = <String>[];
  final a = firstArtist(query.artist);
  if (a.isNotEmpty) {
    queries.add('$a ${query.title}'.trim());
  }
  final full = '${query.artist} ${query.title}'.trim();
  if (full.isNotEmpty && !queries.contains(full)) {
    queries.add(full);
  }
  if (queries.isEmpty) {
    queries.add(query.title);
  }

  for (final q in queries) {
    final truncated = q.length > 200 ? q.substring(0, 200) : q;
    final searchResults = await client.search(truncated);
    final hits = searchResults.tracks;
    if (hits.isEmpty) continue;

    if (query.duration > 0) {
      var best = hits.first;
      var bestScore = matchScore(
        track: best,
        wantTitle: query.title,
        wantArtist: query.artist,
        wantDuration: query.duration,
      );
      for (var i = 1; i < hits.length; i++) {
        final candidate = hits[i];
        final score = matchScore(
          track: candidate,
          wantTitle: query.title,
          wantArtist: query.artist,
          wantDuration: query.duration,
        );
        if (score > bestScore) {
          best = candidate;
          bestScore = score;
        }
      }
      return best;
    }

    return hits.first;
  }

  return null;
}
