import 'dart:io';

import 'package:awady_music/data/db/app_database.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/stream_info.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/sources/audius/audius_client.dart';
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
  bool isPlayingState = false;

  @override
  Future<Duration?> setAudioSource(
    AudioSource source, {
    Duration? initialPosition,
    bool preload = true,
  }) async {
    lastSource = source;
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
  int resolveCalls = 0;
  int forceFreshCalls = 0;
  final List<String> invalidated = [];
  int failCount = 0;

  @override
  Future<StreamInfo> resolve(String videoId, {bool forceFresh = false}) async {
    resolveCalls++;
    if (forceFresh) forceFreshCalls++;

    if (failCount > 0) {
      failCount--;
      throw Exception('Simulated stream resolution error');
    }

    return StreamInfo(
      url: Uri.parse('https://googlevideo.com/playback/$videoId'),
      expiresAt: DateTime.now().add(const Duration(hours: 4)),
      mimeType: 'audio/mp4',
      bitrate: 128000,
    );
  }

  @override
  void invalidate(String videoId) {
    invalidated.add(videoId);
  }

  @override
  void prefetch(String videoId) {}
}

class FakeAudiusClient implements AudiusClient {
  int searchCalls = 0;
  bool shouldReturnMatch = true;

  @override
  Future<List<Track>> searchTracks(
    String query, {
    int limit = 40,
    int? offset,
  }) async {
    searchCalls++;
    if (!shouldReturnMatch) return [];
    return [
      const Track(
        id: 'audius-fallback-1',
        title: 'Audius Match',
        artist: Artist(id: 'a-1', name: 'Audius Artist'),
      ),
    ];
  }

  @override
  String streamUrl(String trackId) => 'https://audius.co/stream/$trackId';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Track makeTestTrack(String id, {String source = 'yt'}) {
  return Track(
    id: id,
    title: 'Track $id',
    artist: Artist(id: 'art-$id', name: 'Artist $id'),
    source: source == 'yt' ? TrackSource.yt : TrackSource.audius,
    streamId: id,
    duration: 200,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAudioHandler audioHandler;
  late FakeStreamResolver fakeResolver;
  late FakeAudiusClient fakeAudius;
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    audioHandler = FakeAudioHandler();
    fakeResolver = FakeStreamResolver();
    fakeAudius = FakeAudiusClient();
    db = AppDatabase(NativeDatabase.memory());

    container = ProviderContainer(
      overrides: [
        audioHandlerProvider.overrideWithValue(audioHandler),
        streamResolverProvider.overrideWithValue(fakeResolver),
        audiusClientProvider.overrideWithValue(fakeAudius),
        appDatabaseProvider.overrideWithValue(db),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await audioHandler.dispose();
    await db.close();
  });

  group('T-30 Load pipeline & fallback tests', () {
    test(
      'successful resolve sets playing and resets circuit breaker',
      () async {
        final controller = container.read(playerControllerProvider.notifier);
        final track = makeTestTrack('yt-1');

        controller.playTrack(track);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final state = container.read(playerControllerProvider);
        expect(state.index, 0);
        expect(state.isPlaying, true);
        expect(state.buffering, false);
        expect(fakeResolver.resolveCalls, 1);
        expect(controller.autoFailStreak, 0);
        expect(audioHandler.lastSource, isA<UriAudioSource>());
      },
    );

    test('downloaded file takes priority and skips StreamResolver', () async {
      final tempFile = File('${Directory.systemTemp.path}/test_song.m4a');
      await tempFile.writeAsString('audio-bytes');
      addTearDown(() async {
        if (tempFile.existsSync()) await tempFile.delete();
      });

      await db.downloadsDao.insertDownload(
        'dl-1',
        tempFile.path,
        DateTime.now(),
      );

      final controller = container.read(playerControllerProvider.notifier);
      final track = makeTestTrack('dl-1');

      controller.playTrack(track);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(container.read(playerControllerProvider).isPlaying, true);
      // Resolver was bypassed, file audio source used
      expect(fakeResolver.resolveCalls, 0);
      expect(audioHandler.lastSource, isA<ProgressiveAudioSource>());
    });

    test(
      'retry-once invalidates cache and resolves fresh on first failure',
      () async {
        fakeResolver.failCount = 1; // Fails once, succeeds on retry

        final controller = container.read(playerControllerProvider.notifier);
        final track = makeTestTrack('retry-1');

        controller.playTrack(track);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(container.read(playerControllerProvider).isPlaying, true);
        expect(fakeResolver.resolveCalls, 2);
        expect(fakeResolver.forceFreshCalls, 1);
        expect(fakeResolver.invalidated, contains('retry-1'));
      },
    );

    test(
      'Audius fallback used when StreamResolver permanently fails',
      () async {
        fakeResolver.failCount = 99; // Permanently fails
        fakeAudius.shouldReturnMatch = true;

        final controller = container.read(playerControllerProvider.notifier);
        final track = makeTestTrack('yt-fail-1');

        controller.playTrack(track);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(container.read(playerControllerProvider).isPlaying, true);
        expect(fakeResolver.resolveCalls, 2); // Initial + 1 retry
        expect(fakeAudius.searchCalls, 1);
      },
    );

    test('loadSeq staleness drops earlier in-flight resolution', () async {
      final controller = container.read(playerControllerProvider.notifier);
      final tracks = [makeTestTrack('s1'), makeTestTrack('s2')];

      controller
        ..playContext(tracks, 0)
        // Immediately switch to track 1 before track 0 completes
        ..jumpTo(1);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      final state = container.read(playerControllerProvider);
      expect(state.index, 1);
      expect(state.current?.id, 's2');
    });

    test(
      'circuit breaker stops playback after 3 consecutive failures',
      () async {
        fakeResolver.failCount = 999;
        fakeAudius.shouldReturnMatch = false; // Audius fails too

        final controller = container.read(playerControllerProvider.notifier);
        final tracks = [
          makeTestTrack('fail-1'),
          makeTestTrack('fail-2'),
          makeTestTrack('fail-3'),
          makeTestTrack('fail-4'),
        ];

        controller.playContext(tracks, 0);
        await Future<void>.delayed(const Duration(milliseconds: 150));

        final state = container.read(playerControllerProvider);
        // Circuit breaker stopped playback after 3 failures
        expect(state.isPlaying, false);
        expect(state.buffering, false);
        expect(state.notice, 'core.noConnection');
      },
    );
  });
}
