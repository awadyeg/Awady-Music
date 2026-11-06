import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/player/connect_protocol.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConnectMessage Protocol Tests', () {
    const sampleTrack = Track(
      id: 't_connect_1',
      title: 'Starboy',
      artist: Artist(id: 'a1', name: 'The Weeknd'),
      duration: 230,
    );

    test('syncQueue encode and decode preserves full state', () {
      final msg = ConnectMessage.syncQueue(
        queue: const [sampleTrack],
        index: 0,
        positionMs: 45000,
        isPlaying: true,
        senderName: 'Awady Pixel 8',
      );

      final encoded = msg.encode();
      final decoded = ConnectMessage.tryDecode(encoded);

      expect(decoded, isNotNull);
      expect(decoded!.action, 'sync_queue');
      expect(decoded.index, 0);
      expect(decoded.positionMs, 45000);
      expect(decoded.isPlaying, isTrue);
      expect(decoded.senderName, 'Awady Pixel 8');
      expect(decoded.queue, isNotNull);
      expect(decoded.queue!.length, 1);
      expect(decoded.queue!.first.id, 't_connect_1');
      expect(decoded.queue!.first.title, 'Starboy');
    });

    test('playback commands encode and decode accurately', () {
      expect(
        ConnectMessage.tryDecode(ConnectMessage.play().encode())?.action,
        'play',
      );
      expect(
        ConnectMessage.tryDecode(ConnectMessage.pause().encode())?.action,
        'pause',
      );
      expect(
        ConnectMessage.tryDecode(ConnectMessage.next().encode())?.action,
        'next',
      );
      expect(
        ConnectMessage.tryDecode(ConnectMessage.prev().encode())?.action,
        'prev',
      );

      final seekMsg = ConnectMessage.tryDecode(
        ConnectMessage.seek(60000).encode(),
      );
      expect(seekMsg?.action, 'seek');
      expect(seekMsg?.positionMs, 60000);

      final volMsg = ConnectMessage.tryDecode(
        ConnectMessage.volume(0.85).encode(),
      );
      expect(volMsg?.action, 'volume');
      expect(volMsg?.volume, closeTo(0.85, 0.001));
    });

    test('stateUpdate encodes and decodes track metadata and state', () {
      final msg = ConnectMessage.stateUpdate(
        isPlaying: true,
        positionMs: 12000,
        durationMs: 230000,
        index: 1,
        track: sampleTrack,
        volume: 0.9,
      );

      final decoded = ConnectMessage.tryDecode(msg.encode());
      expect(decoded, isNotNull);
      expect(decoded!.action, 'state_update');
      expect(decoded.isPlaying, isTrue);
      expect(decoded.positionMs, 12000);
      expect(decoded.durationMs, 230000);
      expect(decoded.index, 1);
      expect(decoded.track?.title, 'Starboy');
      expect(decoded.volume, closeTo(0.9, 0.001));
    });

    test('gracefully returns null on malformed json input', () {
      expect(ConnectMessage.tryDecode('not a json string'), isNull);
      expect(ConnectMessage.tryDecode(null), isNull);
      expect(ConnectMessage.tryDecode(12345), isNull);
    });
  });
}
