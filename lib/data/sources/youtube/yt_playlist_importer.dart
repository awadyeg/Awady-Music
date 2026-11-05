import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:flutter/foundation.dart';

@immutable
class YtPlaylistImportResult {
  const YtPlaylistImportResult({
    required this.ok,
    this.id = '',
    this.name = '',
    this.tracks = const [],
    this.source = 'yt',
  });

  static const failed = YtPlaylistImportResult(ok: false);

  final bool ok;
  final String id;
  final String name;
  final List<Track> tracks;
  final String source;
}

class YtPlaylistImporter {
  YtPlaylistImporter({InnertubeClient? innertube})
    : _innertube = innertube ?? InnertubeClient();

  static final RegExp ytListPattern = RegExp('[?&]list=([A-Za-z0-9_-]+)');
  static final RegExp ytIdPattern = RegExp(
    r'^(VL)?(PL|RD|OLAK)[A-Za-z0-9_-]+$',
  );

  final InnertubeClient _innertube;

  static String? extractPlaylistId(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    final match = ytListPattern.firstMatch(trimmed);
    if (match != null) {
      final id = match.group(1);
      if (id != null && id.isNotEmpty) {
        return id.replaceFirst(RegExp('^VL'), '');
      }
    }

    if (ytIdPattern.hasMatch(trimmed)) {
      return trimmed.replaceFirst(RegExp('^VL'), '');
    }

    if (trimmed.length >= 12 && RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(trimmed)) {
      return trimmed.replaceFirst(RegExp('^VL'), '');
    }

    return null;
  }

  Future<YtPlaylistImportResult> importPlaylist(String input) async {
    final id = extractPlaylistId(input);
    if (id == null) return YtPlaylistImportResult.failed;

    try {
      final page = await _innertube.playlist(id);
      if (page.tracks.isEmpty) {
        return YtPlaylistImportResult.failed;
      }

      return YtPlaylistImportResult(
        ok: true,
        id: id,
        name: page.playlist.name.isNotEmpty
            ? page.playlist.name
            : 'Imported Playlist',
        tracks: page.tracks,
      );
    } on Object {
      return YtPlaylistImportResult.failed;
    }
  }
}
