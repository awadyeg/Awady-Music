import 'dart:async';
import 'dart:math' as math;

import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String audiusAppName = 'AwadyMusic';
const String audiusBootstrapHost = 'https://api.audius.co';

/// Curated Audius genres for browsing.
const List<String> audiusGenres = [
  'Electronic',
  'Hip-Hop/Rap',
  'Pop',
  'Rock',
  'R&B/Soul',
  'Latin',
  'Techno',
  'House',
  'Trap',
  'Dubstep',
  'Drum & Bass',
  'Trance',
  'Lo-Fi',
  'Ambient',
  'Jazz',
  'Funk',
  'Acoustic',
  'Alternative',
  'Metal',
  'Punk',
  'Reggae',
  'Dancehall',
  'Hyperpop',
  'Vaporwave',
];

/// Strong non-original terms.
final RegExp audiusStrongRegExp = RegExp(
  r"(re-?mix(ed|es|ing)?|mash ?ups?|bootlegs?|re-?edits?|vip mix(es)?|club mix(es)?|extended (mix|versions?)|dj[ -_]?(sets?|mix(es)?)|megamix(es)?|mixtapes?|sped[- ]?up|speed[- ]?up|slowed( +(&|and|n'|’) +reverb)?|nightcore|daycore|type beats?|sample packs?|loop kits?|drum kits?|accent samples?|radio mixes?|festival mixes?|cover versions?|bass boosted|8d audio|\blive (at|version|session)|unplugged|\bdemos?\b|radio edit|orchestral version|piano version|refix)",
  caseSensitive: false,
);

/// Weak terms that appear in brackets, colons, or dashes.
final RegExp audiusWeakRegExp = RegExp(
  r'[(\[\-:]\s*(edits?|vip|flips?|karaoke|tributes?|a ?cappellas?|acapellas?|instrumentals?|covers?|live|acoustic|single version|rework)\b\s*[)\]]?',
  caseSensitive: false,
);

/// Direct search queries that explicitly ask for non-originals.
final RegExp audiusNonOriginalQueryRegExp = RegExp(
  r'\b(remix|mashup|bootleg|nightcore|sped.?up|slowed|karaoke|cover)\b',
  caseSensitive: false,
);

/// Returns true if query explicitly asks for non-original content.
bool isNonOriginalQuery(String q) {
  return audiusStrongRegExp.hasMatch(q) ||
      audiusWeakRegExp.hasMatch(q) ||
      audiusNonOriginalQueryRegExp.hasMatch(q);
}

/// Returns true if a track is detected as non-original (remix, edit,
/// set, etc.).
bool isNonOriginal(Map<String, dynamic> raw) {
  if (raw['remix_of'] != null) return true;
  final title = (raw['title'] as String?) ?? '';
  final tags = (raw['tags'] as String?) ?? '';
  return audiusStrongRegExp.hasMatch('$title $tags') ||
      audiusWeakRegExp.hasMatch(title);
}

/// Duration >= 10 minutes indicates DJ sets, podcasts, or full mixes.
bool isLongForm(int durationSeconds) => durationSeconds >= 600;

/// Scoring function prioritizing verified originals over remixes/sets.
double scoreTrack(Map<String, dynamic> raw) {
  final playCount = (raw['play_count'] as num?)?.toDouble() ?? 0.0;
  var s = math.log(playCount + 10) / math.ln10;

  final user = raw['user'];
  final isVerified =
      user is Map<String, dynamic> && (user['is_verified'] as bool? ?? false);
  if (isVerified) s += 1.5;
  if (isNonOriginal(raw)) s -= 4.0;

  final duration = (raw['duration'] as num?)?.toInt() ?? 0;
  if (isLongForm(duration)) s -= 2.0;

  final isStreamGated = raw['is_stream_gated'] as bool? ?? false;
  if (isStreamGated) s -= 10.0;

  final isStreamable = raw['is_streamable'] as bool? ?? true;
  if (!isStreamable) s -= 10.0;

  return s;
}

/// Sorts raw track maps by descending originality score.
List<Map<String, dynamic>> rankRawTracks(List<Map<String, dynamic>> tracks) {
  final copy = List<Map<String, dynamic>>.from(tracks)
    ..sort((a, b) => scoreTrack(b).compareTo(scoreTrack(a)));
  return copy;
}

