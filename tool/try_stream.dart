import 'dart:io';

import 'package:awady_music/data/sources/ytstream/stream_resolver_impl.dart';

Future<void> main(List<String> args) async {
  final videoId = args.isNotEmpty ? args.first : 'dQw4w9WgXcQ';
  stdout.writeln('Resolving stream for videoId: $videoId ...');

  final resolver = StreamResolverImpl();
  try {
    final info = await resolver.resolve(videoId);
    stdout
      ..writeln('Stream resolved successfully!')
      ..writeln('URL: ${info.url}')
      ..writeln('Expires at: ${info.expiresAt}')
      ..writeln('MimeType: ${info.mimeType}')
      ..writeln('Bitrate: ${info.bitrate}')
      ..writeln('Loudness: ${info.loudnessDb} dB');
  } on Exception catch (e) {
    stderr.writeln('Error resolving stream: $e');
    exit(1);
  }
}
