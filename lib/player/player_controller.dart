import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/models/track_validator.dart';
import 'package:awady_music/player/audio_handler.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension TrackMediaItemX on Track {
  MediaItem toMediaItem() {
    final artUrl =
        artwork?.s480 ?? artwork?.s1000 ?? artwork?.s150 ?? artwork?.fallback;
    return MediaItem(
      id: id,
      title: title,
      artist: artist.name,
      album: album?.name,
      duration: duration > 0 ? Duration(seconds: duration) : null,
      artUri: artUrl != null ? Uri.tryParse(artUrl) : null,
    );
  }
}

/// Helper to generate a Spotify-style shuffled deck of queue indices.
List<int> shuffledIndices(int count, int excludeIndex, [Random? random]) {
  final rng = random ?? Random();
  final list = [
    for (var i = 0; i < count; i++)
      if (i != excludeIndex) i,
  ];
  for (var i = list.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final temp = list[i];
    list[i] = list[j];
    list[j] = temp;
  }
  return list;
}

final playerControllerProvider =
    NotifierProvider<PlayerController, PlayerState>(PlayerController.new);

class PlayerController extends Notifier<PlayerState> {
  AwadyAudioHandler get _audioHandler => ref.read(audioHandlerProvider);
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Timer? _noticeTimer;

  // Circuit breaker & load sequence counters
  int loadSeq = 0;
  int autoFailStreak = 0;

  @override
  PlayerState build() {
    ref.onDispose(() {
      for (final s in _subscriptions) {
        unawaited(s.cancel());
      }
      _subscriptions.clear();
      _noticeTimer?.cancel();
    });

    _setupAudioHandlerHooks();
    return const PlayerState();
  }

  void _setupAudioHandlerHooks() {
    _audioHandler
      ..onPlayRequested = toggle
      ..onPauseRequested = toggle
      ..onSkipToNextRequested = () async {
        next();
      }
      ..onSkipToPreviousRequested = () async {
        prev();
      }
      ..onSkipToQueueItemRequested = (index) async {
        jumpTo(index);
      }
      ..onPlaybackCompleted = () {
        next(auto: true);
      };

    _subscriptions
      ..add(
        _audioHandler.playbackState.listen((ps) {
          state = state.copyWith(
            isPlaying: ps.playing,
            buffering:
                ps.processingState == AudioProcessingState.buffering ||
                ps.processingState == AudioProcessingState.loading,
            currentTime: ps.position,
          );
        }),
      )
      ..add(
        _audioHandler.player.positionStream.listen((pos) {
          state = state.copyWith(currentTime: pos);
        }),
      )
      ..add(
        _audioHandler.player.durationStream.listen((dur) {
          if (dur != null) {
            state = state.copyWith(duration: dur);
          }
        }),
      );
  }

  void notify(String message) {
    state = state.copyWith(notice: message);
    _noticeTimer?.cancel();
    _noticeTimer = Timer(const Duration(milliseconds: 4500), () {
      state = state.copyWith(notice: null);
    });
  }

  void playContext(List<Track> tracks, int index) {
    final playable = tracks.where(isPlayableTrack).toList();
    if (playable.isEmpty) {
      notify('core.nothingPlayable');
      return;
    }

    final target = index >= 0 && index < tracks.length ? tracks[index] : null;
    final i = target != null && playable.contains(target)
        ? playable.indexOf(target)
        : playable.indexWhere((t) => t.id == target?.id);

    if (i < 0) {
      notify('core.unavailable');
      return;
    }

    autoFailStreak = 0;
    final deck = state.shuffle ? shuffledIndices(playable.length, i) : <int>[];

    state = state.copyWith(
      queue: playable,
      history: const [],
      shuffleDeck: deck,
    );

    _audioHandler.updateCurrentQueue(
      playable.map((t) => t.toMediaItem()).toList(),
    );
    unawaited(loadAt(i));
  }

  void playTrack(Track track, [List<Track>? context]) {
    if (!isPlayableTrack(track)) {
      notify('core.unavailable');
      return;
    }

    if (context != null) {
      final i = context.indexWhere((t) => t.id == track.id);
      if (i >= 0) {
        playContext(context, i);
        return;
      }
    }

    autoFailStreak = 0;
    state = state.copyWith(
      queue: [track],
      history: const [],
      shuffleDeck: const [],
    );

    _audioHandler.updateCurrentQueue([track.toMediaItem()]);
    unawaited(loadAt(0));
  }

  Future<void> toggle() async {
    final current = state.current;
    if (current == null) return;

    if (state.isPlaying) {
      state = state.copyWith(isPlaying: false);
      await _audioHandler.player.pause();
    } else {
      state = state.copyWith(isPlaying: true);
      await _audioHandler.player.play();
    }
  }

