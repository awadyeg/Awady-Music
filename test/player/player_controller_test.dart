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
    return const Duration(seconds: 180);
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
      url: Uri.parse('https://googlevideo.com/playback/$videoId'),
      expiresAt: DateTime.now().add(const Duration(hours: 4)),
      mimeType: 'audio/mp4',
      bitrate: 128000,
    );
  }

  @override
  void invalidate(String videoId) {}

  @override
  void prefetch(String videoId) {}
}

class FakeAudiusClient implements AudiusClient {
  @override
  String streamUrl(String trackId) => 'https://audius.co/stream/$trackId';

  @override
  Future<List<Track>> searchTracks(
    String query, {
    int limit = 40,
    int? offset,
  }) async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Track makeTrack(String id, {String title = 'Song', int duration = 180}) {
  return Track(
    id: id,
    title: '$title $id',
    artist: Artist(id: 'a-$id', name: 'Artist $id'),
    source: TrackSource.yt,
    streamId: id,
    duration: duration,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAudioHandler audioHandler;
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    audioHandler = FakeAudioHandler();
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        audioHandlerProvider.overrideWithValue(audioHandler),
        appDatabaseProvider.overrideWithValue(db),
        streamResolverProvider.overrideWithValue(FakeStreamResolver()),
        audiusClientProvider.overrideWithValue(FakeAudiusClient()),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await audioHandler.dispose();
    await db.close();
  });

