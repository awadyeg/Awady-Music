import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/catalog_providers.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/data/repositories/stats_repository.dart';
import 'package:awady_music/data/sources/innertube/parsers/browse_parser.dart';
import 'package:awady_music/data/sources/innertube/parsers/playlist_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pure-Dart SHA-1 implementation returning a 40-character lowercase hex.
String sha1Hex(String input) {
  final bytes = utf8.encode(input);
  final bitLength = bytes.length * 8;

  final padded = List<int>.from(bytes)..add(0x80);
  while ((padded.length % 64) != 56) {
    padded.add(0x00);
  }

  final lengthBytes = ByteData(8)..setUint64(0, bitLength);
  for (var i = 0; i < 8; i++) {
    padded.add(lengthBytes.getUint8(i));
  }

  var h0 = 0x67452301;
  var h1 = 0xEFCDAB89;
  var h2 = 0x98BADCFE;
  var h3 = 0x10325476;
  var h4 = 0xC3D2E1F0;

  final w = List<int>.filled(80, 0);

  for (var chunk = 0; chunk < padded.length; chunk += 64) {
    for (var i = 0; i < 16; i++) {
      w[i] =
          (padded[chunk + i * 4] << 24) |
          (padded[chunk + i * 4 + 1] << 16) |
          (padded[chunk + i * 4 + 2] << 8) |
          (padded[chunk + i * 4 + 3]);
    }
    for (var i = 16; i < 80; i++) {
      final val = w[i - 3] ^ w[i - 8] ^ w[i - 14] ^ w[i - 16];
      w[i] = ((val << 1) | (val >>> 31)) & 0xFFFFFFFF;
    }

    var a = h0;
    var b = h1;
    var c = h2;
    var d = h3;
    var e = h4;

    for (var i = 0; i < 80; i++) {
      int f;
      int k;
      if (i < 20) {
        f = (b & c) | ((~b) & d);
        k = 0x5A827999;
      } else if (i < 40) {
        f = b ^ c ^ d;
        k = 0x6ED9EBA1;
      } else if (i < 60) {
        f = (b & c) | (b & d) | (c & d);
        k = 0x8F1BBCDC;
      } else {
        f = b ^ c ^ d;
        k = 0xCA62C1D6;
      }

      final temp = (((a << 5) | (a >>> 27)) + f + e + k + w[i]) & 0xFFFFFFFF;
      e = d;
      d = c;
      c = ((b << 30) | (b >>> 2)) & 0xFFFFFFFF;
      b = a;
      a = temp;
    }

    h0 = (h0 + a) & 0xFFFFFFFF;
    h1 = (h1 + b) & 0xFFFFFFFF;
    h2 = (h2 + c) & 0xFFFFFFFF;
    h3 = (h3 + d) & 0xFFFFFFFF;
    h4 = (h4 + e) & 0xFFFFFFFF;
  }

  String toHex32(int val) => val.toRadixString(16).padLeft(8, '0');
  final part1 = '${toHex32(h0)}${toHex32(h1)}${toHex32(h2)}';
  return '$part1${toHex32(h3)}${toHex32(h4)}';
}

/// Helper for YouTube Music account authentication, import, and sync.
class YtMusicAccountImporter {
  const YtMusicAccountImporter._();

  static const _authChannel = MethodChannel('com.awady.awady_music/ytm_auth');
  static const keyCookie = 'ytm_account_cookie';
  static const keyAccountName = 'ytm_account_name';

