import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/data/db/app_database.dart';
import 'package:awady_music/data/sources/audius/audius_client.dart';
import 'package:awady_music/data/sources/deezer/deezer_client.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:awady_music/data/sources/ytstream/stream_resolver_impl.dart';
import 'package:awady_music/data/sources/ytstream/stream_resolver_provider.dart';
import 'package:awady_music/player/audio_handler.dart';
import 'package:awady_music/player/eq.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAudioHandler extends AwadyAudioHandler {
  final List<double> volumeHistory = [];

  @override
  Future<void> setVolume(double volume) async {
    volumeHistory.add(volume);
  }

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

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

class MockStreamResolver extends Mock implements StreamResolver;

class MockAudiusClient extends Mock implements AudiusClient;

class MockInnertubeClient extends Mock implements InnertubeClient;

class MockDeezerClient extends Mock implements DeezerClient;

class MockAppDatabase extends Mock implements AppDatabase;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('T-35 Equalizer constants & pure functions', () {
    test('contains 7 desktop band frequencies and matching labels', () {
      expect(desktopEqFrequencies.length, 7);
      expect(desktopBandLabels.length, 7);
      expect(desktopEqFrequencies, [60, 250, 500, 1000, 4000, 8000, 14000]);
      expect(desktopBandLabels, ['60', '250', '500', '1K', '4K', '8K', '14K']);
    });

    test('defines required presets ported from EqPopover.tsx', () {
      expect(eqPresets.containsKey('flat'), isTrue);
      expect(eqPresets.containsKey('bass'), isTrue);
      expect(eqPresets.containsKey('vocal'), isTrue);
      expect(eqPresets.containsKey('bright'), isTrue);
      expect(eqPresets.containsKey('vshape'), isTrue);

      expect(eqPresets['flat'], [0, 0, 0, 0, 0, 0, 0]);
      expect(eqPresets['bass'], [6, 4, 1, 0, 0, 1, 2]);
      expect(eqPresets['vocal'], [-2, 0, 3, 5, 4, 2, 0]);
      expect(eqPresets['bright'], [-1, 0, 1, 2, 4, 6, 7]);
      expect(eqPresets['vshape'], [6, 3, 0, -1, 0, 3, 6]);
    });

    test('detectEqPreset identifies matching presets and null for custom', () {
      expect(detectEqPreset([0, 0, 0, 0, 0, 0, 0]), 'flat');
      expect(detectEqPreset([6, 4, 1, 0, 0, 1, 2]), 'bass');
      expect(detectEqPreset([1, 2, 3, 4, 5, 6, 7]), isNull);
      expect(detectEqPreset([]), isNull);
    });

    test(
      'mapDeviceBandToDesktopIndex finds nearest center frequency index',
      () {
        expect(mapDeviceBandToDesktopIndex(55), 0);
        expect(mapDeviceBandToDesktopIndex(220), 1);
        expect(mapDeviceBandToDesktopIndex(600), 2);
        expect(mapDeviceBandToDesktopIndex(950), 3);
        expect(mapDeviceBandToDesktopIndex(3500), 4);
        expect(mapDeviceBandToDesktopIndex(7500), 5);
        expect(mapDeviceBandToDesktopIndex(15000), 6);
      },
    );
  });

  group('T-35 EqualizerController platform guard', () {
    test('isSupported is false on iOS or desktop platforms', () async {
      final iosController = EqualizerController(
        platformOverride: TargetPlatform.iOS,
      );
      expect(iosController.isSupported, isFalse);

      await expectLater(
        iosController.applyGains([2, 4, 0, 0, 0, 0, 0]),
        completes,
      );

      final windowsController = EqualizerController(
        platformOverride: TargetPlatform.windows,
      );
      expect(windowsController.isSupported, isFalse);
    });

    test('isSupported is false on Android if AndroidEqualizer is null', () {
      final androidController = EqualizerController(
        platformOverride: TargetPlatform.android,
      );
      expect(androidController.isSupported, isFalse);
    });
  });

  group('T-35 PlayerController EQ integration', () {
    late SharedPreferences prefs;
    late FakeAudioHandler audioHandler;
    late MockStreamResolver streamResolver;
    late MockAudiusClient audiusClient;
    late MockInnertubeClient innertubeClient;
    late MockDeezerClient deezerClient;
    late MockAppDatabase appDb;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      audioHandler = FakeAudioHandler();
      streamResolver = MockStreamResolver();
      audiusClient = MockAudiusClient();
      innertubeClient = MockInnertubeClient();
      deezerClient = MockDeezerClient();
      appDb = MockAppDatabase();

      when(() => appDb.getQueueState()).thenAnswer((_) async => null);
    });

    test('setEqBand clamps within [-12, +12] and updates state.eq', () {
      final container = ProviderContainer(
        overrides: [
          audioHandlerProvider.overrideWithValue(audioHandler),
          streamResolverProvider.overrideWithValue(streamResolver),
          audiusClientProvider.overrideWithValue(audiusClient),
          innertubeClientProvider.overrideWithValue(innertubeClient),
          deezerClientProvider.overrideWithValue(deezerClient),
          appDatabaseProvider.overrideWithValue(appDb),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final controller = container.read(playerControllerProvider.notifier);
      expect(container.read(playerControllerProvider).eq, [
        0,
        0,
        0,
        0,
        0,
        0,
        0,
      ]);

      // Boost band 0 beyond +12
      controller.setEqBand(0, 15);
      expect(container.read(playerControllerProvider).eq[0], 12);

      // Cut band 1 beyond -12
      controller.setEqBand(1, -20);
      expect(container.read(playerControllerProvider).eq[1], -12);

      // Set valid gain
      controller.setEqBand(4, 3.5);
      expect(container.read(playerControllerProvider).eq[4], 3.5);

      // Out of bounds index ignored
      controller.setEqBand(10, 5);
      expect(container.read(playerControllerProvider).eq.length, 7);
    });

    test('setEqPreset updates eq gains to matched preset', () {
      final container = ProviderContainer(
        overrides: [
          audioHandlerProvider.overrideWithValue(audioHandler),
          streamResolverProvider.overrideWithValue(streamResolver),
          audiusClientProvider.overrideWithValue(audiusClient),
          innertubeClientProvider.overrideWithValue(innertubeClient),
          deezerClientProvider.overrideWithValue(deezerClient),
          appDatabaseProvider.overrideWithValue(appDb),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final controller = container.read(playerControllerProvider.notifier)
        ..setEqPreset('bass');
      expect(container.read(playerControllerProvider).eq, eqPresets['bass']);

      controller.setEqPreset('vshape');
      expect(container.read(playerControllerProvider).eq, eqPresets['vshape']);
    });
  });
}
