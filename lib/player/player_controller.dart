import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/data/db/app_database.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/models/track_validator.dart';
import 'package:awady_music/data/repositories/stats_repository.dart';
import 'package:awady_music/data/sources/audius/audius_client.dart';
import 'package:awady_music/data/sources/deezer/deezer_client.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:awady_music/data/sources/innertube/matcher.dart';
import 'package:awady_music/data/sources/ytstream/client_constants.dart';
import 'package:awady_music/data/sources/ytstream/stream_resolver_impl.dart';
import 'package:awady_music/data/sources/ytstream/stream_resolver_provider.dart';
import 'package:awady_music/player/audio_handler.dart';
import 'package:awady_music/player/eq.dart';
import 'package:awady_music/player/loudness.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:awady_music/widgets/artwork_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;
import 'package:shared_preferences/shared_preferences.dart';

extension TrackMediaItemX on Track {
  MediaItem toMediaItem() {
    final rawArtUrl =
        artwork?.s1000 ?? artwork?.s480 ?? artwork?.s150 ?? artwork?.fallback;
    Uri? artUri;
    if (rawArtUrl != null && rawArtUrl.isNotEmpty) {
      if (ArtworkImage.isLocalPath(rawArtUrl)) {
        final cleanPath = rawArtUrl.startsWith('file://')
            ? rawArtUrl.substring(7)
            : rawArtUrl;
        artUri = Uri.file(cleanPath);
      } else {
        artUri = Uri.tryParse(ArtworkImage.upscaleUrl(rawArtUrl));
      }
    }
    return MediaItem(
      id: id,
      title: title,
      artist: artist.name,
      album: album?.name,
      duration: duration > 0 ? Duration(seconds: duration) : null,
      artUri: artUri,
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

/// Normalizes a track title for deduplication against remixes/accents/brackets.
/// Ported exactly from upstream `player.ts:normTitle`.
String normTitle(String title) {
  return fold(title)
      .toLowerCase()
      .replaceAll(RegExp(r'\s*(\([^)]*\)|\[[^\]]*\]|\|.*)$'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

final playerControllerProvider =
    NotifierProvider<PlayerController, PlayerState>(PlayerController.new);

class PlayerController extends Notifier<PlayerState> {
  AwadyAudioHandler get _audioHandler => ref.read(audioHandlerProvider);
  StreamResolver get _streamResolver => ref.read(streamResolverProvider);
  AudiusClient get _audiusClient => ref.read(audiusClientProvider);
  InnertubeClient get _innertubeClient => ref.read(innertubeClientProvider);
  DeezerClient get _deezerClient => ref.read(deezerClientProvider);
  AppDatabase get _db => ref.read(appDatabaseProvider);
  late StatsRepository _statsRepo;

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Timer? _noticeTimer;
  Timer? _saveQueueDebounceTimer;
  Timer? _sleepTimer;
  AppLifecycleListener? _lifecycleListener;
  DateTime _lastPositionPersist = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _positionPersistInterval = Duration(seconds: 5);

  // Circuit breaker & load sequence counters
  int loadSeq = 0;
  int autoFailStreak = 0;
  int streamRetries = 0;
  String? _prefetchedForTrackId;
  String? _autoCrossfadedForTrackId;

  final Set<String> _radioTried = {};
  ({String id, String tail})? _radioFilledFor;
  double? _currentLoudnessDb;

  late final EqualizerController _eqController;
  EqualizerController get eqController => _eqController;

  late final StatsRecorder _statsRecorder;
  StatsRecorder get statsRecorder => _statsRecorder;

  @override
  PlayerState build() {
    _statsRepo = ref.read(statsRepositoryProvider);
    _eqController = EqualizerController(equalizer: _audioHandler.equalizer);
    _statsRecorder = StatsRecorder(repository: _statsRepo);
    _prefetchedForTrackId = null;
    _autoCrossfadedForTrackId = null;
    ref.onDispose(() {
      for (final s in _subscriptions) {
        unawaited(s.cancel());
      }
      _subscriptions.clear();
      _noticeTimer?.cancel();
      _saveQueueDebounceTimer?.cancel();
      _sleepTimer?.cancel();
      _lifecycleListener?.dispose();
      _statsRepo.flush();
    });

    _setupAudioHandlerHooks();
    _setupLifecycleListener();
    unawaited(restorePersistedState());
    return const PlayerState();
  }

  void _publishSessionModes() {
    _audioHandler.setSessionModes(
      shuffleMode: state.shuffle
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
      repeatMode: switch (state.repeat) {
        RepeatMode.one => AudioServiceRepeatMode.one,
        RepeatMode.all => AudioServiceRepeatMode.all,
        RepeatMode.off => AudioServiceRepeatMode.none,
      },
    );
  }

  void _persistPositionThrottled() {
    if (state.queue.isEmpty) return;
    final now = DateTime.now();
    if (now.difference(_lastPositionPersist) < _positionPersistInterval) {
      return;
    }
    unawaited(saveQueueStateNow());
  }

  void _restoreSleepDeadline(int? sleepAtMs) {
    if (sleepAtMs == null || state.sleepAt != null) return;
    final deadline = DateTime.fromMillisecondsSinceEpoch(sleepAtMs);
    final remaining = deadline.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      unawaited(_removeSleepPref());
      return;
    }
    _sleepTimer?.cancel();
    state = state.copyWith(sleepAt: deadline);
    _sleepTimer = Timer(remaining, () async {
      _sleepTimer = null;
      state = state.copyWith(sleepAt: null, isPlaying: false);
      await _audioHandler.pausePlayer();
      await _removeSleepPref();
      await saveQueueStateNow();
    });
  }

  Future<void> _removeSleepPref() async {
    try {
      final prefs =
          ref.read(sharedPreferencesProvider) ??
          await SharedPreferences.getInstance();
      await prefs.remove('player_sleep_at_ms');
    } on Object catch (e) {
      Log.w('Failed clearing sleep timer: $e');
    }
  }

  void _setupLifecycleListener() {
    _lifecycleListener = AppLifecycleListener(
      onPause: () => unawaited(saveQueueStateNow()),
      onInactive: () => unawaited(saveQueueStateNow()),
      onHide: () => unawaited(saveQueueStateNow()),
    );
  }

  /// Restores queue, index, position, and settings from persistent storage.
  /// Audio playback is restored paused per spec.
  Future<void> restorePersistedState() async {
    // Let build() finish initializing notifier state before we read it.
    await Future<void>.value();
    if (!ref.mounted) return;

    int? sleepAtMs;
    try {
      final prefs =
          ref.read(sharedPreferencesProvider) ??
          await SharedPreferences.getInstance();
      sleepAtMs = prefs.getInt('player_sleep_at_ms');

      final volume = prefs.getDouble('player_volume') ?? 1.0;
      final muted = prefs.getBool('player_muted') ?? false;
      final shuffle = prefs.getBool('player_shuffle') ?? false;
      final repeatStr = prefs.getString('player_repeat') ?? 'off';
      final repeat = switch (repeatStr) {
        'one' => RepeatMode.one,
        'all' => RepeatMode.all,
        _ => RepeatMode.off,
      };
      final autoplay = prefs.getBool('player_autoplay') ?? true;
      final normOn = prefs.getBool('player_norm_on') ?? true;
      final fadeSecs = prefs.getInt('player_fade_secs') ?? 4;
      final eqStrings = prefs.getStringList('player_eq');
      var eq = state.eq;
      if (eqStrings != null && eqStrings.length == 7) {
        final parsed = eqStrings.map(double.tryParse).toList();
        if (parsed.every((v) => v != null)) {
          eq = parsed.cast<double>();
        }
      }
      unawaited(_eqController.applyGains(eq));

      final rawJson = await _db.getQueueState();
      var queue = <Track>[];
      var index = -1;
      var pos = Duration.zero;
      Track? current;

      if (rawJson != null && rawJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(rawJson);
          if (decoded is Map<String, dynamic>) {
            final rawQueue = decoded['queue'];
            queue = sanitizeTrackList(rawQueue, 300);

            final rawIndex = decoded['index'];
            if (rawIndex is int) {
              index = rawIndex.clamp(-1, queue.length - 1);
            }

            final rawPosMs = decoded['positionMs'];
            if (rawPosMs is int && rawPosMs > 0) {
              pos = Duration(milliseconds: rawPosMs);
            }

            final rawCurrent = decoded['current'];
            if (rawCurrent is Map<String, dynamic> &&
                isValidTrack(rawCurrent)) {
              current = slimTrack(repairTrack(Track.fromJson(rawCurrent)));
            } else if (index >= 0 && index < queue.length) {
              current = queue[index];
            }

            if (current != null) {
              final found = queue.indexWhere((t) => t.id == current!.id);
              if (found >= 0) {
                index = found;
              } else {
                queue = [current, ...queue];
                index = 0;
              }
            }
          }
        } on Object catch (e, st) {
          Log.w('Failed parsing persisted queue JSON: $e', e, st);
        }
      }

      if (!ref.mounted) return;

      if (state.queue.isNotEmpty || state.isPlaying) {
        state = state.copyWith(
          volume: volume,
          muted: muted,
          shuffle: shuffle,
          repeat: repeat,
          autoplay: autoplay,
          normOn: normOn,
          fadeSecs: fadeSecs,
          eq: eq,
        );
        return;
      }

      if (queue.isEmpty) {
        state = state.copyWith(
          volume: volume,
          muted: muted,
          shuffle: shuffle,
          repeat: repeat,
          autoplay: autoplay,
          normOn: normOn,
          fadeSecs: fadeSecs,
          eq: eq,
        );
        return;
      }

      final deck = shuffle && queue.isNotEmpty
          ? shuffledIndices(queue.length, index >= 0 ? index : 0)
          : <int>[];

      state = state.copyWith(
        volume: volume,
        muted: muted,
        shuffle: shuffle,
        repeat: repeat,
        autoplay: autoplay,
        normOn: normOn,
        fadeSecs: fadeSecs,
        eq: eq,
        queue: queue,
        index: index,
        currentTime: pos,
        shuffleDeck: deck,
        isPlaying: false,
        buffering: false,
      );

      if (queue.isNotEmpty) {
        _audioHandler
          ..updateCurrentQueue(queue.map((t) => t.toMediaItem()).toList())
          ..setCurrentQueueIndex(index >= 0 ? index : null);
        if (current != null) {
          _audioHandler.updateCurrentMediaItem(current.toMediaItem());
        }
      }
    } on Object catch (e, st) {
      Log.w('Failed restoring persisted player state: $e', e, st);
    } finally {
      if (ref.mounted) {
        _restoreSleepDeadline(sleepAtMs);
        _publishSessionModes();
      }
    }
  }

  /// Flushes current queue state, index, and playback position to DB
  /// immediately.
  Future<void> saveQueueStateNow() async {
    _saveQueueDebounceTimer?.cancel();
    _saveQueueDebounceTimer = null;
    _lastPositionPersist = DateTime.now();
    try {
      final slimmed = sanitizeTrackList(state.queue, 300);
      final jsonMap = {
        'queue': slimmed.map((t) => t.toJson()).toList(),
        'index': state.index,
        'positionMs': state.currentTime.inMilliseconds,
        'current': state.current != null
            ? slimTrack(state.current!).toJson()
            : null,
      };
      await _db.saveQueueState(jsonEncode(jsonMap));
    } on Object catch (e, st) {
      Log.w('Failed saving queue state: $e', e, st);
    }
  }

  void _scheduleSaveQueueState() {
    _saveQueueDebounceTimer?.cancel();
    _saveQueueDebounceTimer = Timer(const Duration(seconds: 2), () {
      unawaited(saveQueueStateNow());
    });
  }

  Future<void> _savePrefDouble(String key, double val) async {
    try {
      final prefs =
          ref.read(sharedPreferencesProvider) ??
          await SharedPreferences.getInstance();
      await prefs.setDouble(key, val);
    } on Object catch (e) {
      Log.w('Failed saving pref $key: $e');
    }
  }

  Future<void> _savePrefBool(String key, bool val) async {
    try {
      final prefs =
          ref.read(sharedPreferencesProvider) ??
          await SharedPreferences.getInstance();
      await prefs.setBool(key, val);
    } on Object catch (e) {
      Log.w('Failed saving pref $key: $e');
    }
  }

  Future<void> _savePrefString(String key, String val) async {
    try {
      final prefs =
          ref.read(sharedPreferencesProvider) ??
          await SharedPreferences.getInstance();
      await prefs.setString(key, val);
    } on Object catch (e) {
      Log.w('Failed saving pref $key: $e');
    }
  }

  Future<void> _savePrefInt(String key, int val) async {
    try {
      final prefs =
          ref.read(sharedPreferencesProvider) ??
          await SharedPreferences.getInstance();
      await prefs.setInt(key, val);
    } on Object catch (e) {
      Log.w('Failed saving pref $key: $e');
    }
  }

  /// Sets or cancels the sleep timer in [mins] minutes.
  /// When it fires, playback pauses and state is flushed to persistent storage.
  void setSleepTimer(int? mins) {
    if (mins == null || mins <= 0) {
      setSleepTimerDuration(null);
    } else {
      setSleepTimerDuration(Duration(minutes: mins));
    }
  }

  /// Sets or cancels the sleep timer with an explicit [Duration].
  void setSleepTimerDuration(Duration? duration) {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    if (duration == null || duration <= Duration.zero) {
      state = state.copyWith(sleepAt: null);
      unawaited(_removeSleepPref());
      return;
    }
    final target = DateTime.now().add(duration);
    state = state.copyWith(sleepAt: target);
    unawaited(
      _savePrefInt('player_sleep_at_ms', target.millisecondsSinceEpoch),
    );
    _sleepTimer = Timer(duration, () async {
      _sleepTimer = null;
      state = state.copyWith(sleepAt: null, isPlaying: false);
      await _audioHandler.pausePlayer();
      await _removeSleepPref();
      await saveQueueStateNow();
    });
  }

  void setNormOn({required bool value}) {
    state = state.copyWith(normOn: value);
    unawaited(_savePrefBool('player_norm_on', value));
    if (defaultTargetPlatform == TargetPlatform.android &&
        _audioHandler.loudnessEnhancer != null) {
      try {
        final gainDb = computeLoudnessGainDb(_currentLoudnessDb, normOn: value);
        unawaited(_audioHandler.loudnessEnhancer!.setEnabled(gainDb != 0));
        unawaited(_audioHandler.loudnessEnhancer!.setTargetGain(gainDb));
      } on Object catch (_) {}
    }
  }

  void setFadeSecs(int secs) {
    final clamped = secs.clamp(0, 12);
    state = state.copyWith(fadeSecs: clamped);
    unawaited(_savePrefInt('player_fade_secs', clamped));
  }

  void setEqBand(int index, double gainDb) {
    if (index < 0 || index >= 7) return;
    final newEq = List<double>.from(state.eq);
    newEq[index] = gainDb.clamp(eqMinGain, eqMaxGain);
    state = state.copyWith(eq: newEq);
    unawaited(_eqController.applyGains(newEq));
    unawaited(_savePrefEq(newEq));
  }

  void setEq(List<double> gains) {
    final newEq = List<double>.from(gains);
    while (newEq.length < 7) {
      newEq.add(0);
    }
    final truncated = newEq
        .take(7)
        .map((g) => g.clamp(eqMinGain, eqMaxGain))
        .toList();
    state = state.copyWith(eq: truncated);
    unawaited(_eqController.applyGains(truncated));
    unawaited(_savePrefEq(truncated));
  }

  void setEqPreset(String presetKey) {
    final presetGains = eqPresets[presetKey] ?? eqPresets['flat']!;
    setEq(presetGains);
  }

  Future<void> _savePrefEq(List<double> eq) async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs?.setStringList(
        'player_eq',
        eq.map((g) => g.toString()).toList(),
      );
    } on Object catch (_) {}
  }

  /// Ramps volume smoothly between [from] and [to] over [duration].
  Future<void> rampVolume({
    required double from,
    required double to,
    required Duration duration,
    int steps = 5,
  }) async {
    if (duration <= Duration.zero || steps <= 1) {
      await _audioHandler.setVolume(to);
      return;
    }
    final stepDuration = Duration(
      milliseconds: duration.inMilliseconds ~/ steps,
    );
    for (var i = 1; i <= steps; i++) {
      final frac = i / steps;
      final current = from + (to - from) * frac;
      await _audioHandler.setVolume(current);
      await Future<void>.delayed(stepDuration);
    }
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
      }
      ..onSeeked = (position) {
        if (!ref.mounted || state.current == null) return;
        state = state.copyWith(currentTime: position);
        _scheduleSaveQueueState();
      }
      ..onSetShuffleMode = (mode) async {
        final enable = mode != AudioServiceShuffleMode.none;
        if (enable == state.shuffle) {
          _publishSessionModes();
          return;
        }
        toggleShuffle();
      }
      ..onSetRepeatMode = (mode) async {
        final mapped = switch (mode) {
          AudioServiceRepeatMode.one => RepeatMode.one,
          AudioServiceRepeatMode.all ||
          AudioServiceRepeatMode.group => RepeatMode.all,
          AudioServiceRepeatMode.none => RepeatMode.off,
        };
        if (mapped == state.repeat) {
          _publishSessionModes();
          return;
        }
        state = state.copyWith(repeat: mapped);
        unawaited(_savePrefString('player_repeat', mapped.name));
        _publishSessionModes();
      };

    _subscriptions
      ..add(
        _audioHandler.playbackState.listen((ps) {
          if (_audioHandler.suppressPlaybackEcho) return;
          final wasPlaying = state.isPlaying;
          // Idle means the platform player has no active item. Headphone
          // disconnect and audio-focus loss pause a ready player instead, so
          // an idle echo must not clobber playback or start a persist.
          final platformIdle = ps.processingState == AudioProcessingState.idle;
          if (platformIdle) {
            state = state.copyWith(buffering: false);
          } else {
            state = state.copyWith(
              isPlaying: ps.playing,
              buffering:
                  ps.processingState == AudioProcessingState.buffering ||
                  ps.processingState == AudioProcessingState.loading,
              currentTime: ps.position,
            );
          }
          if (wasPlaying && !state.isPlaying) {
            unawaited(saveQueueStateNow());
            _statsRecorder.onTick(
              currentTrack: state.current,
              currentTimeSeconds: state.currentTime.inMilliseconds / 1000.0,
              isPlaying: false,
            );
          }
        }),
      )
      ..add(
        _audioHandler.positionStream.listen((pos) {
          if (state.isPlaying ||
              _audioHandler.playbackState.value.processingState !=
                  AudioProcessingState.idle) {
            state = state.copyWith(currentTime: pos);
            if (state.isPlaying) {
              _persistPositionThrottled();
            }
            _checkPrefetchAt50Percent(pos);
            final dur = state.duration;
            final cur = state.current;
            if (cur != null &&
                state.fadeSecs > 0 &&
                state.isPlaying &&
                dur > Duration(seconds: state.fadeSecs + 4) &&
                pos >= dur - Duration(seconds: (state.fadeSecs / 2).ceil()) &&
                _autoCrossfadedForTrackId != cur.id) {
              _autoCrossfadedForTrackId = cur.id;
              next(auto: true);
            }
            _statsRecorder.onTick(
              currentTrack: state.current,
              currentTimeSeconds: pos.inMilliseconds / 1000.0,
              isPlaying: state.isPlaying,
            );
          }
        }),
      )
      ..add(
        _audioHandler.durationStream.listen((dur) {
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
    _scheduleSaveQueueState();
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
      await _audioHandler.pausePlayer();
      await saveQueueStateNow();
    } else {
      final ps = _audioHandler.playbackState.value.processingState;
      if (ps == AudioProcessingState.idle) {
        await loadAt(state.index, startPos: state.currentTime);
      } else {
        state = state.copyWith(isPlaying: true);
        await _audioHandler.playPlayer();
      }
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
      unawaited(_audioHandler.playPlayer());
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
        unawaited(_audioHandler.pausePlayer());
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

    unawaited(loadAt(nextIndex, crossfade: auto));
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
    _scheduleSaveQueueState();
  }

  void setVolume(double volume) {
    final vol = volume.clamp(0.0, 1.0);
    final wasMuted = state.muted;
    final newMuted = vol == 0.0 && wasMuted;
    state = state.copyWith(volume: vol, muted: newMuted);
    unawaited(_audioHandler.setVolume(vol));
    unawaited(_savePrefDouble('player_volume', vol));
    unawaited(_savePrefBool('player_muted', newMuted));
  }

  void toggleMute() {
    final m = !state.muted;
    state = state.copyWith(muted: m);
    unawaited(_audioHandler.setVolume(m ? 0.0 : state.volume));
    unawaited(_savePrefBool('player_muted', m));
  }

  void toggleShuffle() {
    final newShuffle = !state.shuffle;
    final deck = newShuffle && state.queue.length > 1
        ? shuffledIndices(state.queue.length, state.index)
        : <int>[];

    state = state.copyWith(shuffle: newShuffle, shuffleDeck: deck);
    unawaited(_savePrefBool('player_shuffle', newShuffle));
    _publishSessionModes();
  }

  void cycleRepeat() {
    const order = [RepeatMode.off, RepeatMode.all, RepeatMode.one];
    final nextIdx = (order.indexOf(state.repeat) + 1) % order.length;
    final nextMode = order[nextIdx];
    state = state.copyWith(repeat: nextMode);
    unawaited(_savePrefString('player_repeat', nextMode.name));
    _publishSessionModes();
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
    _scheduleSaveQueueState();
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
    _scheduleSaveQueueState();
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
    _scheduleSaveQueueState();

    final remaining = newQueue.length - (newIndex + 1);
    if (remaining < 4) {
      unawaited(maybeFillRadio());
    }
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
    _scheduleSaveQueueState();
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
    _scheduleSaveQueueState();
  }

  void setNpOpen({required bool value}) =>
      state = state.copyWith(npOpen: value);
  void setQueueOpen({required bool value}) =>
      state = state.copyWith(queueOpen: value);
  void setAutoplay({required bool value}) {
    state = state.copyWith(autoplay: value);
    unawaited(_savePrefBool('player_autoplay', value));
  }

  /// Circuit breaker advancing to next track when resolution or playback fails.
  void failAdvance() {
    if (!ref.mounted) return;
    final ni = state.index + 1;
    autoFailStreak++;
    if (autoFailStreak >= 3 || ni >= state.queue.length) {
      autoFailStreak = 0;
      unawaited(_audioHandler.pausePlayer());
      state = state.copyWith(buffering: false, isPlaying: false);
      notify('core.noConnection');
      return;
    }
    unawaited(loadAt(ni));
  }

  Future<List<Track>> _genreMix(String vid, Track seed) async {
    List<Track> more;
    try {
      more = await _innertubeClient.upNext(vid);
    } on Object catch (_) {
      more = const [];
    }

    if (more.length < 8 &&
        seed.artist.name.isNotEmpty &&
        seed.artist.name != 'Unknown artist') {
      try {
        final searchRes = await _innertubeClient.search(seed.artist.name);
        final seen = more.map((t) => t.streamId ?? t.id).toSet();
        final extra = searchRes.songs
            .where((t) => !seen.contains(t.streamId ?? t.id))
            .toList();
        more = [...more, ...extra];
        if (more.length > 40) more = more.sublist(0, 40);
      } on Object catch (_) {}
    }

    final seedTitle = normTitle(seed.title);
    final titles = <String>{};
    return more.where((t) {
      final n = normTitle(t.title);
      final streamId = t.streamId ?? (t.id.startsWith('yt-') ? t.id : null);
      if (streamId == null || n == seedTitle || titles.contains(n)) {
        return false;
      }
      titles.add(n);
      return true;
    }).toList();
  }

  List<Track> _pickRadioSeeds() {
    if (_radioTried.length > 120) _radioTried.clear();
    final current = state.current;
    final cands = state.queue.where((t) {
      final vid = t.streamId ?? (t.id.startsWith('yt-') ? t.id : null);
      return t.id != current?.id &&
          t.source == TrackSource.yt &&
          vid != null &&
          !_radioTried.contains(vid);
    }).toList();
    final tail = cands.length > 10 ? cands.sublist(cands.length - 10) : cands;
    final pool = tail.length >= 3 ? tail : cands;
    if (pool.isEmpty) return const [];
    final shuffled = [...pool]..shuffle();
    return shuffled.take(4).toList();
  }

  /// Refills upcoming queue with similar tracks when remaining items < 4 and
  /// autoplay is enabled.
  Future<void> maybeFillRadio() async {
    if (!state.autoplay) return;
    final current = state.current;
    if (current == null || current.source != TrackSource.yt) return;
    final vid =
        current.streamId ?? (current.id.startsWith('yt-') ? current.id : null);
    if (vid == null) return;

    final remaining = state.queue.length - (state.index + 1);
    if (remaining >= 4) return;

    final tail = state.queue
        .skip(max(0, state.index))
        .take(4)
        .map((t) => t.id)
        .join(',');

    if (_radioFilledFor?.id == current.id && _radioFilledFor?.tail == tail) {
      return;
    }
    _radioFilledFor = (id: current.id, tail: tail);

    try {
      var more = await _genreMix(vid, current);
      _radioTried.add(vid);

      if (!ref.mounted || state.current?.id != current.id) return;

      List<Track> dedupe(List<Track> candidates) {
        final haveIds = <String>{};
        final haveTitles = <String>{};
        for (final t in state.queue) {
          if (t.streamId != null) haveIds.add(t.streamId!);
          haveIds.add(t.id);
          haveTitles.add(normTitle(t.title));
        }
        final out = <Track>[];
        for (final t in candidates) {
          final tid = t.streamId ?? t.id;
          final n = normTitle(t.title);
          if ((t.streamId != null || t.id.isNotEmpty) &&
              !haveIds.contains(tid) &&
              !haveTitles.contains(n)) {
            haveIds.add(tid);
            haveTitles.add(n);
            out.add(t);
          }
        }
        return out;
      }

      var add = dedupe(more);

      if (add.isEmpty) {
        final seeds = _pickRadioSeeds();
        for (final seed in seeds) {
          final seedVid = seed.streamId ?? seed.id;
          more = await _genreMix(seedVid, seed);
          _radioTried.add(seedVid);
          add = dedupe(more);
          if (add.isNotEmpty) break;
        }
      }

      if (add.isEmpty) {
        try {
          final picks = await _deezerClient.radio(
            current.artist.name,
            current.title,
            limit: 10,
            innertubeClient: _innertubeClient,
          );
          if (picks.isNotEmpty) {
            add = dedupe(picks);
          }
        } on Object catch (e) {
          Log.w('Deezer fallback in radio failed: $e');
        }
      }

      if (add.isEmpty) {
        _radioFilledFor = null;
        return;
      }

      if (!ref.mounted || state.current?.id != current.id) return;

      final oldLength = state.queue.length;
      final newQueue = [...state.queue, ...add];

      var deck = List<int>.from(state.shuffleDeck);
      if (state.shuffle) {
        final newIndices = [for (var i = oldLength; i < newQueue.length; i++) i]
          ..shuffle();
        deck = [...deck, ...newIndices];
      }

      state = state.copyWith(queue: newQueue, shuffleDeck: deck);
      _audioHandler.updateCurrentQueue(
        newQueue.map((t) => t.toMediaItem()).toList(),
      );
      _scheduleSaveQueueState();
    } on Object catch (_) {
      _radioFilledFor = null;
    }
  }

  /// Truncates upcoming queue and populates it with a fresh radio mix seeded by
  /// [track] (or the current track if omitted).
  Future<void> startRadio([Track? track]) async {
    var seed = track;
    if (seed != null &&
        (state.current == null || seed.id != state.current!.id)) {
      playTrack(seed);
    }
    seed ??= state.current;
    if (seed == null) return;
    final vid = seed.streamId ?? (seed.id.startsWith('yt-') ? seed.id : null);

    try {
      var mix = <Track>[];
      if (vid != null && seed.source == TrackSource.yt) {
        mix = await _genreMix(vid, seed);
      }
      if (mix.isEmpty) {
        try {
          mix = await _deezerClient.radio(
            seed.artist.name,
            seed.title,
            limit: 10,
            innertubeClient: _innertubeClient,
          );
        } on Object catch (_) {}
      }

      if (!ref.mounted) return;
      if (state.current?.id != seed.id) return;

      if (mix.isEmpty) {
        notify('table.radioFail');
        return;
      }

      final head = state.queue.sublist(0, state.index + 1);
      final newQueue = [...head, ...mix];
      _radioFilledFor = (
        id: seed.id,
        tail: mix.take(4).map((t) => t.id).join(','),
      );
      _radioTried.clear();
      if (vid != null) {
        _radioTried.add(vid);
      }

      final deck = state.shuffle
          ? shuffledIndices(newQueue.length, state.index)
          : <int>[];

      state = state.copyWith(queue: newQueue, shuffleDeck: deck);
      _audioHandler.updateCurrentQueue(
        newQueue.map((t) => t.toMediaItem()).toList(),
      );
      _scheduleSaveQueueState();
      notify('core.radioStarted');
    } on Object catch (_) {
      notify('table.radioFail');
    }
  }

  void _checkPrefetchAt50Percent(Duration pos) {
    final cur = state.current;
    if (cur == null || _prefetchedForTrackId == cur.id) return;

    final dur = state.duration > Duration.zero
        ? state.duration
        : Duration(seconds: cur.duration);
    if (dur <= Duration.zero) return;

    if (pos >= dur * 0.5) {
      _prefetchedForTrackId = cur.id;
      final nextIdx = state.shuffle && state.shuffleDeck.isNotEmpty
          ? state.shuffleDeck.first
          : state.index + 1;
      if (nextIdx >= 0 && nextIdx < state.queue.length) {
        final nextTrack = state.queue[nextIdx];
        final vid =
            nextTrack.streamId ??
            (nextTrack.id.startsWith('yt-') ? nextTrack.id : null);
        if (nextTrack.source == TrackSource.yt && vid != null) {
          _streamResolver.prefetch(vid);
        }
      }
    }
  }

  /// Loads and plays track at [index] using resolver, downloaded file, or
  /// Audius fallback.
  Future<void> loadAt(
    int index, {
    Duration? startPos,
    bool crossfade = false,
  }) async {
    if (index < 0 || index >= state.queue.length) return;
    final track = state.queue[index];

    final seq = ++loadSeq;
    streamRetries = 0;
    _prefetchedForTrackId = null;
    _autoCrossfadedForTrackId = null;

    state = state.copyWith(
      index: index,
      buffering: true,
      isPlaying: true,
      currentTime: startPos ?? Duration.zero,
      duration: Duration(seconds: track.duration),
    );
    _scheduleSaveQueueState();

    _audioHandler
      ..setCurrentQueueIndex(index)
      ..updateCurrentMediaItem(track.toMediaItem());

    // 1. Check local download first
    AudioSource? source;
    try {
      final dl = await _db.downloadsDao.getDownload(track.id);
      if (dl != null && File(dl.filePath).existsSync()) {
        source = AudioSource.file(dl.filePath);
      }
    } on Object catch (e, st) {
      Log.w('Failed checking downloads for ${track.id}: $e', e, st);
    }

    if (!ref.mounted || seq != loadSeq) return;

    // 2. Resolve stream URL if not downloaded
    double? loudnessDb;
    if (source == null) {
      if (track.source == TrackSource.yt) {
        final videoId = track.streamId ?? track.id;
        try {
          final info = await _streamResolver.resolve(videoId);
          final isVisionOs = info.url.queryParameters['c'] == 'VISIONOS';
          source = AudioSource.uri(
            info.url,
            headers: isVisionOs
                ? const {'User-Agent': visionOsUserAgent}
                : null,
          );
          loudnessDb = info.loudnessDb;
        } on Object catch (e, st) {
          Log.w('Stream resolve failed for $videoId: $e', e, st);
          if (streamRetries == 0) {
            streamRetries = 1;
            _streamResolver.invalidate(videoId);
            try {
              final freshInfo = await _streamResolver.resolve(
                videoId,
                forceFresh: true,
              );
              final isVisionOs =
                  freshInfo.url.queryParameters['c'] == 'VISIONOS';
              source = AudioSource.uri(
                freshInfo.url,
                headers: isVisionOs
                    ? const {'User-Agent': visionOsUserAgent}
                    : null,
              );
              loudnessDb = freshInfo.loudnessDb;
            } on Object catch (e2, st2) {
              Log.w('Stream retry failed for $videoId: $e2', e2, st2);
            }
          }

          if (source == null && ref.mounted && seq == loadSeq) {
            // Audius fallback
            try {
              final audiusResults = await _audiusClient.searchTracks(
                '${track.title} ${track.artist.name}',
              );
              if (audiusResults.isNotEmpty) {
                final matched = audiusResults.first;
                final audiusUrl = _audiusClient.streamUrl(matched.id);
                source = AudioSource.uri(Uri.parse(audiusUrl));
              }
            } on Object catch (ae, ast) {
              Log.w('Audius fallback search failed: $ae', ae, ast);
            }
          }
        }
      } else {
        // Audius track
        final trackId = track.streamId ?? track.id;
        final audiusUrl = _audiusClient.streamUrl(trackId);
        source = AudioSource.uri(Uri.parse(audiusUrl));
      }
    }

    if (!ref.mounted || seq != loadSeq) return;

    if (source == null) {
      state = state.copyWith(buffering: false);
      notify('core.unavailable');
      failAdvance();
      return;
    }

    try {
      final shouldFade =
          crossfade &&
          state.fadeSecs > 0 &&
          state.isPlaying &&
          _audioHandler.playbackState.value.playing;
      final halfFade = shouldFade
          ? Duration(milliseconds: state.fadeSecs * 500)
          : Duration.zero;

      if (shouldFade) {
        await rampVolume(from: state.volume, to: 0, duration: halfFade);
        if (!ref.mounted || seq != loadSeq) return;
      } else {
        unawaited(_audioHandler.setVolume(state.muted ? 0.0 : state.volume));
      }

      await _audioHandler.setAudioSource(source, initialPosition: startPos);
      if (!ref.mounted || seq != loadSeq) return;

      _currentLoudnessDb = loudnessDb;
      if (defaultTargetPlatform == TargetPlatform.android &&
          _audioHandler.loudnessEnhancer != null) {
        try {
          final gainDb = computeLoudnessGainDb(
            loudnessDb,
            normOn: state.normOn,
          );
          await _audioHandler.loudnessEnhancer!.setEnabled(gainDb != 0);
          await _audioHandler.loudnessEnhancer!.setTargetGain(gainDb);
        } on Object catch (_) {}
      }

      await _audioHandler.playPlayer();
      if (!ref.mounted || seq != loadSeq) return;

      if (shouldFade) {
        unawaited(rampVolume(from: 0, to: state.volume, duration: halfFade));
      }

      autoFailStreak = 0;
      state = state.copyWith(buffering: false, isPlaying: true);
      unawaited(maybeFillRadio());
    } on Object catch (e, st) {
      Log.e('Playback error for ${track.id}: $e', e, st);
      if (!ref.mounted || seq != loadSeq) return;
      failAdvance();
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
