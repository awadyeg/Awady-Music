import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

@immutable
class ImportEntry {
  const ImportEntry({required this.title, required this.artist, this.duration});

  factory ImportEntry.fromJson(Map<String, dynamic> json) => ImportEntry(
    title: json['title'] as String? ?? '',
    artist: json['artist'] as String? ?? '',
    duration: json['duration'] as int?,
  );

  final String title;
  final String artist;
  final int? duration;

  Map<String, dynamic> toJson() => {
    'title': title,
    'artist': artist,
    if (duration != null) 'duration': duration,
  };

  @override
  String toString() =>
      'ImportEntry(title: $title, artist: $artist, duration: $duration)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImportEntry &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          artist == other.artist &&
          duration == other.duration;

  @override
  int get hashCode => Object.hash(title, artist, duration);
}

@immutable
class SpotifyImportResult {
  const SpotifyImportResult({
    required this.ok,
    this.name = '',
    this.tracks = const [],
    this.limited = false,
    this.source = '',
  });

  static const failed = SpotifyImportResult(ok: false);

  final bool ok;
  final String name;
  final List<ImportEntry> tracks;
  final bool limited;
  final String source;
}

class SpotifyEmbedResult {
  const SpotifyEmbedResult({
    required this.name,
    required this.total,
    required this.token,
    required this.tracks,
  });

  final String name;
  final int total;
  final String? token;
  final List<ImportEntry> tracks;
}

class SpotifyParsedPage {
  const SpotifyParsedPage(this.name, this.itemsCount, this.total, this.tracks);

  final String name;
  final int itemsCount;
  final int total;
  final List<ImportEntry> tracks;
}

class SpotifyPathfinderResult {
  const SpotifyPathfinderResult({
    required this.name,
    required this.tracks,
    required this.total,
  });

  final String name;
  final List<ImportEntry> tracks;
  final int total;
}

class SpotifyImporter {
  SpotifyImporter({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              headers: {
                'User-Agent': userAgent,
                'Accept-Language': 'en-US,en;q=0.9',
              },
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
            ),
          );

  static const String pathfinderUrl =
      'https://api-partner.spotify.com/pathfinder/v1/query';
  static const String fetchPlaylistHash =
      '8964e8eafb21aa992a7d951d256d83285c04be2105d209262901de70cb97584a';
  static const int pageSize = 100;
  static const int maxPages = 100;
  static const int pageConcurrency = 5;

  static const String userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  static final RegExp spotifyIdPattern = RegExp(r'^[A-Za-z0-9]{10,40}$');
  static final RegExp spotifyUrlPattern = RegExp(
    r'open\.spotify\.com/playlist/([A-Za-z0-9]+)',
  );
  static final RegExp spotifyUriPattern = RegExp(
    'spotify:playlist:([A-Za-z0-9]+)',
  );

  final Dio _dio;

  static String? extractPlaylistId(String input) {
    final trimmed = input.trim();
    final urlMatch = spotifyUrlPattern.firstMatch(trimmed);
    if (urlMatch != null) return urlMatch.group(1);

    final uriMatch = spotifyUriPattern.firstMatch(trimmed);
    if (uriMatch != null) return uriMatch.group(1);

    if (spotifyIdPattern.hasMatch(trimmed)) return trimmed;
    return null;
  }

  Future<SpotifyImportResult> importPlaylist(String input) async {
    final id = extractPlaylistId(input);
    if (id == null) return SpotifyImportResult.failed;

    try {
      final emb = await fetchEmbed(id);
      if (emb == null) return SpotifyImportResult.failed;

      if (emb.token != null && emb.token!.isNotEmpty) {
        final full = await pathfinder(id, emb.token!);
        if (full != null && full.tracks.length >= emb.tracks.length) {
          return SpotifyImportResult(
            ok: true,
            source: 'pathfinder',
            name: full.name.isNotEmpty ? full.name : emb.name,
            tracks: full.tracks,
            limited: full.tracks.length < full.total,
          );
        }
      }

      return SpotifyImportResult(
        ok: true,
        source: 'embed',
        name: emb.name,
        tracks: emb.tracks,
        limited: emb.total > emb.tracks.length || emb.tracks.length >= 100,
      );
    } on Object {
      return SpotifyImportResult.failed;
    }
  }

