import 'dart:convert';

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
import 'package:awady_music/player/player_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;
import 'package:shared_preferences/shared_preferences.dart';

class FakeAudioHandler extends AwadyAudioHandler {
  AudioSource? lastSource;
  Duration? lastInitialPosition;
  bool isPlayingState = false;

  @override
  Future<Duration?> setAudioSource(
    AudioSource source, {
    Duration? initialPosition,
    bool preload = true,
  }) async {
    lastSource = source;
    lastInitialPosition = initialPosition;
    return const Duration(seconds: 200);
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

Track makeTestTrack(String id, {String? title}) {
  return Track(
    id: id,
    title: title ?? 'Track $id',
    artist: Artist(id: 'art-$id', name: 'Artist $id'),
    source: TrackSource.yt,
    streamId: id,
    duration: 200,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAudioHandler audioHandler;
  late FakeStreamResolver fakeResolver;
  late FakeAudiusClient fakeAudius;
  late FakeInnertubeClient fakeInnertube;
  late FakeDeezerClient fakeDeezer;
  late AppDatabase db;
  late SharedPreferences prefs;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    audioHandler = FakeAudioHandler();
    fakeResolver = FakeStreamResolver();
    fakeAudius = FakeAudiusClient();
    fakeInnertube = FakeInnertubeClient();
    fakeDeezer = FakeDeezerClient();
    db = AppDatabase(NativeDatabase.memory());

    container = ProviderContainer(
      overrides: [
        audioHandlerProvider.overrideWithValue(audioHandler),
        streamResolverProvider.overrideWithValue(fakeResolver),
        audiusClientProvider.overrideWithValue(fakeAudius),
        innertubeClientProvider.overrideWithValue(fakeInnertube),
        deezerClientProvider.overrideWithValue(fakeDeezer),
        appDatabaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test(
    'T-33 saves queue, index, position to queue_state immediately',
    () async {
      final controller = container.read(playerControllerProvider.notifier);
      final tracks = [makeTestTrack('t-1'), makeTestTrack('t-2')];
      controller
        ..playContext(tracks, 1)
        ..seek(const Duration(seconds: 45));

      await controller.saveQueueStateNow();

      final rawJson = await db.getQueueState();
      expect(rawJson, isNotNull);
      final decoded = jsonDecode(rawJson!) as Map<String, dynamic>;
      expect(decoded['index'], 1);
      expect(decoded['positionMs'], 45000);
      final queue = (decoded['queue'] as List).cast<Map<String, dynamic>>();
      expect(queue.length, 2);
      expect(queue[0]['id'], 't-1');
      expect(queue[1]['id'], 't-2');
    },
  );

  test(
    'T-33 persists volume, mute, shuffle, repeat, autoplay to prefs',
    () async {
      final controller = container.read(playerControllerProvider.notifier)
        ..setVolume(0.75);
      expect(prefs.getDouble('player_volume'), 0.75);

      controller.toggleMute();
      expect(prefs.getBool('player_muted'), isTrue);

      controller.toggleShuffle();
      expect(prefs.getBool('player_shuffle'), isTrue);

      controller.cycleRepeat(); // off -> all
      expect(prefs.getString('player_repeat'), 'all');

      controller.setAutoplay(value: false);
      expect(prefs.getBool('player_autoplay'), isFalse);
    },
  );

  test('T-33 restores queue, position and prefs on launch paused', () async {
    // Seed database and prefs
    final persistedQueue = [
      makeTestTrack('restored-1'),
      makeTestTrack('restored-2'),
    ];
    final jsonStr = jsonEncode({
      'queue': persistedQueue.map((t) => t.toJson()).toList(),
      'index': 1,
      'positionMs': 30000,
      'current': persistedQueue[1].toJson(),
    });
    await db.saveQueueState(jsonStr);

    await prefs.setDouble('player_volume', 0.65);
    await prefs.setBool('player_muted', false);
    await prefs.setBool('player_shuffle', true);
    await prefs.setString('player_repeat', 'one');
    await prefs.setBool('player_autoplay', false);

    // Create a fresh container to simulate cold app launch
    final freshContainer = ProviderContainer(
      overrides: [
        audioHandlerProvider.overrideWithValue(audioHandler),
        streamResolverProvider.overrideWithValue(fakeResolver),
        audiusClientProvider.overrideWithValue(fakeAudius),
        innertubeClientProvider.overrideWithValue(fakeInnertube),
        deezerClientProvider.overrideWithValue(fakeDeezer),
        appDatabaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );

    final freshController = freshContainer.read(
      playerControllerProvider.notifier,
    );
    await freshController.restorePersistedState();

    final state = freshContainer.read(playerControllerProvider);
    expect(state.queue.length, 2);
    expect(state.index, 1);
    expect(state.current?.id, 'restored-2');
    expect(state.currentTime, const Duration(seconds: 30));
    expect(state.isPlaying, isFalse); // Paused on launch!
    expect(state.buffering, isFalse);
    expect(state.volume, 0.65);
    expect(state.shuffle, isTrue);
    expect(state.repeat, RepeatMode.one);
    expect(state.autoplay, isFalse);

    freshContainer.dispose();
  });

  test(
    'T-33 toggle resumes paused restored session at stored position',
    () async {
      final persistedQueue = [makeTestTrack('t-resume')];
      final jsonStr = jsonEncode({
        'queue': persistedQueue.map((t) => t.toJson()).toList(),
        'index': 0,
        'positionMs': 12000,
        'current': persistedQueue[0].toJson(),
      });
      await db.saveQueueState(jsonStr);

      final launchContainer = ProviderContainer(
        overrides: [
          audioHandlerProvider.overrideWithValue(audioHandler),
          streamResolverProvider.overrideWithValue(fakeResolver),
          audiusClientProvider.overrideWithValue(fakeAudius),
          innertubeClientProvider.overrideWithValue(fakeInnertube),
          deezerClientProvider.overrideWithValue(fakeDeezer),
          appDatabaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final controller = launchContainer.read(
        playerControllerProvider.notifier,
      );
      await controller.restorePersistedState();

      // Now press play/toggle
      await controller.toggle();

      final state = launchContainer.read(playerControllerProvider);
      expect(state.isPlaying, isTrue);
      expect(audioHandler.lastInitialPosition, const Duration(seconds: 12));

      launchContainer.dispose();
    },
  );
}
