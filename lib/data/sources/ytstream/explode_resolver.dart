import 'dart:async';

import 'package:awady_music/data/models/stream_info.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' hide StreamInfo;

void _log(String msg) {
  // Silent fallback for standalone CLI scripts without Flutter engine
}

/// Fallback stream resolver using the `youtube_explode_dart` client.
class YoutubeExplodeResolver {
  const YoutubeExplodeResolver();

  /// Resolves the best available audio stream for [videoId].
  Future<StreamInfo?> resolve(
    String videoId, {
    bool isIos = false,
    YoutubeExplode? ytOverride,
  }) async {
    final yt = ytOverride ?? YoutubeExplode();
    final shouldClose = ytOverride == null;

    try {
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      final audioStreams = manifest.audioOnly.toList();

      if (audioStreams.isEmpty) return null;

      audioStreams.sort((a, b) {
        final isMp4A =
            a.container.name.toLowerCase().contains('mp4') ||
            a.audioCodec.toLowerCase().contains('mp4');
        final isMp4B =
            b.container.name.toLowerCase().contains('mp4') ||
            b.audioCodec.toLowerCase().contains('mp4');

        if (isIos && isMp4A != isMp4B) {
          return isMp4A ? -1 : 1;
        }

        return b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond);
      });

      final stream = audioStreams.first;
      final uri = stream.url;

      final expireStr = uri.queryParameters['expire'];
      final expireSec = int.tryParse(expireStr ?? '');
      final expiresAt = expireSec != null
          ? DateTime.fromMillisecondsSinceEpoch(expireSec * 1000)
                .subtract(const Duration(minutes: 10))
          : DateTime.now().add(const Duration(hours: 5));

      return StreamInfo(
        url: uri,
        expiresAt: expiresAt,
        mimeType: 'audio/${stream.container.name}',
        bitrate: stream.bitrate.bitsPerSecond,
      );
    } on Exception catch (e) {
      _log('YoutubeExplode resolver failed for $videoId: $e');
      return null;
    } finally {
      if (shouldClose) {
        yt.close();
      }
    }
  }
}
