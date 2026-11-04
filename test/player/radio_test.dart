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

class FakeAudioHandler extends AwadyAudioHandler {
  @override
  Future<Duration?> setAudioSource(
    AudioSource source, {
    Duration? initialPosition,
    bool preload = true,
  }) async {
    return const Duration(seconds: 200);
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
  int upNextCalls = 0;
  List<Track> upNextResponse = [];

  @override
  Future<List<Track>> upNext(String videoId, {int limit = 40}) async {
    upNextCalls++;
    return upNextResponse;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeDeezerClient implements DeezerClient {
  int radioCalls = 0;
  List<Track> radioResponse = [];

  @override
  Future<List<Track>> radio(
    String artist,
    String title, {
    int limit = 12,
    InnertubeClient? innertubeClient,
  }) async {
    radioCalls++;
    return radioResponse;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Track makeTestTrack(String id, {String? title, String? artist}) {
  return Track(
    id: id,
    title: title ?? 'Track $id',
    artist: Artist(id: 'art-$id', name: artist ?? 'Artist $id'),
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
  late ProviderContainer container;

  setUp(() {
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
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('maybeFillRadio does not fill when autoplay is false', () async {
    final controller = container.read(playerControllerProvider.notifier);
    final track = makeTestTrack('yt-1');
    controller
      ..setAutoplay(value: false)
      ..playContext([track], 0);

    await controller.maybeFillRadio();
    expect(fakeInnertube.upNextCalls, 0);
  });

  test('maybeFillRadio does not fill when remaining items >= 4', () async {
    final controller = container.read(playerControllerProvider.notifier);
    final tracks = List.generate(6, (i) => makeTestTrack('yt-$i'));
    controller.playContext(tracks, 0); // remaining = 5

    await controller.maybeFillRadio();
    expect(fakeInnertube.upNextCalls, 0);
  });

  test(
    'maybeFillRadio fetches upNext and dedupes by ID and normalized title',
    () async {
      final controller = container.read(playerControllerProvider.notifier);
      final initial = [
        makeTestTrack('yt-0', title: 'Hello'),
        makeTestTrack('yt-1', title: 'Someone Like You'),
      ];
      controller.playContext(initial, 0); // remaining = 1 < 4

      // Mock upNext with:
      // 1. Same seed title "Hello" (should be skipped)
      // 2. Existing "Someone Like You (Live Version)" (normalized match)
      // 3. Duplicate ID "yt-1" (should be skipped)
      // 4. New track "Rolling in the Deep"
      // 5. New track "Set Fire to the Rain"
      fakeInnertube.upNextResponse = [
        makeTestTrack('yt-dup-seed', title: 'Hello'),
        makeTestTrack('yt-dup-norm', title: 'Someone Like You (Live Version)'),
        makeTestTrack('yt-1', title: 'Different Title'),
        makeTestTrack('yt-2', title: 'Rolling in the Deep'),
        makeTestTrack('yt-3', title: 'Set Fire to the Rain'),
      ];

      await controller.maybeFillRadio();

      expect(fakeInnertube.upNextCalls, greaterThanOrEqualTo(1));
      final q = container.read(playerControllerProvider).queue;
      expect(q.length, 4);
      expect(q[0].id, 'yt-0');
      expect(q[1].id, 'yt-1');
      expect(q[2].id, 'yt-2');
      expect(q[3].id, 'yt-3');
    },
  );

  test('maybeFillRadio falls back to Deezer when Innertube is empty', () async {
    final controller = container.read(playerControllerProvider.notifier);
    final initial = [makeTestTrack('yt-0', title: 'Seed Song')];
    controller.playContext(initial, 0);

    fakeInnertube.upNextResponse = [];
    fakeDeezer.radioResponse = [
      makeTestTrack('deezer-yt-1', title: 'Deezer Discovered 1'),
      makeTestTrack('deezer-yt-2', title: 'Deezer Discovered 2'),
    ];

    await controller.maybeFillRadio();

    expect(fakeDeezer.radioCalls, 1);
    final q = container.read(playerControllerProvider).queue;
    expect(q.length, 3);
    expect(q[1].title, 'Deezer Discovered 1');
    expect(q[2].title, 'Deezer Discovered 2');
  });

  test(
    'startRadio truncates upcoming queue, replaces with mix, and notifies',
    () async {
      final controller = container.read(playerControllerProvider.notifier);
      final initial = [
        makeTestTrack('yt-0', title: 'Song 0'),
        makeTestTrack('yt-1', title: 'Song 1 (to be replaced)'),
        makeTestTrack('yt-2', title: 'Song 2 (to be replaced)'),
      ];
      controller.playContext(initial, 0);

      fakeInnertube.upNextResponse = [
        makeTestTrack('mix-1', title: 'Mix Song 1'),
        makeTestTrack('mix-2', title: 'Mix Song 2'),
      ];

      await controller.startRadio();

      final state = container.read(playerControllerProvider);
      expect(state.queue.length, 3);
      expect(state.queue[0].id, 'yt-0');
      expect(state.queue[1].id, 'mix-1');
      expect(state.queue[2].id, 'mix-2');
      expect(state.notice, 'core.radioStarted');
    },
  );

  test('startRadio notifies table.radioFail when all sources fail', () async {
    final controller = container.read(playerControllerProvider.notifier);
    final initial = [makeTestTrack('yt-0', title: 'Song 0')];
    controller.playContext(initial, 0);

    fakeInnertube.upNextResponse = [];
    fakeDeezer.radioResponse = [];

    await controller.startRadio();

    final state = container.read(playerControllerProvider);
    expect(state.notice, 'table.radioFail');
  });
}