/// Cleans, filters, ranks, and maps raw track objects into [Track] instances.
List<Track> cleanAndMapTracks(
  dynamic data, {
  bool rank = false,
  bool filterUnplayable = true,
}) {
  if (data is! List) return const [];
  final seen = <String>{};
  final valid = <Map<String, dynamic>>[];

  for (final item in data) {
    if (item is! Map<String, dynamic>) continue;
    final id = item['id'];
    final title = item['title'];
    final user = item['user'];

    if (id is! String || id.isEmpty) continue;
    if (title is! String || title.isEmpty) continue;
    if (user is! Map<String, dynamic>) continue;

    final userId = user['id'];
    final userName = user['name'];
    if (userId is! String || userId.isEmpty) continue;
    if (userName is! String || userName.isEmpty) continue;

    if (seen.contains(id)) continue;

    if (filterUnplayable) {
      if (item['is_stream_gated'] == true) continue;
      if (item['is_streamable'] == false) continue;
    }

    seen.add(id);
    valid.add(item);
  }

  final ordered = rank ? rankRawTracks(valid) : valid;
  return ordered.map((raw) {
    final copy = Map<String, dynamic>.from(raw);
    copy['streamId'] ??= copy['id'];
    return Track.fromJson(copy);
  }).toList();
}

/// Cleans and maps raw user objects into [Artist] instances.
List<Artist> cleanAndMapUsers(dynamic data) {
  if (data is! List) return const [];
  final results = <Artist>[];
  for (final item in data) {
    if (item is! Map<String, dynamic>) continue;
    final id = item['id'];
    final name = item['name'];
    if (id is! String || id.isEmpty) continue;
    if (name is! String || name.isEmpty) continue;
    results.add(Artist.fromJson(item));
  }
  return results;
}

/// Cleans and maps raw playlist objects into [RemotePlaylist] instances.
List<RemotePlaylist> cleanAndMapPlaylists(dynamic data) {
  if (data is! List) return const [];
  final results = <RemotePlaylist>[];
  for (final item in data) {
    if (item is! Map<String, dynamic>) continue;
    final id = item['id'];
    final name = item['name'] ?? item['playlist_name'];
    final user = item['user'] ?? item['owner'];
    if (id is! String || id.isEmpty) continue;
    if (name is! String || name.isEmpty) continue;
    if (user is! Map<String, dynamic>) continue;
    results.add(RemotePlaylist.fromJson(item));
  }
  return results;
}

/// Exception thrown by Audius client on deterministic 4xx or fatal errors.
class AudiusClientException implements Exception {
  AudiusClientException(
    this.message, {
    this.statusCode,
    this.isFatal = false,
    this.originalError,
  });

  final String message;
  final int? statusCode;
  final bool isFatal;
  final Object? originalError;

  @override
  String toString() =>
      'AudiusClientException(statusCode: $statusCode, isFatal: $isFatal, '
      'message: $message)';
}

/// Interface for Audius API client.
abstract interface class AudiusClient {
  Future<List<Track>> trendingTracks({
    String? genre,
    String? time,
    int? limit,
    int? offset,
  });

  Future<List<Track>> searchTracks(String query, {int limit = 40, int? offset});

  Future<List<Artist>> searchUsers(String query, {int limit = 12});

  Future<List<RemotePlaylist>> searchPlaylists(String query, {int limit = 12});

  Future<List<RemotePlaylist>> trendingPlaylists({
    String? type,
    String? time,
    int? limit,
  });

  Future<RemotePlaylist?> playlist(String id);

  Future<List<Track>> playlistTracks(String id, {int limit = 100});

  Future<Artist?> user(String id);

  Future<List<Track>> userTracks(String id, {int limit = 50});

  Future<List<RemotePlaylist>> userAlbums(String id);

  Future<Track?> track(String id);

  String streamUrl(String trackId);

  void rotateHost();

  List<String> get hosts;

  String get currentHost;

  int get hostIndex;
}

