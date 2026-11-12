import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef TrackSuggestion = ({String title, String artist});

class ClaudeAiClient {
  ClaudeAiClient({
    this.apiKey = '',
    this.baseUrl = 'https://api.anthropic.com',
    this.model = 'claude-sonnet-5-5',
    this.enabled = true,
    this.httpClient,
  });

  final String apiKey;
  final String baseUrl;
  final String model;
  final bool enabled;
  final HttpClient? httpClient;

  static final Map<String, ({DateTime expiresAt, List<TrackSuggestion> items})>
  _cache = {};

  static void clearCache() => _cache.clear();

  static List<TrackSuggestion> parseTrackSuggestions(String raw) {
    try {
      final start = raw.indexOf('[');
      final end = raw.lastIndexOf(']');
      if (start == -1 || end == -1 || end <= start) {
        return const [];
      }
      final jsonSub = raw.substring(start, end + 1);
      final decoded = jsonDecode(jsonSub);
      if (decoded is! List) return const [];

      final results = <TrackSuggestion>[];
      for (final item in decoded) {
        if (item is Map) {
          final title = (item['title'] ?? item['song'] ?? item['name'] ?? '')
              .toString()
              .trim();
          final artist = (item['artist'] ?? item['singer'] ?? '')
              .toString()
              .trim();
          if (title.isNotEmpty && artist.isNotEmpty) {
            results.add((title: title, artist: artist));
          }
        }
      }
      return results;
    } on Object catch (_) {
      return const [];
    }
  }

  Future<List<TrackSuggestion>> suggestSimilarForSearch({
    required String query,
    Track? topTrack,
    int limit = 8,
  }) async {
    const systemPrompt =
        'You are Claude Code Music AI curator. Return ONLY a valid JSON '
        'array of objects [{"title": "Song Title", "artist": "Artist Name"}] '
        'with no markdown or extra text. Suggest songs with the exact same '
        'musical mood, style, tempo, language/culture, and vibe across '
        'diverse artists (do not repeat the same artist more than once).';

    final userPrompt = topTrack != null
        ? 'User searched for "$query". Top matched song: "${topTrack.title}" '
              'by "${topTrack.artist.name}". Suggest $limit similar songs '
              'that fans of this song would love.'
        : 'User searched for "$query". Suggest $limit songs that match '
              'this musical vibe across diverse artists.';

    return await _completeJson(systemPrompt, userPrompt);
  }

  Future<List<TrackSuggestion>> suggestRecommendations({
    required List<Track> likedTracks,
    required List<Artist> followedArtists,
    required List<Track> recentTracks,
    String countryCode = 'EG',
    int limit = 12,
  }) async {
    const systemPrompt =
        'You are Claude Code Music AI curator. Return ONLY a valid JSON '
        'array of objects [{"title": "Song Title", "artist": "Artist Name"}] '
        'with no markdown or extra text. Suggest fresh, exciting songs '
        'tailored to the listener taste profile across diverse artists '
        '(maximum one song per artist).';

    final likesSummary = likedTracks
        .take(10)
        .map((t) => '"${t.title}" by ${t.artist.name}')
        .join(', ');
    final artistsSummary = followedArtists
        .take(5)
        .map((a) => a.name)
        .join(', ');
    final recentsSummary = recentTracks
        .take(5)
        .map((t) => '"${t.title}" by ${t.artist.name}')
        .join(', ');

    final userPrompt =
        'Listener profile in $countryCode: Liked: [$likesSummary]. '
        'Followed artists: [$artistsSummary]. '
        'Recently played: [$recentsSummary]. '
        'Suggest $limit tailored recommendations across diverse artists.';

    return await _completeJson(systemPrompt, userPrompt);
  }

  Future<List<TrackSuggestion>> suggestForMix({
    required List<Track> seedTracks,
    String? mixTheme,
    int limit = 8,
  }) async {
    const systemPrompt =
        'You are Claude Code Music AI curator. Return ONLY a valid JSON '
        'array of objects [{"title": "Song Title", "artist": "Artist Name"}] '
        'with no markdown or extra text. Suggest songs that blend seamlessly '
        'in mood, BPM, genre, and aesthetic with the seed tracks across '
        'diverse artists (maximum one song per artist).';

    final seeds = seedTracks
        .take(8)
        .map((t) => '"${t.title}" by ${t.artist.name}')
        .join(', ');

    final themeSuffix = mixTheme != null && mixTheme.isNotEmpty
        ? 'Mix theme: $mixTheme. '
        : '';
    final userPrompt =
        'Seed tracks: [$seeds]. $themeSuffix'
        'Suggest $limit songs that seamlessly continue this mix.';

    return await _completeJson(systemPrompt, userPrompt);
  }

  Future<List<TrackSuggestion>> suggestForMood({
    required String moodName,
    String? moodQuery,
    List<Track> seedTracks = const [],
    int limit = 10,
  }) async {
    const systemPrompt =
        'You are Claude Code Music AI curator. Return ONLY a valid JSON '
        'array of objects [{"title": "Song Title", "artist": "Artist Name"}] '
        'with no markdown or extra text. Suggest iconic, authentic, '
        'high-quality songs that strictly match the mood/genre across diverse '
        'artists (max 1 song per artist).';

    final queryStr = moodQuery != null && moodQuery.isNotEmpty
        ? moodQuery
        : moodName;
    final seedJoin = seedTracks
        .take(5)
        .map((t) => '"${t.title}" by ${t.artist.name}')
        .join(', ');
    final seeds = seedTracks.isNotEmpty
        ? ' Listener cultural/language vibe based on favorite tracks: '
              '$seedJoin.'
        : '';

    final userPrompt =
        'Mood/Genre: "$moodName" (query: "$queryStr").$seeds '
        'Suggest $limit iconic, authentic songs matching this mood strictly '
        'across diverse artists.';

    return await _completeJson(systemPrompt, userPrompt);
  }

