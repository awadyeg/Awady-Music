import 'dart:convert';
import 'dart:typed_data';

import 'package:awady_music/player/chromecast_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CastMessage Protobuf Encoding & Decoding Tests', () {
    test('Roundtrip encoding and decoding preserves all fields', () {
      const original = CastMessage(
        sourceId: 'sender-0',
        destinationId: 'receiver-0',
        namespace: 'urn:x-cast:com.google.cast.tp.connection',
        payloadUtf8: '{"type":"CONNECT"}',
      );

      final framed = original.toFramedBytes();
      expect(framed.length, greaterThan(4));

      // Extract 4-byte big-endian length prefix
      final len = ByteData.view(framed.buffer).getUint32(0);
      expect(len, framed.length - 4);

      // Parse payload without the 4-byte prefix
      final parsed = CastMessage.tryParse(Uint8List.sublistView(framed, 4));
      expect(parsed, isNotNull);
      expect(parsed!.sourceId, 'sender-0');
      expect(parsed.destinationId, 'receiver-0');
      expect(parsed.namespace, 'urn:x-cast:com.google.cast.tp.connection');
      expect(parsed.payloadUtf8, '{"type":"CONNECT"}');
    });

    test('Encodes and parses complex UTF-8 characters accurately', () {
      const msg = CastMessage(
        sourceId: 'client-app',
        destinationId: 'web-session-1234',
        namespace: 'urn:x-cast:com.google.cast.media',
        payloadUtf8: '{"title":"عمرو دياب - يا أنا يا لأ 🎵"}',
      );

      final framed = msg.toFramedBytes();
      final parsed = CastMessage.tryParse(Uint8List.sublistView(framed, 4));

      expect(parsed, isNotNull);
      expect(parsed!.payloadUtf8, contains('عمرو دياب'));
      expect(parsed.payloadUtf8, contains('🎵'));
      final decodedJson =
          jsonDecode(parsed.payloadUtf8) as Map<String, dynamic>;
      expect(decodedJson['title'], 'عمرو دياب - يا أنا يا لأ 🎵');
    });

    test('Gracefully returns null for empty or corrupted bytes', () {
      expect(CastMessage.tryParse(Uint8List(0)), isNull);
      expect(CastMessage.tryParse(Uint8List.fromList([0xff, 0xff])), isNull);
    });
  });

  group('LocalAudioProxyServer Tests', () {
    test(
      'getLocalIp returns non-empty local IP or handles gracefully',
      () async {
        final ip = await LocalAudioProxyServer.getLocalIp();
        if (ip != null) {
          expect(ip, isNotEmpty);
        }
      },
    );
  });
}
