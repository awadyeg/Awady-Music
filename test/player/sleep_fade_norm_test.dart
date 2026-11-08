import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/data/db/app_database.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/stream_info.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/sources/audius/audius_client.dart';
import 'package:awady_music/data/sources/deezer/deezer_client.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:awady_music/data/sources/ytstream/stream_resolver_impl.dart';
import 'package:awady_music/data/sources/ytstream/stream_resolver_provider.dart';
import 'package:awady_music/player/audio_handler.dart';
import 'package:awady_music/player/loudness.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:drift/native.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;
import 'package:shared_preferences/shared_preferences.dart';

class FakeAudioHandler extends AwadyAudioHandler {
  final List<double> volumeHistory = [];
  bool isPlayingState = false;

  @override
  Future<Duration?> setAudioSource(
    AudioSource source, {
    Duration? initialPosition,
    bool preload = true,
  }) async {
    return const Duration(seconds: 200);
  }

  @override
  Future<void> setVolume(double volume) async {
    volumeHistory.add(volume);
  }

  @override
  Future<void> playPlayer() async {
    isPlayingState = true;
  }

  @override
  Future<void> pausePlayer() async {
    isPlayingState = false;
  }

  @override
  Future<void> stop() async {
    isPlayingState = false;
  }

  @override
  Future<void> dispose() async {}
}