  Future<SpotifyEmbedResult?> fetchEmbed(String id) async {
    try {
      final response = await _dio.get<String>(
        'https://open.spotify.com/embed/playlist/$id',
        options: Options(
          headers: {
            'User-Agent': userAgent,
            'Accept-Language': 'en-US,en;q=0.9',
          },
        ),
      );
      if (response.statusCode != 200 || response.data == null) return null;
      return parseEmbed(response.data!);
    } on Object {
      return null;
    }
  }

  static SpotifyEmbedResult? parseEmbed(String html) {
    var text = html;
    if (text.startsWith('"') && text.endsWith('"')) {
      try {
        final dynamic unquoted = jsonDecode(text);
        if (unquoted is String) text = unquoted;
      } on Object {
        // Ignored.
      }
    }

    final match = RegExp(
      r'<script id="__NEXT_DATA__" type="application/json">([\s\S]*?)</script>',
    ).firstMatch(text);
    if (match == null) return null;

    final jsonStr = match.group(1);
    if (jsonStr == null) return null;

    try {
      final dynamic parsed = jsonDecode(jsonStr);
      if (parsed is! Map<String, dynamic>) return null;
      final props = parsed['props'];
      if (props is! Map<String, dynamic>) return null;
      final pageProps = props['pageProps'];
      if (pageProps is! Map<String, dynamic>) return null;

      final state = pageProps['state'];
      if (state is! Map<String, dynamic>) return null;

      final data = state['data'];
      final entity = data is Map<String, dynamic> ? data['entity'] : null;
      if (entity is! Map<String, dynamic>) return null;

      final name = entity['name']?.toString() ?? '';
      final trackList = entity['trackList'];
      if (name.isEmpty || trackList is! List || trackList.isEmpty) return null;

      final dynamic totalCount = entity['totalCount'];
      final total = totalCount is num ? totalCount.toInt() : trackList.length;

      final settings = state['settings'];
      final session = settings is Map<String, dynamic>
          ? settings['session']
          : null;
      final token = session is Map<String, dynamic>
          ? session['accessToken']?.toString()
          : null;

      final tracks = <ImportEntry>[];
      for (final item in trackList) {
        if (item is Map) {
          final title = item['title']?.toString();
          final subtitle = item['subtitle']?.toString();
          if (title != null && subtitle != null && title.isNotEmpty) {
            tracks.add(ImportEntry(title: title, artist: subtitle));
          }
        }
      }

      if (tracks.isEmpty) return null;
      return SpotifyEmbedResult(
        name: name,
        total: total,
        token: token,
        tracks: tracks,
      );
    } on Object {
      return null;
    }
  }

  static ImportEntry? mapItem(dynamic item) {
    if (item is! Map) return null;
    final itemMap = Map<String, dynamic>.from(item);
    final dynamic v2 = itemMap['itemV2'];
    final dynamic v3 = itemMap['itemV3'];
    final dynamic rawItem = itemMap['item'];

    final dynamic t =
        (v2 is Map ? v2['data'] : null) ??
        (v3 is Map ? v3['data'] : null) ??
        (rawItem is Map ? rawItem['data'] : null);
    if (t is! Map) return null;
    final tMap = Map<String, dynamic>.from(t);

    final typeName = tMap['__typename']?.toString();
    if (typeName != null && typeName != 'Track') return null;

    final title = (tMap['name']?.toString() ?? '').trim();
    final dynamic artistsData = tMap['artists'];
    final dynamic albumOfTrack = tMap['albumOfTrack'];
    final dynamic artistItems =
        (artistsData is Map ? artistsData['items'] : null) ??
        (albumOfTrack is Map && albumOfTrack['artists'] is Map
            ? (albumOfTrack['artists'] as Map)['items']
            : null);

    final artists = <String>[];
    if (artistItems is List) {
      for (final a in artistItems) {
        if (a is Map) {
          final profile = a['profile'];
          final name = profile is Map ? profile['name']?.toString() : null;
          if (name != null && name.trim().isNotEmpty) {
            artists.add(name.trim());
          }
        }
      }
    }

    if (title.isEmpty || artists.isEmpty) return null;
    final dynamic durationData = tMap['trackDuration'];
    final dynamic msVal = durationData is Map
        ? durationData['totalMilliseconds']
        : null;
    int? duration;
    if (msVal is num && msVal > 0) {
      duration = (msVal / 1000).round();
    }

    return ImportEntry(
      title: title,
      artist: artists.join(', '),
      duration: duration,
    );
  }

