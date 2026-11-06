import 'dart:convert';

import 'package:awady_music/data/models/import_entry.dart';
import 'package:flutter/foundation.dart';

@immutable
class ParsedPlaylistFile {
  const ParsedPlaylistFile({required this.name, required this.entries});

  final String name;
  final List<ImportEntry> entries;
}

class _ParseArgs {
  const _ParseArgs(this.text, this.defaultName);
  final String text;
  final String defaultName;
}

ParsedPlaylistFile _parseJsonComputeEntrypoint(_ParseArgs args) =>
    PlaylistFileParser.parseJson(args.text, defaultName: args.defaultName);

ParsedPlaylistFile _parseCsvComputeEntrypoint(_ParseArgs args) =>
    PlaylistFileParser.parseCsv(args.text, defaultName: args.defaultName);

class PlaylistFileParser {
  static const int maxEntries = 5000;

  static List<List<String>> csvRows(String text) {
    final rows = <List<String>>[];
    var cur = '';
    var inQ = false;
    var row = <String>[];

    for (var i = 0; i < text.length; i++) {
      final c = text[i];
      if (inQ) {
        if (c == '"' && i + 1 < text.length && text[i + 1] == '"') {
          cur += '"';
          i++;
        } else if (c == '"') {
          inQ = false;
        } else {
          cur += c;
        }
      } else if (c == '"') {
        inQ = true;
      } else if (c == ',') {
        row.add(cur);
        cur = '';
      } else if (c == '\n' || c == '\r') {
        if (c == '\r' && i + 1 < text.length && text[i + 1] == '\n') {
          i++;
        }
        row.add(cur);
        cur = '';
        if (row.any((f) => f.trim().isNotEmpty)) {
          rows.add(row);
        }
        row = <String>[];
      } else {
        cur += c;
      }
    }

    row.add(cur);
    if (row.any((f) => f.trim().isNotEmpty)) {
      rows.add(row);
    }
    return rows;
  }

  static (int titleIndex, int artistIndex) findCols(List<String> header) {
    final h = header.map((s) => s.trim().toLowerCase()).toList();

    var title = h.indexWhere(
      (s) =>
          RegExp(r'^(track name|track title|title|name|song|song name)$')
              .hasMatch(s),
    );
    if (title < 0) {
      title = h.indexWhere((s) => RegExp('track name|song name').hasMatch(s));
    }

    final artist = h.indexWhere((s) => RegExp('artist').hasMatch(s));

    return (title >= 0 ? title : 0, artist >= 0 ? artist : 1);
  }

  static ParsedPlaylistFile parseCsv(
    String csvText, {
    String defaultName = 'Imported Playlist',
  }) {
    final rows = csvRows(csvText);
    if (rows.length < 2) {
      throw const FormatException('CSV file has no data rows');
    }

    final (titleIndex, artistIndex) = findCols(rows[0]);
    final headerLower = rows[0].map((s) => s.trim().toLowerCase()).toList();
    final durationIndex = headerLower.indexWhere((s) => s.contains('duration'));
    final entries = <ImportEntry>[];

    for (var i = 1; i < rows.length && entries.length < maxEntries; i++) {
      final row = rows[i];
      final title = titleIndex < row.length ? row[titleIndex].trim() : '';
      final artist = artistIndex < row.length ? row[artistIndex].trim() : '';
      int? duration;
      if (durationIndex >= 0 && durationIndex < row.length) {
        final rawDur = int.tryParse(row[durationIndex].trim());
        if (rawDur != null && rawDur > 0) {
          duration = rawDur > 1000 ? (rawDur / 1000).round() : rawDur;
        }
      }
      if (title.isNotEmpty || artist.isNotEmpty) {
        entries.add(
          ImportEntry(title: title, artist: artist, duration: duration),
        );
      }
    }

    if (entries.isEmpty) {
      throw const FormatException('No tracks found in CSV');
    }

    return ParsedPlaylistFile(name: defaultName, entries: entries);
  }

