import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/track.dart';

bool isValidUser(dynamic v) {
  if (v is! Map) return false;
  final id = v['id'];
  final name = v['name'];
  return id is String && id.isNotEmpty && name is String;
}

bool isPlayableTrack(Track t) => t.isStreamable;

bool isValidTrack(dynamic t) {
  if (t is Track) {
    return t.id.isNotEmpty && t.title.isNotEmpty && isPlayableTrack(t);
  }
  if (t is! Map) return false;

  final id = t['id'];
  final title = t['title'];
  if (id is! String || title is! String) return false;

  final u = t['user'] ?? t['artist'];
  if (!isValidUser(u)) return false;

  final duration = t['duration'];
  if (duration != null) {
    if (duration is! num) return false;
    if (duration.isNaN || duration.isInfinite) return false;
  }

  return true;
}

Track repairTrack(Track t) {
  var out = t;

  if (t.id.startsWith('yt-') && (t.streamId == null || t.streamId!.isEmpty)) {
    out = out.copyWith(streamId: t.id.substring(3), source: TrackSource.yt);
  }

  final art = out.artwork;
  if (art != null) {
    String? cleanUrl(String? u) {
      if (u == null) return null;
      return u.replaceAllMapped(
        RegExp(r'(ytimg\.com/[^?]+)\?.*$'),
        (m) => m.group(1) ?? u,
      );
    }

    final new150 = cleanUrl(art.s150);
    final new480 = cleanUrl(art.s480);
    final new1000 = cleanUrl(art.s1000);

    final vid =
        out.streamId ?? (out.id.startsWith('yt-') ? out.id.substring(3) : null);

    var fallback = art.fallback;
    if (vid != null && (fallback == null || fallback.isEmpty)) {
      fallback = 'https://i.ytimg.com/vi/$vid/hqdefault.jpg';
    }

    final updatedArt = art.copyWith(
      s150: new150,
      s480: new480,
      s1000: new1000,
      fallback: fallback,
    );

    out = out.copyWith(artwork: updatedArt);
  }

  return out;
}

Track slimTrack(Track t) {
  return t.copyWith(artist: slimUser(t.artist));
}

Artist slimUser(Artist u) {
  return u.copyWith(bio: null, coverPhoto: null);
}

List<Track> sanitizeTrackList(dynamic v, int cap) {
  if (v is! List) return <Track>[];

  final result = <Track>[];
  for (final item in v) {
    if (item is Track) {
      result.add(slimTrack(repairTrack(item)));
    } else if (isValidTrack(item)) {
      try {
        final parsed = Track.fromJson(Map<String, dynamic>.from(item as Map));
        result.add(slimTrack(repairTrack(parsed)));
      } on Object catch (_) {
        // Skip unparseable
      }
    }
    if (result.length >= cap) break;
  }

  return result;
}
