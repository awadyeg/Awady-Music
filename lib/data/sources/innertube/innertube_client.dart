import 'dart:async';

import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/core/util/semaphore.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/artist_page.dart';
import 'package:awady_music/data/models/mood_models.dart';
import 'package:awady_music/data/models/playlist_page.dart';
import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/search_results.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/sources/http.dart';
import 'package:awady_music/data/sources/innertube/matcher.dart';
import 'package:awady_music/data/sources/innertube/parsers/artist_parser.dart';
import 'package:awady_music/data/sources/innertube/parsers/browse_parser.dart';
import 'package:awady_music/data/sources/innertube/parsers/playlist_parser.dart';
import 'package:awady_music/data/sources/innertube/parsers/search_parser.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a bootstrapped session context for Innertube.
class InnertubeSession {
  const InnertubeSession({
    required this.apiKey,
    required this.clientVersion,
    this.visitorData,
  });

  final String apiKey;
  final String clientVersion;
  final String? visitorData;
}

/// Defensive nested JSON reader helper that never throws.
dynamic dig(dynamic source, List<dynamic> path) {
  dynamic current = source;
  for (final segment in path) {
    if (current == null) return null;
    if (segment is String && current is Map) {
      current = current[segment];
    } else if (segment is int && current is List) {
      if (segment >= 0 && segment < current.length) {
        current = current[segment];
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
  return current;
}

/// Type-safe defensive JSON reader helper.
T? digAs<T>(dynamic source, List<dynamic> path) {
  final val = dig(source, path);
  return val is T ? val : null;
}

/// Client for interacting with the raw YouTube Music Innertube API.
class InnertubeClient {
  InnertubeClient({Dio? dio, Semaphore? limiter, this.countryCode = 'US'})
    : _dio = dio ?? createDio(),
      _limiter = limiter ?? Semaphore(4);

  final Dio _dio;
  final Semaphore _limiter;
  final String countryCode;

  /// Current session credentials. Can be set directly for testing.
  InnertubeSession? session;
  Future<InnertubeSession>? _bootstrapFuture;

  static const String defaultApiKey = 'AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8';
  static const String defaultClientVersion = '1.20241028.01.00';
  static const String userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36';

  /// Bootstraps session tokens from music.youtube.com homepage ytcfg.
  Future<InnertubeSession> bootstrapSession({bool force = false}) {
    if (!force && session != null) {
      return Future.value(session!);
    }
    if (_bootstrapFuture != null) {
      return _bootstrapFuture!;
    }

    _bootstrapFuture = _performBootstrap();
    return _bootstrapFuture!;
  }

  Future<InnertubeSession> _performBootstrap() async {
    try {
      final response = await _limiter.run(
        () => _dio.get<String>(
          'https://music.youtube.com/',
          options: Options(
            headers: const {
              'User-Agent': userAgent,
              'Accept-Language': 'en-US,en;q=0.9',
            },
          ),
        ),
      );

      final html = response.data ?? '';
      final keyMatch = RegExp(r'"INNERTUBE_API_KEY"\s*:\s*"([^"]+)"')
          .firstMatch(html);
      final verMatch = RegExp(r'"INNERTUBE_CLIENT_VERSION"\s*:\s*"([^"]+)"')
          .firstMatch(html);
      final visMatch = RegExp(r'"VISITOR_DATA"\s*:\s*"([^"]+)"')
          .firstMatch(html);

      final resolvedSession = InnertubeSession(
        apiKey: keyMatch?.group(1) ?? defaultApiKey,
        clientVersion: verMatch?.group(1) ?? defaultClientVersion,
        visitorData: visMatch?.group(1),
      );
      session = resolvedSession;
      return resolvedSession;
    } on Object catch (e) {
      Log.w('Failed to bootstrap Innertube session, using defaults: $e');
      const fallback = InnertubeSession(
        apiKey: defaultApiKey,
        clientVersion: defaultClientVersion,
      );
      session = fallback;
      return fallback;
    } finally {
      _bootstrapFuture = null;
    }
  }

  /// Sends a POST request to an Innertube endpoint with
  /// WEB_REMIX client context.
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final session = await bootstrapSession();

    final payload = {
      'context': {
        'client': {
          'clientName': 'WEB_REMIX',
          'clientVersion': session.clientVersion,
          if (session.visitorData != null) 'visitorData': session.visitorData,
          'hl': 'en',
          'gl': countryCode,
        },
      },
      ...body,
    };

    final url =
        'https://music.youtube.com/youtubei/v1/$endpoint?prettyPrint=false&key=${session.apiKey}';

    final response = await _limiter.run(
      () => _dio.post<Map<String, dynamic>>(
        url,
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': userAgent,
            'X-YouTube-Client-Name': '67',
            'X-YouTube-Client-Version': session.clientVersion,
            'X-Origin': 'https://music.youtube.com',
          },
        ),
      ),
    );

    return response.data ?? <String, dynamic>{};
  }

  final _searchParser = const SearchParser();
  final _artistParser = const ArtistParser();
  final _playlistParser = const PlaylistParser();
  final _browseParser = const BrowseParser();

  /// Searches Innertube and returns parsed [SearchResults].
  Future<SearchResults> search(String query) async {
    final res = await post('search', {'query': query});
    return _searchParser.parseSearch(res);
  }

  /// Returns search suggestions for [query].
  Future<List<String>> suggest(String query) async {
    final res = await post('music/get_search_suggestions', {'input': query});
    return _searchParser.parseSuggestions(res);
  }

  static final RegExp _ucChannelPattern = RegExp(r'^UC[\w-]{8,}$');

  Artist? _pickArtistFromSearch(SearchResults searchRes, String query) {
    final qLower = query.trim().toLowerCase();
    if (searchRes.top is Artist) {
      final topArtist = searchRes.top! as Artist;
      final topCid = (topArtist.streamId ?? topArtist.id)
          .replaceFirst(RegExp('^yt-'), '')
          .replaceFirst(RegExp('^MPLA'), '')
          .trim();
      if (_ucChannelPattern.hasMatch(topCid)) {
        return topArtist;
      }
    }

    if (searchRes.artists.isNotEmpty) {
      for (final a in searchRes.artists) {
        if (a.name.trim().toLowerCase() == qLower) {
          return a;
        }
      }
      for (final a in searchRes.artists) {
        if (a.name.toLowerCase().contains(qLower) ||
            (qLower.isNotEmpty && qLower.contains(a.name.toLowerCase()))) {
          return a;
        }
      }
      return searchRes.artists.first;
    }

    for (final song in searchRes.songs) {
      final cid = (song.artist.streamId ?? song.artist.id)
          .replaceFirst(RegExp('^yt-'), '')
          .replaceFirst(RegExp('^MPLA'), '')
          .trim();
      if (_ucChannelPattern.hasMatch(cid)) {
        return song.artist;
      }
    }

    if (searchRes.top is Artist) {
      return searchRes.top! as Artist;
    }
    return null;
  }

  /// Fetches and parses full artist profile, top tracks, and discography.
  Future<ArtistPage> artist(String channelId, {String? nameHint}) async {
    var cleanId = channelId
        .replaceFirst(RegExp('^yt-'), '')
        .replaceFirst(RegExp('^MPLA'), '')
        .trim();

    final effectiveHint = (nameHint != null && nameHint.trim().isNotEmpty)
        ? nameHint.trim()
        : (!_ucChannelPattern.hasMatch(cleanId) && cleanId.isNotEmpty
              ? cleanId
              : null);

    SearchResults? cachedSearch;
    Artist? searchMatchedArtist;

    if (!_ucChannelPattern.hasMatch(cleanId)) {
      final query = effectiveHint ?? cleanId;
      if (query.isEmpty) {
        throw StateError('Empty artist identifier');
      }
      cachedSearch = await search(query);
      searchMatchedArtist = _pickArtistFromSearch(cachedSearch, query);
      if (searchMatchedArtist != null) {
        final matchedId =
            (searchMatchedArtist.streamId ?? searchMatchedArtist.id)
                .replaceFirst(RegExp('^yt-'), '')
                .replaceFirst(RegExp('^MPLA'), '')
                .trim();
        if (_ucChannelPattern.hasMatch(matchedId)) {
          cleanId = matchedId;
        }
      }
      if (!_ucChannelPattern.hasMatch(cleanId)) {
        if (cachedSearch.songs.isNotEmpty || searchMatchedArtist != null) {
          final fallbackArtist =
              searchMatchedArtist ?? cachedSearch.songs.first.artist;
          return ArtistPage(
            artist: fallbackArtist.copyWith(
              trackCount: cachedSearch.songs.length,
            ),
            topSongs: cachedSearch.songs,
            albums: cachedSearch.playlists.where((p) => p.isAlbum).toList(),
            singles: cachedSearch.playlists.where((p) => !p.isAlbum).toList(),
          );
        }
        throw StateError('Artist not found on YouTube Music for "$query"');
      }
    }

    ArtistPage? page;
    Exception? browseError;
    try {
      final res = await post('browse', {'browseId': cleanId});
      page = _artistParser.parseArtistPage(
        res,
        channelId: cleanId,
        nameHint: effectiveHint ?? searchMatchedArtist?.name,
      );
    } on Exception catch (e) {
      browseError = e;
      Log.w('Innertube browse failed for artist $cleanId: $e');
    }

    final isDeadPage =
        page == null ||
        (page.topSongs.isEmpty && page.albums.isEmpty && page.singles.isEmpty);

    if (isDeadPage) {
      final rescueQuery =
          effectiveHint ??
          searchMatchedArtist?.name ??
          (page != null &&
                  page.artist.name.isNotEmpty &&
                  page.artist.name != 'Artist'
              ? page.artist.name
              : null);
      if (rescueQuery != null && rescueQuery.isNotEmpty) {
        try {
          cachedSearch ??= await search(rescueQuery);
          searchMatchedArtist ??= _pickArtistFromSearch(
            cachedSearch,
            rescueQuery,
          );
          if (searchMatchedArtist != null) {
            final rescueCid =
                (searchMatchedArtist.streamId ?? searchMatchedArtist.id)
                    .replaceFirst(RegExp('^yt-'), '')
                    .replaceFirst(RegExp('^MPLA'), '')
                    .trim();
            if (_ucChannelPattern.hasMatch(rescueCid) && rescueCid != cleanId) {
              final res2 = await post('browse', {'browseId': rescueCid});
              page = _artistParser.parseArtistPage(
                res2,
                channelId: rescueCid,
                nameHint: searchMatchedArtist.name,
              );
            }
          }
        } on Object catch (e) {
          Log.w('Innertube artist rescue search failed for "$rescueQuery": $e');
        }
      }
    }

    if (page != null && page.topSongs.isEmpty) {
      final songQuery =
          (page.artist.name.isNotEmpty && page.artist.name != 'Artist')
          ? page.artist.name
          : effectiveHint;
      if (cachedSearch == null && songQuery != null && songQuery.isNotEmpty) {
        try {
          cachedSearch = await search(songQuery);
        } on Object catch (_) {}
      }
      if (cachedSearch != null && cachedSearch.songs.isNotEmpty) {
        page = ArtistPage(
          artist: page.artist.copyWith(
            trackCount: cachedSearch.songs.length,
            profilePicture:
                page.artist.profilePicture ??
                searchMatchedArtist?.profilePicture,
          ),
          topSongs: cachedSearch.songs,
          albums: page.albums.isNotEmpty
              ? page.albums
              : cachedSearch.playlists.where((p) => p.isAlbum).toList(),
          singles: page.singles.isNotEmpty
              ? page.singles
              : cachedSearch.playlists.where((p) => !p.isAlbum).toList(),
          bio: page.bio,
        );
      }
    }

    if (page != null) {
      return page;
    }

    if (cachedSearch != null &&
        (cachedSearch.songs.isNotEmpty || searchMatchedArtist != null)) {
      final fallbackArtist =
          searchMatchedArtist ?? cachedSearch.songs.first.artist;
      return ArtistPage(
        artist: fallbackArtist.copyWith(trackCount: cachedSearch.songs.length),
        topSongs: cachedSearch.songs,
        albums: cachedSearch.playlists.where((p) => p.isAlbum).toList(),
        singles: cachedSearch.playlists.where((p) => !p.isAlbum).toList(),
      );
    }

    if (browseError != null) {
      throw browseError;
    }
    throw StateError('Artist not found for $channelId');
  }

  /// Fetches an album by its browseId (e.g. MPREb_...).
  Future<PlaylistPage> album(String browseId) async {
    final cleanId = browseId.replaceFirst(RegExp('^(ytalb-|ytpl-|yt-)'), '');
    if (cleanId.startsWith('VL') ||
        cleanId.startsWith('PL') ||
        cleanId.startsWith('RD') ||
        cleanId.startsWith('OLAK')) {
      return await playlist(cleanId);
    }

    Map<String, dynamic>? raw;
    PlaylistPage? page;
    Exception? browseError;
    try {
      raw = await post('browse', {'browseId': cleanId});
      page = _playlistParser.parseAlbum(raw, cleanId);
      if (page.tracks.isNotEmpty) {
        return page;
      }
    } on Exception catch (e) {
      browseError = e;
      Log.w('Innertube album browse failed for $cleanId: $e');
    }

    if (raw != null) {
      final nestedIds = _playlistParser.findNestedPlaylistIds(raw);
      for (final pid in nestedIds) {
        final strippedPid = pid.replaceFirst(RegExp('^VL'), '');
        try {
          final plRes = await post('browse', {'browseId': 'VL$strippedPid'});
          final plPage = _playlistParser.parsePlaylist(plRes, strippedPid);
          if (plPage.tracks.isNotEmpty) {
            return PlaylistPage(
              playlist: (page?.playlist ?? plPage.playlist).copyWith(
                trackCount: plPage.tracks.length,
                artwork: page?.playlist.artwork ?? plPage.playlist.artwork,
              ),
              tracks: plPage.tracks,
            );
          }
        } on Exception catch (_) {}

        try {
          final nextRes = await post('next', {'playlistId': strippedPid});
          final nextTracks = _browseParser.parseUpNext(nextRes, limit: 100);
          if (nextTracks.isNotEmpty) {
            return PlaylistPage(
              playlist:
                  (page?.playlist ??
                          RemotePlaylist(
                            id: 'ytalb-$cleanId',
                            name: 'Album',
                            isAlbum: true,
                            artwork: nextTracks.first.artwork,
                            owner: nextTracks.first.artist,
                          ))
                      .copyWith(
                        trackCount: nextTracks.length,
                        artwork:
                            page?.playlist.artwork ?? nextTracks.first.artwork,
                      ),
              tracks: nextTracks,
            );
          }
        } on Exception catch (_) {}
      }
    }

    if (page != null &&
        page.playlist.name.isNotEmpty &&
        page.playlist.name != 'Album') {
      try {
        final ownerName = page.playlist.owner.name != 'Various Artists'
            ? page.playlist.owner.name
            : '';
        final searchRes = await search(
          '${page.playlist.name} $ownerName'.trim(),
        );
        if (searchRes.songs.isNotEmpty) {
          return PlaylistPage(
            playlist: page.playlist.copyWith(
              trackCount: searchRes.songs.length,
              artwork: page.playlist.artwork ?? searchRes.songs.first.artwork,
            ),
            tracks: searchRes.songs,
          );
        }
      } on Exception catch (_) {}
    }

    if (page != null) {
      return page;
    }
    throw browseError ?? Exception('Failed to load album: $cleanId');
  }

  /// Fetches a playlist by its browseId with VL-prefix strip/retry and
  /// `/next` watchPlaylist fallback.
  Future<PlaylistPage> playlist(String browseId) async {
    final cleanId = browseId.replaceFirst(RegExp('^(ytpl-|ytalb-|yt-)'), '');
    if (cleanId.startsWith('MPRE')) {
      return await album(cleanId);
    }
    final stripped = cleanId.replaceFirst(RegExp('^VL'), '');
    final candidates = {
      if (cleanId.startsWith('VL')) ...[
        cleanId,
        stripped,
      ] else ...[
        'VL$cleanId',
        cleanId,
      ],
    }.toList();

    PlaylistPage? bestPage;
    Map<String, dynamic>? bestRaw;
    Exception? lastError;

    for (final candidate in candidates) {
      try {
        final res = await post('browse', {'browseId': candidate});
        final page = _playlistParser.parsePlaylist(res, cleanId);
        if (page.tracks.isNotEmpty) {
          return page;
        }
        bestPage ??= page;
        bestRaw ??= res;
      } on Exception catch (e) {
        lastError = e;
      }
    }

    // Fallback 1: try /next endpoint with playlistId (handles RD... mixes,
    // OLAK... album playlists, and PL... playlists whose /browse shelf is empty)
    final nextCandidates = <String>{
      stripped,
      if (bestRaw != null)
        ..._playlistParser
            .findNestedPlaylistIds(bestRaw)
            .map((id) => id.replaceFirst(RegExp('^VL'), '')),
    };

    for (final pid in nextCandidates) {
      if (pid.isEmpty) continue;
      try {
        final nextRes = await post('next', {'playlistId': pid});
        final nextTracks = _browseParser.parseUpNext(nextRes, limit: 100);
        if (nextTracks.isNotEmpty) {
          final basePlaylist =
              bestPage?.playlist ??
              RemotePlaylist(
                id: 'ytpl-$cleanId',
                name: 'Playlist',
                artwork: nextTracks.first.artwork,
                owner: const Artist(
                  id: 'yt-va',
                  name: 'YouTube Music',
                  handle: 'YouTube Music',
                ),
              );
          return PlaylistPage(
            playlist: basePlaylist.copyWith(
              trackCount: nextTracks.length,
              artwork: basePlaylist.artwork ?? nextTracks.first.artwork,
            ),
            tracks: nextTracks,
          );
        }
      } on Exception catch (e) {
        lastError ??= e;
      }
    }

    // Fallback 2: if browse returned a valid playlist header name but 0 tracks,
    // rescue tracks via search
    if (bestPage != null &&
        bestPage.playlist.name.isNotEmpty &&
        bestPage.playlist.name != 'Playlist') {
      try {
        final searchRes = await search(bestPage.playlist.name);
        if (searchRes.songs.isNotEmpty) {
          return PlaylistPage(
            playlist: bestPage.playlist.copyWith(
              trackCount: searchRes.songs.length,
              artwork:
                  bestPage.playlist.artwork ?? searchRes.songs.first.artwork,
            ),
            tracks: searchRes.songs,
          );
        }
      } on Exception catch (_) {}
    }

    if (bestPage != null) {
      return bestPage;
    }

    throw lastError ?? Exception('Failed to load playlist: $cleanId');
  }

  /// Fetches home and explore feeds and returns editorial playlists/albums.
  Future<List<RemotePlaylist>> homePlaylists() async {
    final results = <RemotePlaylist>[];
    final seen = <String>{};

    if (countryCode.toUpperCase() != 'US') {
      try {
        final country = findMusicCountry(countryCode);
        final regional = await search('${country.nameEn} top hits playlist');
        for (final pl in regional.playlists) {
          if (seen.add(pl.id)) {
            results.add(pl);
          }
        }
      } on Exception catch (e) {
        Log.w('Failed to fetch regional playlists for $countryCode: $e');
      }
    }

    for (final browseId in ['FEmusic_home', 'FEmusic_explore']) {
      try {
        final res = await post('browse', {'browseId': browseId});
        final playlists = _browseParser.parseHomePlaylists(res);
        for (final pl in playlists) {
          if (seen.add(pl.id)) {
            results.add(pl);
          }
        }
      } on Exception catch (e) {
        Log.w('Failed to fetch home playlists for $browseId: $e');
      }
    }

    return results;
  }

  /// Fetches new releases feed.
  Future<List<RemotePlaylist>> newReleases({int limit = 24}) async {
    final results = <RemotePlaylist>[];
    final seen = <String>{};

    if (countryCode.toUpperCase() != 'US') {
      try {
        final country = findMusicCountry(countryCode);
        final regional = await search('${country.nameEn} new music albums');
        for (final pl in regional.playlists) {
          if (seen.add(pl.id)) {
            results.add(pl);
          }
        }
      } on Exception catch (_) {}
    }

    try {
      final res = await post('browse', {'browseId': 'FEmusic_new_releases'});
      final parsed = _browseParser.parseNewReleases(res, limit: limit);
      for (final pl in parsed) {
        if (seen.add(pl.id)) {
          results.add(pl);
        }
      }
    } on Exception catch (e) {
      Log.w('Failed to fetch FEmusic_new_releases: $e');
    }

    return results.length > limit ? results.sublist(0, limit) : results;
  }

  /// Fetches the regional charts and returns the top chart songs.
  Future<List<Track>> charts() async {
    final res = await post('browse', {'browseId': 'FEmusic_charts'});
    final parsed = _browseParser.parseCharts(res);

    for (final bid in parsed.chartPlaylistIds) {
      try {
        final pl = await playlist(bid);
        if (pl.tracks.length >= 10) {
          return pl.tracks.length > 50 ? pl.tracks.sublist(0, 50) : pl.tracks;
        }
      } on Exception catch (e) {
        Log.w('Failed to fetch chart playlist $bid: $e');
      }
    }

    return parsed.tracks.length > 50
        ? parsed.tracks.sublist(0, 50)
        : parsed.tracks;
  }

  /// Fetches trending songs from regional charts, explore, or home feed.
  Future<List<Track>> trending() async {
    final tracks = <Track>[];
    final seen = <String>{};

    if (countryCode.toUpperCase() != 'US') {
      try {
        final country = findMusicCountry(countryCode);
        final regional = await search('${country.nameEn} trending songs');
        for (final t in regional.songs) {
          if (seen.add(t.id)) {
            tracks.add(t);
          }
          if (tracks.length >= 10) break;
        }
      } on Exception catch (e) {
        Log.w('Failed to fetch regional trending for $countryCode: $e');
      }
    }

    for (final browseId in [
      'FEmusic_charts',
      'FEmusic_explore',
      'FEmusic_home',
    ]) {
      try {
        final res = await post('browse', {'browseId': browseId});
        final parsed = _browseParser.parseCharts(res);
        for (final t in parsed.tracks) {
          if (seen.add(t.id)) {
            tracks.add(t);
          }
          if (tracks.length >= 20) {
            return tracks;
          }
        }
      } on Exception catch (e) {
        Log.w('Failed to fetch trending from $browseId: $e');
      }
    }
    return tracks;
  }

  /// Fetches moods and genres directory.
  Future<List<MoodCategory>> moods() async {
    final res = await post('browse', {'browseId': 'FEmusic_moods_and_genres'});
    return _browseParser.parseMoods(res);
  }

  /// Fetches an individual mood / genre category page by [params].
  Future<MoodPageData> mood(String params) async {
    final res = await post('browse', {
      'browseId': 'FEmusic_moods_and_genres_category',
      'params': params,
    });
    return _browseParser.parseMoodPage(res);
  }

  /// Fetches upNext / autoplay radio tracks for [videoId].
  Future<List<Track>> upNext(String videoId, {int limit = 40}) async {
    final cleanId = videoId.replaceFirst(RegExp('^(?:yt-|ytpl-|ytalb-)'), '');
    try {
      final res = await post('next', {
        'videoId': cleanId,
        'playlistId': 'RDAMVM$cleanId',
        'isAudioOnly': true,
      });
      final tracks = _browseParser.parseUpNext(res, limit: limit);
      if (tracks.isNotEmpty) return tracks;
    } on Object catch (e) {
      Log.w('Automix upNext with RDAMVM failed for $cleanId: $e');
    }
    final res = await post('next', {'videoId': cleanId});
    return _browseParser.parseUpNext(res, limit: limit);
  }

  /// Resolves a batch of [MatchQuery] items with concurrency limiter.
  Future<List<Track?>> match(List<MatchQuery> items) async {
    final results = List<Track?>.filled(items.length, null);
    final limiter = Semaphore(4);

    final futures = <Future<void>>[];
    for (var i = 0; i < items.length; i++) {
      final index = i;
      final query = items[i];
      futures.add(
        limiter.run(() async {
          try {
            results[index] = await matchSingleTrack(this, query);
          } on Exception catch (e) {
            Log.w('Match failed for "${query.title}" by "${query.artist}": $e');
          }
        }),
      );
    }

    await Future.wait(futures);
    return results;
  }
}

/// Provider for [InnertubeClient].
final innertubeClientProvider = Provider<InnertubeClient>((ref) {
  final countryCode = ref.watch(settingsProvider.select((s) => s.countryCode));
  return InnertubeClient(countryCode: countryCode);
});