  static ParsedPlaylistFile parseJson(
    String jsonText, {
    String defaultName = 'Imported Playlist',
  }) {
    final dynamic j = jsonDecode(jsonText);
    if (j is! Map<String, dynamic>) {
      throw const FormatException('Invalid JSON');
    }

    final app = j['app']?.toString();
    if (app == null) {
      // Support Spotify GDPR YourLibrary.json and Playlist1.json exports
      final dynamic spotifyPlaylists = j['playlists'];
      if (spotifyPlaylists is List && spotifyPlaylists.isNotEmpty) {
        final firstPl = spotifyPlaylists.first;
        if (firstPl is Map) {
          final plName = firstPl['name']?.toString().trim() ?? defaultName;
          final items = firstPl['items'];
          if (items is List) {
            final entries = <ImportEntry>[];
            for (final it in items) {
              if (it is Map) {
                final tr = it['track'] is Map ? it['track'] as Map : it;
                final title =
                    (tr['trackName'] ?? tr['name'] ?? tr['title'] ?? '')
                        .toString()
                        .trim();
                final artist = (tr['artistName'] ?? tr['artist'] ?? '')
                    .toString()
                    .trim();
                if (title.isNotEmpty || artist.isNotEmpty) {
                  entries.add(ImportEntry(title: title, artist: artist));
                }
              }
              if (entries.length >= maxEntries) break;
            }
            if (entries.isNotEmpty) {
              return ParsedPlaylistFile(
                name: plName.isNotEmpty ? plName : defaultName,
                entries: entries,
              );
            }
          }
        }
      }

      final dynamic rawTracks = j['tracks'];
      if (rawTracks is List && rawTracks.isNotEmpty) {
        final entries = <ImportEntry>[];
        for (final tr in rawTracks) {
          if (tr is Map &&
              (tr.containsKey('track') || tr.containsKey('trackName'))) {
            final title = (tr['track'] ?? tr['trackName'] ?? '')
                .toString()
                .trim();
            final artist = (tr['artist'] ?? tr['artistName'] ?? '')
                .toString()
                .trim();
            if (title.isNotEmpty || artist.isNotEmpty) {
              entries.add(ImportEntry(title: title, artist: artist));
            }
          }
          if (entries.length >= maxEntries) break;
        }
        if (entries.isNotEmpty) {
          return ParsedPlaylistFile(name: 'Liked Songs', entries: entries);
        }
      }
    }

    if (app != 'freebify' && app != 'awadymusic') {
      throw const FormatException('Not a supported playlist backup');
    }

    final type = j['type']?.toString();
    if (type != 'playlist') {
      throw const FormatException('Not a playlist backup');
    }

    final dynamic tracks = j['tracks'];
    if (tracks is! List) {
      throw const FormatException('Missing tracks list');
    }

    final entries = <ImportEntry>[];
    for (final tr in tracks) {
      if (tr is Map) {
        final title = tr['title']?.toString().trim() ?? '';
        final dynamic userMap = tr['user'];
        final artist =
            tr['artist']?.toString().trim() ??
            (userMap is Map ? userMap['name']?.toString().trim() : '') ??
            '';
        final dynamic durVal = tr['duration'];
        final duration = durVal is num ? durVal.toInt() : null;

        if (title.isNotEmpty || artist.isNotEmpty) {
          entries.add(
            ImportEntry(title: title, artist: artist, duration: duration),
          );
        }
      }
      if (entries.length >= maxEntries) break;
    }

    if (entries.isEmpty) {
      throw const FormatException('No tracks in playlist');
    }

    final name =
        (j['name'] is String && (j['name'] as String).trim().isNotEmpty)
        ? (j['name'] as String).trim()
        : defaultName;

    return ParsedPlaylistFile(name: name, entries: entries);
  }

  static Future<ParsedPlaylistFile> parseJsonCompute(
    String jsonText, {
    String defaultName = 'Imported Playlist',
  }) {
    return compute(
      _parseJsonComputeEntrypoint,
      _ParseArgs(jsonText, defaultName),
    );
  }

  static Future<ParsedPlaylistFile> parseCsvCompute(
    String csvText, {
    String defaultName = 'Imported Playlist',
  }) {
    return compute(
      _parseCsvComputeEntrypoint,
      _ParseArgs(csvText, defaultName),
    );
  }
}
