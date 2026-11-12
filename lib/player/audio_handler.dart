import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:awady_music/core/util/log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// Provider holding the initialized [AwadyAudioHandler].
/// In production, this is overridden with the result of
/// [AudioService.init].
/// In tests, it defaults to a [NoopAudioHandler] so widget tests
/// can run without platform audio setup.
final audioHandlerProvider = Provider<AwadyAudioHandler>((ref) {
  return NoopAudioHandler();
});

/// Fallback audio handler for tests or pre-initialization environments.
class NoopAudioHandler extends AwadyAudioHandler {
  NoopAudioHandler({super.player});

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<Duration?> setAudioSource(
    AudioSource source, {
    Duration? initialPosition,
    bool preload = true,
  }) async {
    return const Duration(seconds: 180);
  }

  @override
  Future<void> playPlayer() async {}

  @override
  Future<void> pausePlayer() async {}
}

/// Background audio handler integrating `just_audio` with `audio_service`.
class AwadyAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  AwadyAudioHandler({
    AudioPlayer? player,
    this.equalizer,
    this.loudnessEnhancer,
  }) : _player = player ?? AudioPlayer() {
    _init();
  }

  /// Factory creating [AwadyAudioHandler] with Android audio effects
  /// pipeline on Android.
  factory AwadyAudioHandler.create() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final eq = AndroidEqualizer();
      final le = AndroidLoudnessEnhancer();
      final player = AudioPlayer(
        audioPipeline: AudioPipeline(androidAudioEffects: [eq, le]),
      );
      return AwadyAudioHandler(
        player: player,
        equalizer: eq,
        loudnessEnhancer: le,
      );
    }
    return AwadyAudioHandler();
  }

  final AudioPlayer _player;
  final AndroidEqualizer? equalizer;
  final AndroidLoudnessEnhancer? loudnessEnhancer;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  // Hooks for PlayerController coordination
  Future<void> Function()? onPlayRequested;
  Future<void> Function()? onPauseRequested;
  Future<void> Function()? onSkipToNextRequested;
  Future<void> Function()? onSkipToPreviousRequested;
  Future<void> Function(int index)? onSkipToQueueItemRequested;
  void Function()? onPlaybackCompleted;

  // Android Auto / MediaBrowser hooks
  Future<List<MediaItem>> Function(String parentMediaId)? onGetChildren;
  Future<void> Function(String mediaId)? onPlayFromMediaId;
  Future<void> Function(String query)? onPlayFromSearch;
  Future<List<MediaItem>> Function(String query)? onSearch;

  int? _currentQueueIndex;

  AudioPlayer get player => _player;

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<Duration?> get durationStream => _player.durationStream;

  void setCurrentQueueIndex(int? index) {
    _currentQueueIndex = index;
    _broadcastState();
  }

  void updateCurrentMediaItem(MediaItem item) {
    mediaItem.add(item);
    _broadcastState();
  }

  void updateCurrentQueue(List<MediaItem> items) {
    queue.add(items);
  }

  void _init() {
    _subscriptions.add(
      _player.playbackEventStream.listen(
        (event) => _broadcastState(),
        onError: (Object e, StackTrace st) {
          Log.e('AudioHandler playback event error', e, st);
        },
      ),
    );

    _subscriptions.add(
      _player.playerStateStream.listen((state) {
        _broadcastState();
        if (state.processingState == ProcessingState.completed) {
          onPlaybackCompleted?.call();
        }
      }),
    );

    _subscriptions.add(
      _player.playingStream.listen((_) {
        _broadcastState();
      }),
    );

    _subscriptions.add(
      _player.durationStream.listen((d) {
        if (d != null && d > Duration.zero) {
          final current = mediaItem.value;
          if (current != null && current.duration != d) {
            mediaItem.add(current.copyWith(duration: d));
            _broadcastState();
          }
        }
      }),
    );
  }

  void _broadcastState() {
    final processingState = switch (_player.processingState) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    };

    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (_player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.setShuffleMode,
          MediaAction.setRepeatMode,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: processingState,
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _currentQueueIndex,
      ),
    );
  }

  Future<void> playPlayer() async {
    unawaited(_player.play());
    _broadcastState();
  }

  Future<void> pausePlayer() async {
    await _player.pause();
    _broadcastState();
  }

  @override
  Future<void> play() async {
    if (onPlayRequested != null) {
      await onPlayRequested!();
    } else {
      await _player.play();
    }
  }

  @override
  Future<void> pause() async {
    if (onPauseRequested != null) {
      await onPauseRequested!();
    } else {
      await _player.pause();
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await playbackState
        .firstWhere(
          (state) => state.processingState == AudioProcessingState.idle,
        )
        .timeout(
          const Duration(milliseconds: 500),
          onTimeout: () => playbackState.value,
        );
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (onSkipToNextRequested != null) {
      await onSkipToNextRequested!();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (onSkipToPreviousRequested != null) {
      await onSkipToPreviousRequested!();
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (onSkipToQueueItemRequested != null) {
      await onSkipToQueueItemRequested!(index);
    }
  }

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<List<MediaItem>> getChildren(
    String parentMediaId, [
    Map<String, dynamic>? options,
  ]) async {
    if (onGetChildren != null) {
      return await onGetChildren!(parentMediaId);
    }
    return queue.value;
  }

  @override
  Future<void> playFromMediaId(
    String mediaId, [
    Map<String, dynamic>? extras,
  ]) async {
    if (onPlayFromMediaId != null) {
      await onPlayFromMediaId!(mediaId);
    }
  }

  @override
  Future<void> playFromSearch(
    String query, [
    Map<String, dynamic>? extras,
  ]) async {
    if (onPlayFromSearch != null) {
      await onPlayFromSearch!(query);
    }
  }

  @override
  Future<List<MediaItem>> search(
    String query, [
    Map<String, dynamic>? extras,
  ]) async {
    if (onSearch != null) {
      return await onSearch!(query);
    }
    return const [];
  }

  Future<void> setVolume(double volume) => _player.setVolume(volume);

  Future<Duration?> setAudioSource(
    AudioSource source, {
    Duration? initialPosition,
    bool preload = true,
  }) {
    return _player.setAudioSource(
      source,
      initialPosition: initialPosition,
      preload: preload,
    );
  }

  Future<void> dispose() async {
    for (final s in _subscriptions) {
      await s.cancel();
    }
    _subscriptions.clear();
    await _player.dispose();
  }
}

/// Initializes AudioSession for background music playback.
Future<void> initAudioSession() async {
  try {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  } on Object catch (e, st) {
    Log.w('Failed to configure AudioSession: $e', e, st);
  }
}