  Future<List<TrackSuggestion>> _completeJson(
    String systemPrompt,
    String userPrompt,
  ) async {
    if (!enabled) return const [];

    final cacheKey = '$systemPrompt|$userPrompt';
    final cached = _cache[cacheKey];
    if (cached != null && DateTime.now().isBefore(cached.expiresAt)) {
      return cached.items;
    }

    try {
      final rawResponse = await _sendRequest(
        systemPrompt,
        userPrompt,
      ).timeout(const Duration(seconds: 6));
      final parsed = parseTrackSuggestions(rawResponse);
      if (parsed.isNotEmpty) {
        _cache[cacheKey] = (
          expiresAt: DateTime.now().add(const Duration(minutes: 15)),
          items: parsed,
        );
      }
      return parsed;
    } on Object catch (e) {
      Log.w('Claude AI request failed: $e');
      return const [];
    }
  }

  Future<String> _sendRequest(String systemPrompt, String userPrompt) async {
    final client =
        httpClient ??
        (HttpClient()..connectionTimeout = const Duration(seconds: 4));

    try {
      final key = apiKey.trim();
      final base = baseUrl.trim();

      if (key.isNotEmpty) {
        final isAnthropic =
            base.contains('anthropic.com') || base.endsWith('/v1/messages');

        if (isAnthropic) {
          final endpoint = base.endsWith('/v1/messages')
              ? base
              : '${base.replaceAll(RegExp(r'/$'), '')}/v1/messages';
          final uri = Uri.parse(endpoint);
          final req = await client.postUrl(uri);
          req.headers.set('x-api-key', key);
          req.headers.set('anthropic-version', '2023-06-01');
          req.headers.set('content-type', 'application/json');

          final payload = jsonEncode({
            'model': model,
            'max_tokens': 800,
            'system': systemPrompt,
            'messages': [
              {'role': 'user', 'content': userPrompt},
            ],
          });
          req.add(utf8.encode(payload));

          final res = await req.close();
          final body = await res.transform(utf8.decoder).join();
          if (res.statusCode == 200) {
            final data = jsonDecode(body);
            if (data is Map<String, dynamic>) {
              final content = data['content'] as List<dynamic>?;
              if (content != null && content.isNotEmpty) {
                final first = content.first as Map<String, dynamic>;
                return first['text']?.toString() ?? '';
              }
            }
          }
          return '';
        } else {
          // OpenAI / Proxy compatible
          final endpoint = base.endsWith('/completions')
              ? base
              : '${base.replaceAll(RegExp(r'/$'), '')}/v1/chat/completions';
          final uri = Uri.parse(endpoint);
          final req = await client.postUrl(uri);
          req.headers.set('Authorization', 'Bearer $key');
          req.headers.set('content-type', 'application/json');

          final payload = jsonEncode({
            'model': model,
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': userPrompt},
            ],
          });
          req.add(utf8.encode(payload));

          final res = await req.close();
          final body = await res.transform(utf8.decoder).join();
          if (res.statusCode == 200) {
            final data = jsonDecode(body);
            if (data is Map<String, dynamic>) {
              final choices = data['choices'] as List<dynamic>?;
              if (choices != null && choices.isNotEmpty) {
                final first = choices.first as Map<String, dynamic>;
                final msg = first['message'] as Map<String, dynamic>?;
                return msg?['content']?.toString() ?? '';
              }
            }
          }
          return '';
        }
      } else {
        // Zero-config mode: Pollinations OpenAI endpoint
        final uri = Uri.parse('https://text.pollinations.ai/openai');
        final req = await client.postUrl(uri);
        req.headers.set('content-type', 'application/json');

        final payload = jsonEncode({
          'model': 'openai',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
        });
        req.add(utf8.encode(payload));

        final res = await req.close();
        final body = await res.transform(utf8.decoder).join();
        if (res.statusCode == 200) {
          try {
            final data = jsonDecode(body);
            if (data is Map<String, dynamic>) {
              final choices = data['choices'] as List<dynamic>?;
              if (choices != null && choices.isNotEmpty) {
                final first = choices.first as Map<String, dynamic>;
                final msg = first['message'] as Map<String, dynamic>?;
                final content = msg?['content']?.toString();
                if (content != null && content.isNotEmpty) {
                  return content;
                }
              }
            }
          } on Object catch (_) {}
          return body;
        }
        return '';
      }
    } finally {
      if (httpClient == null) {
        client.close(force: true);
      }
    }
  }
}

final claudeAiClientProvider = Provider<ClaudeAiClient>((ref) {
  final apiKey = ref.watch(settingsProvider.select((s) => s.claudeApiKey));
  final baseUrl = ref.watch(settingsProvider.select((s) => s.claudeBaseUrl));
  final model = ref.watch(settingsProvider.select((s) => s.claudeModel));
  final enabled = ref.watch(settingsProvider.select((s) => s.enableClaudeAi));

  return ClaudeAiClient(
    apiKey: apiKey,
    baseUrl: baseUrl,
    model: model,
    enabled: enabled,
  );
});