/// Implementation of [AudiusClient] with discovery node pool and host rotation.
class AudiusClientImpl implements AudiusClient {
  AudiusClientImpl({
    Dio? dio,
    List<String>? initialHosts,
    int? initialHostIndex,
    math.Random? random,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 8),
               receiveTimeout: const Duration(seconds: 15),
             ),
           ),
       _hosts = initialHosts != null && initialHosts.isNotEmpty
           ? List<String>.from(initialHosts)
           : [audiusBootstrapHost],
       _random = random ?? math.Random() {
    if (initialHosts != null && initialHosts.isNotEmpty) {
      _hostsRequested = true;
      if (initialHostIndex != null) {
        _hostIndex = initialHostIndex % _hosts.length;
      } else if (_hosts.length > 1) {
        _hostIndex = _random.nextInt(_hosts.length);
      }
    }
  }

  final Dio _dio;
  final math.Random _random;
  List<String> _hosts;
  int _hostIndex = 0;
  bool _hostsRequested = false;

  @override
  List<String> get hosts => List.unmodifiable(_hosts);

  @override
  int get hostIndex => _hostIndex;

  @override
  String get currentHost => _hosts[_hostIndex % _hosts.length];

  @override
  void rotateHost() {
    if (_hosts.isNotEmpty) {
      _hostIndex = (_hostIndex + 1) % _hosts.length;
    }
  }

  /// Fetches the list of healthy discovery nodes from the bootstrap host.
  Future<void> _loadHosts() async {
    if (_hostsRequested) return;
    _hostsRequested = true;
    try {
      final res = await _dio.get<dynamic>(
        audiusBootstrapHost,
        options: Options(receiveTimeout: const Duration(seconds: 8)),
      );
      final body = res.data;
      if (body is Map && body['data'] is List) {
        final list = (body['data'] as List)
            .whereType<String>()
            .where((h) => h.startsWith('https://'))
            .toList();
        if (list.isNotEmpty) {
          _hosts = list;
          _hostIndex = _random.nextInt(_hosts.length);
        }
      }
    } on Object catch (e) {
      Log.w('Failed to bootstrap Audius discovery nodes: $e');
      _hostsRequested = false; // Allow retry on next call
    }
  }

  Future<T> _api<T>(String path, {Map<String, dynamic>? params}) async {
    await _loadHosts();

    final query = <String, dynamic>{'app_name': audiusAppName};
    if (params != null) {
      for (final entry in params.entries) {
        if (entry.value != null) {
          query[entry.key] = entry.value;
        }
      }
    }

    Exception lastError = AudiusClientException('No hosts available');
    final base = _hostIndex;
    final attempts = math.min(_hosts.length, 4);

    for (var i = 0; i < attempts; i++) {
      final idx = (base + i) % _hosts.length;
      final host = _hosts[idx];

      try {
        final res = await _dio.get<dynamic>(
          '$host/v1$path',
          queryParameters: query,
          options: Options(receiveTimeout: const Duration(seconds: 15)),
        );

        final statusCode = res.statusCode ?? 200;
        if (statusCode >= 400 && statusCode < 500) {
          throw AudiusClientException(
            'HTTP $statusCode on $path',
            statusCode: statusCode,
            isFatal: true,
          );
        }

        final body = res.data;
        if (body is Map && body.containsKey('data')) {
          _hostIndex = idx;
          final data = body['data'];
          if (data == null) {
            throw AudiusClientException('Empty data received from $path');
          }
          return data as T;
        }

        throw AudiusClientException('Malformed response from $path');
      } on DioException catch (e) {
        final code = e.response?.statusCode;
        if (code != null && code >= 400 && code < 500) {
          throw AudiusClientException(
            'HTTP $code on $path',
            statusCode: code,
            isFatal: true,
            originalError: e,
          );
        }
        lastError = e;
        if (_hosts.length > 1) {
          _hostIndex = (idx + 1) % _hosts.length;
        }
      } on AudiusClientException catch (e) {
        if (e.isFatal) rethrow;
        lastError = e;
        if (_hosts.length > 1) {
          _hostIndex = (idx + 1) % _hosts.length;
        }
      } on Exception catch (e) {
        lastError = e;
        if (_hosts.length > 1) {
          _hostIndex = (idx + 1) % _hosts.length;
        }
      }
    }

    throw lastError;
  }

  @override
  String streamUrl(String trackId) {
    return '$currentHost/v1/tracks/$trackId/stream?app_name=$audiusAppName';
  }

  @override
  Future<List<Track>> trendingTracks({
    String? genre,
    String? time,
    int? limit,
    int? offset,
  }) async {
    final raw = await _api<dynamic>(
      '/tracks/trending',
      params: {
        'genre': genre,
        'time': time ?? 'week',
        'limit': limit ?? 20,
        'offset': offset,
      },
    );
    return cleanAndMapTracks(raw);
  }

  @override
  Future<List<Track>> searchTracks(
    String query, {
    int limit = 40,
    int? offset,
  }) async {
    final raw = await _api<dynamic>(
      '/tracks/search',
      params: {'query': query, 'limit': limit, 'offset': offset},
    );
    return cleanAndMapTracks(raw, rank: true);
  }

  @override
  Future<List<Artist>> searchUsers(String query, {int limit = 12}) async {
    final raw = await _api<dynamic>(
      '/users/search',
      params: {'query': query, 'limit': limit},
    );
    return cleanAndMapUsers(raw);
  }

  @override
  Future<List<RemotePlaylist>> searchPlaylists(
    String query, {
    int limit = 12,
  }) async {
    final raw = await _api<dynamic>(
      '/playlists/search',
      params: {'query': query, 'limit': limit},
    );
    return cleanAndMapPlaylists(raw);
  }

  @override
  Future<List<RemotePlaylist>> trendingPlaylists({
    String? type,
    String? time,
    int? limit,
  }) async {
    final raw = await _api<dynamic>(
      '/playlists/trending',
      params: {'type': type, 'time': time ?? 'week', 'limit': limit ?? 12},
    );
    return cleanAndMapPlaylists(raw);
  }

  @override
  Future<RemotePlaylist?> playlist(String id) async {
    final raw = await _api<dynamic>('/playlists/$id');
    if (raw is Map<String, dynamic>) {
      return RemotePlaylist.fromJson(raw);
    }
    if (raw is List && raw.isNotEmpty && raw.first is Map<String, dynamic>) {
      return RemotePlaylist.fromJson(raw.first as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<List<Track>> playlistTracks(String id, {int limit = 100}) async {
    final raw = await _api<dynamic>(
      '/playlists/$id/tracks',
      params: {'limit': limit},
    );
    return cleanAndMapTracks(raw);
  }

  @override
  Future<Artist?> user(String id) async {
    final raw = await _api<dynamic>('/users/$id');
    if (raw is Map<String, dynamic>) {
      return Artist.fromJson(raw);
    }
    if (raw is List && raw.isNotEmpty && raw.first is Map<String, dynamic>) {
      return Artist.fromJson(raw.first as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<List<Track>> userTracks(String id, {int limit = 50}) async {
    final raw = await _api<dynamic>(
      '/users/$id/tracks',
      params: {
        'limit': limit,
        'sort_method': 'plays',
        'sort_direction': 'desc',
      },
    );
    return cleanAndMapTracks(raw);
  }

  @override
  Future<List<RemotePlaylist>> userAlbums(String id) async {
    final raw = await _api<dynamic>(
      '/users/$id/albums',
      params: {'limit': 100},
    );
    return cleanAndMapPlaylists(raw);
  }

  @override
  Future<Track?> track(String id) async {
    final raw = await _api<dynamic>('/tracks/$id');
    if (raw is Map<String, dynamic>) {
      final copy = Map<String, dynamic>.from(raw);
      copy['streamId'] ??= copy['id'];
      return Track.fromJson(copy);
    }
    if (raw is List && raw.isNotEmpty && raw.first is Map<String, dynamic>) {
      final copy = Map<String, dynamic>.from(raw.first as Map<String, dynamic>);
      copy['streamId'] ??= copy['id'];
      return Track.fromJson(copy);
    }
    return null;
  }
}

/// Provider for [AudiusClient].
final audiusClientProvider = Provider<AudiusClient>((ref) {
  return AudiusClientImpl();
});