  Future<SpotifyPathfinderResult?> pathfinder(String id, String token) async {
    final uri = 'spotify:playlist:$id';
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'text/html,application/json',
      'Referer': 'https://open.spotify.com/',
      'Accept-Language': 'en-US,en;q=0.9',
      'User-Agent': userAgent,
    };

    Future<Map<String, dynamic>?> fetchPage(int offset) async {
      final body = {
        'variables': {
          'uri': uri,
          'offset': offset,
          'limit': pageSize,
          'enableWatchFeedEntrypoint': true,
        },
        'operationName': 'fetchPlaylist',
        'extensions': {
          'persistedQuery': {'version': 1, 'sha256Hash': fetchPlaylistHash},
        },
      };

      try {
        final res = await _dio.post<dynamic>(
          pathfinderUrl,
          data: body,
          options: Options(headers: headers),
        );
        if (res.statusCode != 200 || res.data == null) return null;
        final dynamic data = res.data is String
            ? jsonDecode(res.data as String)
            : res.data;
        if (data is Map && data['data'] is Map) {
          final playlist = (data['data'] as Map)['playlistV2'];
          if (playlist is Map) return Map<String, dynamic>.from(playlist);
        }
        return null;
      } on Object {
        return null;
      }
    }

    SpotifyParsedPage parsePage(Map<String, dynamic>? raw) {
      if (raw == null) return const SpotifyParsedPage('', 0, 0, []);
      final name = raw['name']?.toString() ?? '';
      final dynamic content = raw['content'];
      final items = content is Map && content['items'] is List
          ? content['items'] as List<dynamic>
          : const <dynamic>[];
      final tracks = <ImportEntry>[];
      for (final it in items) {
        final t = mapItem(it);
        if (t != null) tracks.add(t);
      }
      final dynamic totalCount = content is Map ? content['totalCount'] : null;
      final total = totalCount is num ? totalCount.toInt() : 0;
      return SpotifyParsedPage(name, items.length, total, tracks);
    }

    final first = await fetchPage(0);
    if (first == null) return null;
    final head = parsePage(first);
    final total = head.total > 0 ? head.total : head.itemsCount;
    final tracks = List<ImportEntry>.from(head.tracks);
    var name = head.name;

    final offsets = <int>[];
    for (
      var o = pageSize;
      o < total && offsets.length < maxPages;
      o += pageSize
    ) {
      offsets.add(o);
    }

    for (var i = 0; i < offsets.length; i += pageConcurrency) {
      final end = (i + pageConcurrency < offsets.length)
          ? i + pageConcurrency
          : offsets.length;
      final batch = offsets.sublist(i, end);
      final pages = await Future.wait(batch.map(fetchPage));

      var stopped = false;
      for (final raw in pages) {
        if (raw == null) {
          stopped = true;
          break;
        }
        final p = parsePage(raw);
        if (name.isEmpty) name = p.name;
        tracks.addAll(p.tracks);
      }
      if (stopped) break;
    }

    if (tracks.isEmpty) return null;
    return SpotifyPathfinderResult(name: name, tracks: tracks, total: total);
  }
}