class FakeStreamResolver implements StreamResolver {
  @override
  Future<StreamInfo> resolve(String videoId, {bool forceFresh = false}) async {
    return StreamInfo(
      url: Uri.parse('https://googlevideo.com/$videoId'),
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  void invalidate(String videoId) {}

  @override
  void prefetch(String videoId) {}
}

class FakeAudiusClient implements AudiusClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeInnertubeClient implements InnertubeClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeDeezerClient implements DeezerClient {
  @override
  Future<List<Track>> radio(
    String artist,
    String title, {
    int limit = 12,
    InnertubeClient? innertubeClient,
  }) async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Track makeTestTrack(String id) {
  return Track(
    id: id,
    title: 'Track $id',
    artist: Artist(id: 'art-$id', name: 'Artist $id'),
    source: TrackSource.yt,
    streamId: id,
    duration: 200,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('T-34 Loudness Normalisation calculations', () {
    test('computeLoudnessGainDb clamps within [-6.0, +6.0] dB', () {
      expect(computeLoudnessGainDb(null), 0);
      expect(computeLoudnessGainDb(3, normOn: false), 0);

      // -loudnessDb clamped to [-6, +6]
      expect(computeLoudnessGainDb(0), 0);
      expect(computeLoudnessGainDb(-4.5), 4.5);
      expect(computeLoudnessGainDb(-10), 6); // clamped to +6 dB
      expect(computeLoudnessGainDb(3.2), -3.2);
      expect(computeLoudnessGainDb(8), -6); // clamped to -6 dB
    });

    test('computeLoudnessMultiplier converts dB gain to linear multiplier', () {
      expect(computeLoudnessMultiplier(0), closeTo(1, 0.001));
      expect(computeLoudnessMultiplier(null), 1);
      expect(computeLoudnessMultiplier(6), closeTo(0.501, 0.01)); // -6 dB
      expect(computeLoudnessMultiplier(-6), closeTo(1.995, 0.01)); // +6 dB
    });
  });

  group('T-34 Sleep timer tests with fake clock', () {
    late FakeAudioHandler audioHandler;
    late AppDatabase db;
    late SharedPreferences prefs;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      audioHandler = FakeAudioHandler();
      db = AppDatabase(NativeDatabase.memory());

      container = ProviderContainer(
        overrides: [
          audioHandlerProvider.overrideWithValue(audioHandler),
          streamResolverProvider.overrideWithValue(FakeStreamResolver()),
          audiusClientProvider.overrideWithValue(FakeAudiusClient()),
          innertubeClientProvider.overrideWithValue(FakeInnertubeClient()),
          deezerClientProvider.overrideWithValue(FakeDeezerClient()),
          appDatabaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('setSleepTimer sets sleepAt and pauses playback when elapsed', () {
      fakeAsync((async) {
        final controller = container.read(playerControllerProvider.notifier);
        final track = makeTestTrack('yt-sleep');
        controller.playTrack(track);
        async.elapse(const Duration(milliseconds: 10));

        expect(container.read(playerControllerProvider).isPlaying, isTrue);

        // Set sleep timer for 10 minutes
        controller.setSleepTimer(10);
        final state = container.read(playerControllerProvider);
        expect(state.sleepAt, isNotNull);

        // Advance 5 minutes - still playing
        async.elapse(const Duration(minutes: 5));
        expect(container.read(playerControllerProvider).isPlaying, isTrue);

        // Advance remaining 5 minutes - timer fires
        async.elapse(const Duration(minutes: 5));

        final stoppedState = container.read(playerControllerProvider);
        expect(stoppedState.isPlaying, isFalse);
        expect(stoppedState.sleepAt, isNull);
      });
    });

    test('setSleepTimer(null) cancels pending timer', () {
      fakeAsync((async) {
        final controller = container.read(playerControllerProvider.notifier);
        final track = makeTestTrack('yt-sleep');
        controller.playTrack(track);
        async.elapse(const Duration(milliseconds: 10));

        controller.setSleepTimer(10);
        expect(container.read(playerControllerProvider).sleepAt, isNotNull);

        controller.setSleepTimer(null);
        expect(container.read(playerControllerProvider).sleepAt, isNull);

        // Advance past the original deadline. Playback must keep going.
        async.elapse(const Duration(minutes: 15));
        expect(container.read(playerControllerProvider).isPlaying, isTrue);
      });
    });

    test('sleep deadline survives a new player controller', () async {
      container.read(playerControllerProvider.notifier).setSleepTimer(30);
      expect(container.read(playerControllerProvider).sleepAt, isNotNull);
      int? stored;
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        stored = prefs.getInt('player_sleep_at_ms');
        if (stored != null) break;
      }
      expect(stored, isNotNull);

      final restored = ProviderContainer(
        overrides: [
          audioHandlerProvider.overrideWithValue(audioHandler),
          streamResolverProvider.overrideWithValue(FakeStreamResolver()),
          audiusClientProvider.overrideWithValue(FakeAudiusClient()),
          innertubeClientProvider.overrideWithValue(FakeInnertubeClient()),
          deezerClientProvider.overrideWithValue(FakeDeezerClient()),
          appDatabaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(restored.dispose);

      DateTime? sleepAt;
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        sleepAt = restored.read(playerControllerProvider).sleepAt;
        if (sleepAt != null) break;
      }
      expect(sleepAt, isNotNull);
      expect(sleepAt!.millisecondsSinceEpoch, stored);
    });
  });

  group('T-34 Fade and volume ramping tests', () {
    late FakeAudioHandler audioHandler;
    late AppDatabase db;
    late SharedPreferences prefs;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      audioHandler = FakeAudioHandler();
      db = AppDatabase(NativeDatabase.memory());

      container = ProviderContainer(
        overrides: [
          audioHandlerProvider.overrideWithValue(audioHandler),
          streamResolverProvider.overrideWithValue(FakeStreamResolver()),
          audiusClientProvider.overrideWithValue(FakeAudiusClient()),
          innertubeClientProvider.overrideWithValue(FakeInnertubeClient()),
          deezerClientProvider.overrideWithValue(FakeDeezerClient()),
          appDatabaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('setFadeSecs and setNormOn persist to prefs', () {
      final controller = container.read(playerControllerProvider.notifier)
        ..setFadeSecs(6);
      expect(container.read(playerControllerProvider).fadeSecs, 6);
      expect(prefs.getInt('player_fade_secs'), 6);

      controller.setNormOn(value: false);
      expect(container.read(playerControllerProvider).normOn, isFalse);
      expect(prefs.getBool('player_norm_on'), isFalse);
    });

    test('rampVolume steps smoothly from 1.0 down to 0.0', () async {
      final controller = container.read(playerControllerProvider.notifier);

      audioHandler.volumeHistory.clear();
      await controller.rampVolume(
        from: 1,
        to: 0,
        duration: const Duration(milliseconds: 50),
      );

      expect(audioHandler.volumeHistory.length, 5);
      expect(audioHandler.volumeHistory.first, closeTo(0.8, 0.01));
      expect(audioHandler.volumeHistory.last, closeTo(0, 0.01));
    });
  });
}