  static String? extractSapisid(String cookie) {
    final parts = cookie.split(';');
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.startsWith('SAPISID=')) {
        return trimmed.substring('SAPISID='.length);
      }
      if (trimmed.startsWith('__Secure-3PAPISID=')) {
        return trimmed.substring('__Secure-3PAPISID='.length);
      }
    }
    return null;
  }

  static String buildSapisidHash(
    String sapisid, {
    String origin = 'https://music.youtube.com',
    int? timestamp,
  }) {
    final now = timestamp ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    final hash = sha1Hex('$now $sapisid $origin');
    return 'SAPISIDHASH ${now}_$hash';
  }

  static Map<String, String> buildInnertubeHeaders(String cookie) {
    final sapisid = extractSapisid(cookie);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/126.0.0.0 Mobile Safari/537.36',
      'Origin': 'https://music.youtube.com',
      'Referer': 'https://music.youtube.com/',
      'X-Origin': 'https://music.youtube.com',
      'X-Goog-AuthUser': '0',
      'X-YouTube-Client-Name': '67',
      'X-YouTube-Client-Version': '1.20240101.01.00',
      'Cookie': cookie,
    };
    if (sapisid != null && sapisid.isNotEmpty) {
      headers['Authorization'] = buildSapisidHash(sapisid);
    }
    return headers;
  }

  static Future<Map<String, dynamic>?> fetchBrowse(
    String browseId,
    String cookie, {
    HttpClient? httpClient,
  }) async {
    final client =
        httpClient ??
        (HttpClient()..connectionTimeout = const Duration(seconds: 10));

    try {
      final uri = Uri.parse(
        'https://music.youtube.com/youtubei/v1/browse?prettyPrint=false',
      );
      final req = await client.postUrl(uri);
      buildInnertubeHeaders(cookie).forEach(req.headers.set);

      final payload = jsonEncode({
        'context': {
          'client': {
            'clientName': 'WEB_REMIX',
            'clientVersion': '1.20240101.01.00',
            'gl': 'US',
            'hl': 'en',
          },
        },
        'browseId': browseId,
      });
      req.add(utf8.encode(payload));

      final res = await req.close();
      if (res.statusCode == 200) {
        final body = await res.transform(utf8.decoder).join();
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
      return null;
    } on Object catch (e) {
      Log.w('Failed to fetch Innertube browseId $browseId: $e');
      return null;
    } finally {
      if (httpClient == null) {
        client.close(force: true);
      }
    }
  }

  /// Fetches Liked Music (VLLM), History, and Home using the cookie.
  static Future<List<Track>> fetchAccountMusic(
    String cookie, {
    HttpClient? httpClient,
  }) async {
    const playlistParser = PlaylistParser();
    const browseParser = BrowseParser();
    final allTracks = <Track>[];
    final seenIds = <String>{};

    void addTracks(List<Track> tracks) {
      for (final t in tracks) {
        if (seenIds.add(t.id)) {
          allTracks.add(t);
        }
      }
    }

    const browseIds = ['VLLM', 'FEmusic_history', 'FEmusic_home'];
    for (final browseId in browseIds) {
      try {
        final json = await fetchBrowse(
          browseId,
          cookie,
          httpClient: httpClient,
        );
        if (json != null) {
          final page = playlistParser.parsePlaylist(json, browseId);
          addTracks(page.tracks);
          final moodPage = browseParser.parseMoodPage(json);
          addTracks(moodPage.tracks);
          final upNext = browseParser.parseUpNext(json, limit: 60);
          addTracks(upNext);
        }
      } on Object catch (e) {
        Log.w('Error loading $browseId from account: $e');
      }
    }

    return allTracks;
  }

  static Future<bool> syncLikeToAccount(
    String trackId, {
    required bool like,
    required String cookie,
    HttpClient? httpClient,
  }) async {
    final cleanVideoId = trackId.replaceFirst(
      RegExp('^(?:yt-|ytpl-|ytalb-)'),
      '',
    );
    if (cleanVideoId.isEmpty) return false;

    final client =
        httpClient ??
        (HttpClient()..connectionTimeout = const Duration(seconds: 8));

    try {
      final endpoint = like
          ? 'https://music.youtube.com/youtubei/v1/like/like'
          : 'https://music.youtube.com/youtubei/v1/like/removelike';
      final uri = Uri.parse(endpoint);
      final req = await client.postUrl(uri);
      buildInnertubeHeaders(cookie).forEach(req.headers.set);

      final payload = jsonEncode({
        'context': {
          'client': {
            'clientName': 'WEB_REMIX',
            'clientVersion': '1.20240101.01.00',
            'gl': 'US',
            'hl': 'en',
          },
        },
        'target': {'videoId': cleanVideoId},
      });
      req.add(utf8.encode(payload));

      final res = await req.close();
      return res.statusCode == 200;
    } on Object catch (e) {
      Log.w('Failed to sync like ($like) for $trackId: $e');
      return false;
    } finally {
      if (httpClient == null) {
        client.close(force: true);
      }
    }
  }

  static Future<bool> syncLikeWithSavedCookie(
    String trackId, {
    required bool like,
    SharedPreferences? prefs,
    HttpClient? httpClient,
  }) async {
    try {
      final p = prefs ?? await SharedPreferences.getInstance();
      final cookie = p.getString(keyCookie);
      if (cookie == null || cookie.isEmpty) return false;
      return await syncLikeToAccount(
        trackId,
        like: like,
        cookie: cookie,
        httpClient: httpClient,
      );
    } on Object catch (e) {
      Log.w('Failed to sync like with saved cookie: $e');
      return false;
    }
  }

  static Future<String?> loginWithGoogle() async {
    try {
      return await _authChannel.invokeMethod<String>('loginYouTubeMusic');
    } on Object catch (e) {
      Log.w('Google / YTM login failed: $e');
      return null;
    }
  }

  static Future<void> logout() async {
    try {
      await _authChannel.invokeMethod<void>('logout');
    } on Object catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(keyCookie);
      await prefs.remove(keyAccountName);
    } on Object catch (_) {}
  }

  static Future<void> signInAndImport(
    BuildContext context,
    WidgetRef ref,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Google / YouTube Music sign-in...'),
        duration: Duration(seconds: 2),
      ),
    );

    final cookie = await loginWithGoogle();
    if (cookie == null || cookie.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign-in was cancelled or no session found.'),
        ),
      );
      return;
    }

    final sapisid = extractSapisid(cookie);
    if (sapisid == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Signed in, but YouTube Music auth tokens could not be read.',
          ),
        ),
      );
      return;
    }

    // Save cookie
    final prefs =
        ref.read(sharedPreferencesProvider) ??
        await SharedPreferences.getInstance();
    await prefs.setString(keyCookie, cookie);
    await prefs.setString(keyAccountName, 'YouTube Music Account');

    unawaited(
      ref
          .read(settingsProvider.notifier)
          .setYtmAccount(loggedIn: true, name: 'YouTube Music Account'),
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signed in! Importing Likes & Listening History...'),
      ),
    );

    try {
      final tracks = await fetchAccountMusic(cookie);
      if (!context.mounted) return;
      if (tracks.isNotEmpty) {
        ref.read(statsRepositoryProvider).recordImportedFavorites(tracks);
        ref.read(libraryRepositoryProvider).addLikedTracks(tracks);
        ref
          ..invalidate(recommendedForYouProvider)
          ..invalidate(aiMixesProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully imported ${tracks.length} songs '
              'from YouTube Music!',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Connected! No existing likes or history found to import.',
            ),
          ),
        );
      }
    } on Object catch (e) {
      Log.w('Failed during import: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import encountered an issue: $e')),
      );
    }
  }
}