  void next({bool auto = false}) {
    final queue = state.queue;
    final index = state.index;
    final history = state.history;
    final shuffle = state.shuffle;
    final repeat = state.repeat;
    final autoplay = state.autoplay;

    if (queue.isEmpty) return;

    if (auto && repeat == RepeatMode.one) {
      seek(Duration.zero);
      unawaited(_audioHandler.player.play());
      return;
    }

    if (!auto) {
      autoFailStreak = 0;
    }

    var nextIndex = index + 1;
    var deck = List<int>.from(state.shuffleDeck);

    if (shuffle && queue.length > 1) {
      while (deck.isNotEmpty &&
          (deck.first == index || deck.first >= queue.length)) {
        deck.removeAt(0);
      }

      if (deck.isEmpty && (repeat == RepeatMode.all || autoplay)) {
        deck = shuffledIndices(queue.length, index);
      }

      nextIndex = deck.isNotEmpty ? deck.removeAt(0) : queue.length;
    }

    if (nextIndex >= queue.length) {
      if (repeat == RepeatMode.all) {
        nextIndex = 0;
      } else if (!auto) {
        return;
      } else {
        unawaited(_audioHandler.player.pause());
        state = state.copyWith(isPlaying: false, buffering: false);
        return;
      }
    }

    final newHistory = [
      if (history.length >= 64)
        ...history.sublist(history.length - 63)
      else
        ...history,
      if (index >= 0) index,
    ];

    state = state.copyWith(history: newHistory, shuffleDeck: deck);

    unawaited(loadAt(nextIndex));
  }

  void prev() {
    final queue = state.queue;
    final index = state.index;
    final history = state.history;

    if (queue.isEmpty) return;

    if (state.currentTime.inSeconds > 3) {
      seek(Duration.zero);
      return;
    }

    autoFailStreak = 0;
    final prevIndex = history.isNotEmpty ? history.last : index - 1;
    final newHistory = history.isNotEmpty
        ? history.sublist(0, history.length - 1)
        : history;

    state = state.copyWith(history: newHistory);

    if (prevIndex >= 0 && prevIndex < queue.length) {
      unawaited(loadAt(prevIndex));
    } else {
      seek(Duration.zero);
    }
  }

  void seek(Duration position) {
    if (state.current == null) return;
    final maxDur = state.duration > Duration.zero
        ? state.duration
        : Duration(seconds: state.current!.duration);

    final clamped = maxDur > Duration.zero
        ? (position < Duration.zero
              ? Duration.zero
              : (position > maxDur ? maxDur : position))
        : (position < Duration.zero ? Duration.zero : position);

    unawaited(_audioHandler.seek(clamped));
    state = state.copyWith(currentTime: clamped);
  }

  void setVolume(double volume) {
    final vol = volume.clamp(0.0, 1.0);
    if (vol > 0 && state.muted) {
      state = state.copyWith(muted: false);
    }
    state = state.copyWith(volume: vol, muted: vol == 0.0 && state.muted);
    unawaited(_audioHandler.setVolume(vol));
  }

  void toggleMute() {
    final m = !state.muted;
    state = state.copyWith(muted: m);
    unawaited(_audioHandler.setVolume(m ? 0.0 : state.volume));
  }

  void toggleShuffle() {
    final newShuffle = !state.shuffle;
    final deck = newShuffle && state.queue.length > 1
        ? shuffledIndices(state.queue.length, state.index)
        : <int>[];

    state = state.copyWith(shuffle: newShuffle, shuffleDeck: deck);
  }

  void cycleRepeat() {
    const order = [RepeatMode.off, RepeatMode.all, RepeatMode.one];
    final nextIdx = (order.indexOf(state.repeat) + 1) % order.length;
    state = state.copyWith(repeat: order[nextIdx]);
  }

  void jumpTo(int i) {
    final queue = state.queue;
    final index = state.index;
    if (i == index ||
        i < 0 ||
        i >= queue.length ||
        !isPlayableTrack(queue[i])) {
      return;
    }

    autoFailStreak = 0;
    final newHistory = [
      if (state.history.length >= 64)
        ...state.history.sublist(state.history.length - 63)
      else
        ...state.history,
      if (index >= 0) index,
    ];

    final deck = state.shuffleDeck.where((d) => d != i).toList();

    state = state.copyWith(history: newHistory, shuffleDeck: deck);

    unawaited(loadAt(i));
  }

  void enqueue(Track track) {
    if (!isPlayableTrack(track)) {
      notify('core.unavailable');
      return;
    }

    if (state.index == -1 || state.queue.isEmpty) {
      playTrack(track);
      return;
    }

    if (state.queue.length >= 500) {
      notify('core.queueFull');
      return;
    }

    final prevLen = state.queue.length;
    final newQueue = [...state.queue, track];
    final deck = List<int>.from(state.shuffleDeck);

    if (state.shuffle) {
      final insertPos = deck.isEmpty ? 0 : Random().nextInt(deck.length + 1);
      deck.insert(insertPos, prevLen);
    }

    state = state.copyWith(queue: newQueue, shuffleDeck: deck);

    _audioHandler.updateCurrentQueue(
      newQueue.map((t) => t.toMediaItem()).toList(),
    );
    notify('core.addedQueue');
  }

