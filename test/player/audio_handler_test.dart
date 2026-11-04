import 'package:audio_service/audio_service.dart';
import 'package:awady_music/player/audio_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AwadyAudioHandler tests', () {
    test('initializes and reports initial playback state', () async {
      final handler = AwadyAudioHandler();
      expect(
        handler.playbackState.value.processingState,
        AudioProcessingState.idle,
      );
      expect(handler.playbackState.value.playing, false);

      const item = MediaItem(
        id: 'test-1',
        title: 'Test Song',
        artist: 'Test Artist',
        duration: Duration(seconds: 180),
      );
      handler.updateCurrentMediaItem(item);
      expect(handler.mediaItem.value?.id, 'test-1');
      expect(handler.mediaItem.value?.title, 'Test Song');

      handler.updateCurrentQueue([item]);
      expect(handler.queue.value.length, 1);
      expect(handler.queue.value.first.id, 'test-1');

      handler.setCurrentQueueIndex(0);
      expect(handler.playbackState.value.queueIndex, 0);

      await handler.dispose();
    });

    test('invokes coordination callbacks on skip and play/pause', () async {
      final handler = AwadyAudioHandler();

      var playCalled = false;
      var pauseCalled = false;
      var nextCalled = false;
      var prevCalled = false;
      var skipToQueueItemIndex = -1;

      handler
        ..onPlayRequested = () async {
          playCalled = true;
        }
        ..onPauseRequested = () async {
          pauseCalled = true;
        }
        ..onSkipToNextRequested = () async {
          nextCalled = true;
        }
        ..onSkipToPreviousRequested = () async {
          prevCalled = true;
        }
        ..onSkipToQueueItemRequested = (index) async {
          skipToQueueItemIndex = index;
        };

      await handler.play();
      expect(playCalled, true);

      await handler.pause();
      expect(pauseCalled, true);

      await handler.skipToNext();
      expect(nextCalled, true);

      await handler.skipToPrevious();
      expect(prevCalled, true);

      await handler.skipToQueueItem(3);
      expect(skipToQueueItemIndex, 3);

      await handler.dispose();
    });

    test('seek, volume, and speed call underlying player', () async {
      final handler = AwadyAudioHandler();

      await handler.setSpeed(1.25);
      await handler.setVolume(0.8);
      await handler.seek(const Duration(seconds: 45));

      expect(handler.player.speed, 1.25);
      expect(handler.player.volume, closeTo(0.8, 0.01));

      await handler.dispose();
    });
  });
}
