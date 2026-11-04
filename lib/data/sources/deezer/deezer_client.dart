import 'dart:async';

import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:awady_music/data/sources/innertube/matcher.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String deezerUserAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
    'Chrome/120.0.0.0 Safari/537.36';

const int maxRelatedArtists = 6;
const int perArtistTopTracks = 3;

/// Lightweight model representing a track discovered via Deezer public API.
class DeezerTrack {
  const DeezerTrack({required this.title, required this.artist, this.duration});

  final String title;
  final String artist;
  final int? duration;

  Map<String, dynamic> toJson() => {
    'title': title,
    'artist': artist,
    if (duration != null) 'duration': duration,
  };

  @override
  String toString() => 'DeezerTrack($artist - $title, ${duration}s)';
}

class _ArtistTrackList {
  const _ArtistTrackList({required this.name, required this.tracks});

  final String name;
  final List<dynamic> tracks;
}

/// Interface for Deezer discovery client used as fallback radio.
abstract interface class DeezerClient {
  /// Discovers related artist tracks via Deezer public API.
  Future<List<DeezerTrack>> radioTracks(
    String artist,
    String title, {
    int limit = 12,
  });

  /// Discovers related artist tracks via Deezer and matches them to YouTube.
  Future<List<Track>> radio(
    String artist,
    String title, {
    int limit = 12,
    InnertubeClient? innertubeClient,
  });
}

/// Implementation of [DeezerClient] using public Deezer API and
/// YouTube matcher.
class DeezerClientImpl implements DeezerClient {
  DeezerClientImpl({Dio? dio, this.innertubeClient})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://api.deezer.com',
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
              headers: {'User-Agent': deezerUserAgent},
            ),
          );

  final Dio _dio;
  final InnertubeClient? innertubeClient;

  Future<dynamic> _json(String path) async {
    try {
      final res = await _dio.get<dynamic>(
        path,
        options: Options(
          headers: {'User-Agent': deezerUserAgent},
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      return res.data;
    } on Object catch (e) {
      Log.w('Deezer request failed for $path: $e');
      return null;
    }
  }

  @override
  Future<List<DeezerTrack>> radioTracks(
    String artist,
    String title, {
    int limit = 12,
  }) async {
    final name = artist.trim();
    if (name.isEmpty || name == 'Unknown artist') {
      return const [];
    }

    final searchRes = await _json(
      '/search/artist?q=${Uri.encodeComponent(name)}&limit=1',
    );
    if (searchRes is! Map) return const [];
    final searchData = searchRes['data'];
    if (searchData is! List || searchData.isEmpty) return const [];
    final firstArtist = searchData.first;
    if (firstArtist is! Map) return const [];
    final artistId = firstArtist['id'];
    if (artistId == null) return const [];

    final relatedRes = await _json(
      '/artist/$artistId/related?limit=$maxRelatedArtists',
    );
    if (relatedRes is! Map) return const [];
    final relatedData = relatedRes['data'];
    if (relatedData is! List || relatedData.isEmpty) return const [];

    final relatedArtists = relatedData
        .whereType<Map<dynamic, dynamic>>()
        .take(maxRelatedArtists)
        .toList();
    if (relatedArtists.isEmpty) return const [];

    final trackLists = await Future.wait(
      relatedArtists.map((a) async {
        final aId = a['id'];
        final aName = (a['name'] as String? ?? '').trim();
        final topRes = await _json(
          '/artist/$aId/top?limit=$perArtistTopTracks',
        );
        final topTracks = topRes is Map && topRes['data'] is List
            ? topRes['data'] as List<dynamic>
            : const <dynamic>[];
        return _ArtistTrackList(name: aName, tracks: topTracks);
      }),
    );

    final seed = title.trim().toLowerCase();
    final seen = <String>{};
    final out = <DeezerTrack>[];

    for (var round = 0; round < perArtistTopTracks; round++) {
      for (final list in trackLists) {
        if (round >= list.tracks.length) continue;
        final t = list.tracks[round];
        if (t is! Map) continue;

        final songTitle = (t['title'] as String? ?? '').trim();
        final artistObj = t['artist'];
        final songArtist =
            (artistObj is Map && artistObj['name'] is String
                    ? artistObj['name'] as String
                    : list.name)
                .trim();

        final key = '$songArtist $songTitle'.toLowerCase();
        if (songTitle.isEmpty || songArtist.isEmpty) continue;
        if (seen.contains(key) || seed == songTitle.toLowerCase()) continue;

        seen.add(key);

        int? dur;
        final rawDur = t['duration'];
        if (rawDur is num && rawDur.isFinite && rawDur > 0) {
          dur = rawDur.round();
        }

        out.add(
          DeezerTrack(title: songTitle, artist: songArtist, duration: dur),
        );

        if (out.length >= limit) return out;
      }
    }

    return out;
  }

  @override
  Future<List<Track>> radio(
    String artist,
    String title, {
    int limit = 12,
    InnertubeClient? innertubeClient,
  }) async {
    final client = innertubeClient ?? this.innertubeClient;
    if (client == null) {
      Log.w('Deezer radio called without InnertubeClient for matching');
      return const [];
    }

    final picks = await radioTracks(artist, title, limit: limit);
    if (picks.isEmpty) return const [];

    final matched = <Track>[];
    for (final p in picks) {
      try {
        final hit = await matchSingleTrack(
          client,
          MatchQuery(
            title: p.title,
            artist: p.artist,
            duration: p.duration ?? 0,
          ),
        );
        if (hit != null) {
          matched.add(hit);
        }
      } on Object catch (e) {
        Log.w('Deezer track match failed for "${p.title}": $e');
      }
    }

    return matched;
  }
}

/// Provider for [DeezerClient].
final deezerClientProvider = Provider<DeezerClient>((ref) {
  final innertube = ref.watch(innertubeClientProvider);
  return DeezerClientImpl(innertubeClient: innertube);
});