  void playNextUp(Track track) {
    if (!isPlayableTrack(track)) {
      notify('core.unavailable');
      return;
    }

    if (state.index == -1 || state.queue.isEmpty) {
      playTrack(track);
      return;
    }

    final insertAt = state.index + 1;
    final newQueue = [...state.queue]..insert(insertAt, track);
    final newHistory = state.history
        .map((h) => h >= insertAt ? h + 1 : h)
        .toList();
    var deck = List<int>.from(state.shuffleDeck);

    if (state.shuffle) {
      deck = deck.map((d) => d >= insertAt ? d + 1 : d).toList()
        ..insert(0, insertAt);
    }

    state = state.copyWith(
      queue: newQueue,
      history: newHistory,
      shuffleDeck: deck,
    );

    _audioHandler.updateCurrentQueue(
      newQueue.map((t) => t.toMediaItem()).toList(),
    );
    notify('core.playNext');
  }

  void removeAt(int i) {
    final queue = state.queue;
    final index = state.index;
    if (i < 0 || i >= queue.length || i == index) return;

    final newQueue = queue.whereIndexed((n, _) => n != i).toList();
    final newIndex = i < index ? index - 1 : index;
    final newHistory = state.history
        .where((h) => h != i)
        .map((h) => h > i ? h - 1 : h)
        .toList();
    final deck = state.shuffleDeck
        .where((d) => d != i)
        .map((d) => d > i ? d - 1 : d)
        .toList();

    state = state.copyWith(
      queue: newQueue,
      index: newIndex,
      history: newHistory,
      shuffleDeck: deck,
    );

    _audioHandler
      ..updateCurrentQueue(newQueue.map((t) => t.toMediaItem()).toList())
      ..setCurrentQueueIndex(newIndex);
  }

  void clearQueue() {
    final current = state.current;
    final index = state.index;

    if (index >= 0 && current != null) {
      state = state.copyWith(
        queue: [current],
        index: 0,
        history: const [],
        shuffleDeck: const [],
      );
      _audioHandler
        ..updateCurrentQueue([current.toMediaItem()])
        ..setCurrentQueueIndex(0);
    } else {
      state = state.copyWith(
        queue: const [],
        index: -1,
        history: const [],
        shuffleDeck: const [],
      );
      _audioHandler
        ..updateCurrentQueue(const [])
        ..setCurrentQueueIndex(null);
    }
  }

  void moveInQueue(int from, int to) {
    final queue = state.queue;
    final index = state.index;

    if (from == to ||
        from == index ||
        from < 0 ||
        from >= queue.length ||
        to < 0 ||
        to >= queue.length) {
      return;
    }

    final newQueue = [...queue];
    final item = newQueue.removeAt(from);
    newQueue.insert(to, item);

    final newIndex = index > from && index <= to
        ? index - 1
        : (index < from && index >= to ? index + 1 : index);

    int remap(int h) => h == from
        ? to
        : (h > from && h <= to ? h - 1 : (h < from && h >= to ? h + 1 : h));

    final newHistory = state.history.map(remap).toList();
    final deck = state.shuffleDeck.map(remap).toList();

    state = state.copyWith(
      queue: newQueue,
      index: newIndex,
      history: newHistory,
      shuffleDeck: deck,
    );

    _audioHandler
      ..updateCurrentQueue(newQueue.map((t) => t.toMediaItem()).toList())
      ..setCurrentQueueIndex(newIndex);
  }

  void setNpOpen({required bool value}) =>
      state = state.copyWith(npOpen: value);
  void setQueueOpen({required bool value}) =>
      state = state.copyWith(queueOpen: value);
  void setAutoplay({required bool value}) =>
      state = state.copyWith(autoplay: value);

  /// Loads and plays track at [index].
  Future<void> loadAt(int index, [Duration? startPos]) async {
    if (index < 0 || index >= state.queue.length) return;
    final track = state.queue[index];

    final seq = ++loadSeq;
    state = state.copyWith(
      index: index,
      buffering: true,
      isPlaying: true,
      currentTime: startPos ?? Duration.zero,
      duration: Duration(seconds: track.duration),
    );

    _audioHandler
      ..setCurrentQueueIndex(index)
      ..updateCurrentMediaItem(track.toMediaItem());

    // In T-29 core, set state and invoke handler.
    // In T-30, StreamResolver pipeline runs here.
    if (seq == loadSeq) {
      state = state.copyWith(buffering: false, isPlaying: true);
    }
  }
}

extension IterableIndexed<E> on Iterable<E> {
  Iterable<E> whereIndexed(bool Function(int index, E element) test) sync* {
    var index = 0;
    for (final element in this) {
      if (test(index++, element)) yield element;
    }
  }
}