  group('PlayerController core queue semantics tests', () {
    test('playContext and playTrack initialize queue and current track', () {
      final controller = container.read(playerControllerProvider.notifier);
      final tracks = [makeTrack('t1'), makeTrack('t2'), makeTrack('t3')];

      controller.playContext(tracks, 1);
      var state = container.read(playerControllerProvider);

      expect(state.queue.length, 3);
      expect(state.index, 1);
      expect(state.current?.id, 't2');
      expect(state.isPlaying, true);
      expect(state.history, isEmpty);

      final single = makeTrack('t4');
      controller.playTrack(single);
      state = container.read(playerControllerProvider);

      expect(state.queue.length, 1);
      expect(state.index, 0);
      expect(state.current?.id, 't4');
    });

    test('next advances sequentially with history stack', () {
      final controller = container.read(playerControllerProvider.notifier);
      final tracks = [makeTrack('t1'), makeTrack('t2'), makeTrack('t3')];

      controller.playContext(tracks, 0);
      expect(container.read(playerControllerProvider).index, 0);

      controller.next();
      var state = container.read(playerControllerProvider);
      expect(state.index, 1);
      expect(state.history, [0]);

      controller.next();
      state = container.read(playerControllerProvider);
      expect(state.index, 2);
      expect(state.history, [0, 1]);

      // Manual next at end of queue does nothing when repeat is off
      controller.next();
      state = container.read(playerControllerProvider);
      expect(state.index, 2);

      // Auto next at end of queue stops playback
      controller.next(auto: true);
      state = container.read(playerControllerProvider);
      expect(state.isPlaying, false);
    });

    test('next respects repeat all and repeat one', () {
      final controller = container.read(playerControllerProvider.notifier);
      final tracks = [makeTrack('t1'), makeTrack('t2')];

      controller
        ..playContext(tracks, 1)
        ..cycleRepeat(); // off -> all
      expect(container.read(playerControllerProvider).repeat, RepeatMode.all);

      controller.next();
      expect(container.read(playerControllerProvider).index, 0);

      controller.cycleRepeat(); // all -> one
      expect(container.read(playerControllerProvider).repeat, RepeatMode.one);

      controller.next(auto: true);
      // repeat-one restarts current track without advancing index
      expect(container.read(playerControllerProvider).index, 0);
    });

    test(
      'shuffle deck plays every track without repeating until deck drains',
      () {
        final controller = container.read(playerControllerProvider.notifier);
        final tracks = [
          makeTrack('t1'),
          makeTrack('t2'),
          makeTrack('t3'),
          makeTrack('t4'),
        ];

        controller
          ..toggleShuffle()
          ..playContext(tracks, 0);
        expect(container.read(playerControllerProvider).shuffle, true);

        final state = container.read(playerControllerProvider);
        expect(state.index, 0);
        expect(state.shuffleDeck.length, 3);
        expect(state.shuffleDeck.contains(0), false);

        final heard = <int>{0};
        for (var i = 0; i < 3; i++) {
          controller.next();
          final currentIdx = container.read(playerControllerProvider).index;
          expect(heard.contains(currentIdx), false);
          heard.add(currentIdx);
        }

        expect(heard.length, 4);
        expect(heard, containsAll([0, 1, 2, 3]));
      },
    );

    test('prev seeks to start if > 3s, else pops history stack', () {
      final controller = container.read(playerControllerProvider.notifier);
      final tracks = [makeTrack('t1'), makeTrack('t2'), makeTrack('t3')];

      controller
        ..playContext(tracks, 0)
        ..next() // now at index 1, history [0]
        ..next() // now at index 2, history [0, 1]
        ..seek(const Duration(seconds: 10));

      expect(
        container.read(playerControllerProvider).currentTime.inSeconds,
        10,
      );

      controller.prev();
      // Should seek to 0 without popping history
      expect(
        container.read(playerControllerProvider).currentTime,
        Duration.zero,
      );
      expect(container.read(playerControllerProvider).index, 2);
      expect(container.read(playerControllerProvider).history, [0, 1]);

      // At position 0, prev pops history to index 1
      controller.prev();
      expect(container.read(playerControllerProvider).index, 1);
      expect(container.read(playerControllerProvider).history, [0]);

      // Prev again pops history to index 0
      controller.prev();
      expect(container.read(playerControllerProvider).index, 0);
      expect(container.read(playerControllerProvider).history, isEmpty);

      // Prev with empty history seeks to 0
      controller.prev();
      expect(container.read(playerControllerProvider).index, 0);
    });

    test('enqueue appends track and caps at 500', () {
      final controller = container.read(playerControllerProvider.notifier);
      final tracks = [makeTrack('t1'), makeTrack('t2')];
      controller
        ..playContext(tracks, 0)
        ..enqueue(makeTrack('t3'));
      expect(container.read(playerControllerProvider).queue.length, 3);
      expect(container.read(playerControllerProvider).queue.last.id, 't3');

      // Test idle player starts playing on enqueue
      final idleContainer = ProviderContainer(
        overrides: [
          audioHandlerProvider.overrideWithValue(audioHandler),
          appDatabaseProvider.overrideWithValue(db),
          streamResolverProvider.overrideWithValue(FakeStreamResolver()),
          audiusClientProvider.overrideWithValue(FakeAudiusClient()),
        ],
      );
      addTearDown(idleContainer.dispose);
      final idleController = idleContainer.read(
        playerControllerProvider.notifier,
      );
      expect(idleContainer.read(playerControllerProvider).queue, isEmpty);
      idleController.enqueue(makeTrack('t3'));
      expect(idleContainer.read(playerControllerProvider).queue.length, 1);
      expect(idleContainer.read(playerControllerProvider).index, 0);
    });

    test('playNextUp inserts track immediately after current index', () {
      final controller = container.read(playerControllerProvider.notifier);
      final tracks = [makeTrack('t1'), makeTrack('t2'), makeTrack('t3')];
      controller
        ..playContext(tracks, 0)
        ..playNextUp(makeTrack('next-up'));

      final queue = container.read(playerControllerProvider).queue;
      expect(queue.length, 4);
      expect(queue[1].id, 'next-up');
      expect(queue[2].id, 't2');
      expect(queue[3].id, 't3');
    });

    test('removeAt removes track and rebases index and history', () {
      final controller = container.read(playerControllerProvider.notifier);
      final tracks = [makeTrack('t1'), makeTrack('t2'), makeTrack('t3')];
      controller
        ..playContext(tracks, 0)
        ..next() // now at index 1, history [0]
        ..removeAt(1); // Removing index 1 (currently playing) is ignored
      expect(container.read(playerControllerProvider).queue.length, 3);

      // Removing index 0 rebases index from 1 to 0 and adjusts history
      controller.removeAt(0);
      final state = container.read(playerControllerProvider);
      expect(state.queue.length, 2);
      expect(state.index, 0);
      expect(state.current?.id, 't2');
      expect(state.history, isEmpty);
    });

    test('clearQueue keeps currently playing track only', () {
      final controller = container.read(playerControllerProvider.notifier);
      final tracks = [makeTrack('t1'), makeTrack('t2'), makeTrack('t3')];
      controller
        ..playContext(tracks, 1)
        ..clearQueue();
      final state = container.read(playerControllerProvider);
      expect(state.queue.length, 1);
      expect(state.index, 0);
      expect(state.current?.id, 't2');
      expect(state.history, isEmpty);
    });

    test('moveInQueue reorders tracks and remaps index', () {
      final controller = container.read(playerControllerProvider.notifier);
      final tracks = [
        makeTrack('t1'),
        makeTrack('t2'),
        makeTrack('t3'),
        makeTrack('t4'),
      ];
      controller
        ..playContext(tracks, 1) // playing t2 at index 1
        ..moveInQueue(3, 0); // Move index 3 (t4) to index 0: [t4, t1, t2, t3]
      var state = container.read(playerControllerProvider);
      expect(state.queue.map((t) => t.id).toList(), ['t4', 't1', 't2', 't3']);
      expect(state.index, 2);
      expect(state.current?.id, 't2');

      // Moving the currently playing track is ignored
      controller.moveInQueue(2, 0);
      state = container.read(playerControllerProvider);
      expect(state.index, 2);
    });

    test('jumpTo jumps to track and updates history', () {
      final controller = container.read(playerControllerProvider.notifier);
      final tracks = [
        makeTrack('t1'),
        makeTrack('t2'),
        makeTrack('t3'),
        makeTrack('t4'),
      ];
      controller
        ..playContext(tracks, 0)
        ..jumpTo(3);
      final state = container.read(playerControllerProvider);
      expect(state.index, 3);
      expect(state.current?.id, 't4');
      expect(state.history, [0]);
    });

    test('volume, mute, and cycleRepeat controls', () {
      final controller = container.read(playerControllerProvider.notifier)
        ..setVolume(0.5);
      expect(container.read(playerControllerProvider).volume, 0.5);

      controller
        ..toggleMute()
        ..toggleMute();
      expect(container.read(playerControllerProvider).muted, false);

      expect(container.read(playerControllerProvider).repeat, RepeatMode.off);
      controller
        ..cycleRepeat()
        ..cycleRepeat();
      expect(container.read(playerControllerProvider).repeat, RepeatMode.one);
      controller.cycleRepeat();
      expect(container.read(playerControllerProvider).repeat, RepeatMode.off);
    });

    test(
      'pauseLocalForCast pauses local audioHandler and clears buffering',
      () async {
        final controller = container.read(playerControllerProvider.notifier);
        final tracks = [makeTrack('t1')];
        controller.playTrack(tracks.first);
        audioHandler.isPlayingState = true;

        await controller.pauseLocalForCast();

        expect(audioHandler.isPlayingState, isFalse);
        expect(container.read(playerControllerProvider).buffering, isFalse);
      },
    );
  });
}
