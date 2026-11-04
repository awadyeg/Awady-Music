import 'dart:async';

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
import 'package:awady_music/player/prefetch.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;

class FakeAudioHandler extends AwadyAudioHandler {
  final _posController = StreamController<Duration>.broadcast();
  final _durController = StreamController<Duration?>.broadcast();

  @override
  Stream<Duration> get positionStream => _posController.stream;

  void emitPosition(Duration pos) => _posController.add(pos);
  void emitDuration(Duration? dur) => _durController.add(dur);

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
  Future<void> dispose() async {
    await _posController.close();
    await _durController.close();
  }
}

class FakeStreamResolver implements StreamResolver {
  final List<String> prefetched = [];

  @override
  void prefetch(String videoId) {
    prefetched.add(videoId);
  }

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
}

class FakeAudiusClient implements AudiusClient {
  @override
  String streamUrl(String trackId) => 'https://audius.co/stream/$trackId';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Track makeTestTrack(String id, {String source = 'yt', int duration = 200}) {
  return Track(
    id: id,
    title: 'Track $id',
    artist: Artist(id: 'art-$id', name: 'Artist $id'),
    source: source == 'yt' ? TrackSource.yt : TrackSource.audius,
    streamId: id,
    duration: duration,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAudioHandler audioHandler;
  late FakeStreamResolver fakeResolver;
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    audioHandler = FakeAudioHandler();
    fakeResolver = FakeStreamResolver();
    db = AppDatabase(NativeDatabase.memory());

    container = ProviderContainer(
      overrides: [
        audioHandlerProvider.overrideWithValue(audioHandler),
        streamResolverProvider.overrideWithValue(fakeResolver),
        audiusClientProvider.overrideWithValue(FakeAudiusClient()),
        appDatabaseProvider.overrideWithValue(db),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await audioHandler.dispose();
    await db.close();
  });

  group('T-31 Prefetch tests', () {
    test('prefetches next track when playback passes 50%', () async {
      final controller = container.read(playerControllerProvider.notifier);
      final tracks = [makeTestTrack('t1'), makeTestTrack('t2')];

      controller.playContext(tracks, 0);
      await Future<void>.delayed(const Duration(milliseconds: 30));

      // At 40s (20%), no prefetch
      audioHandler.emitPosition(const Duration(seconds: 40));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(fakeResolver.prefetched, isEmpty);

      // At 100s (50%), next track 't2' is prefetched
      audioHandler.emitPosition(const Duration(seconds: 100));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(fakeResolver.prefetched, ['t2']);

      // Advancing to 120s does not re-prefetch (deduped)
      audioHandler.emitPosition(const Duration(seconds: 120));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(fakeResolver.prefetched.length, 1);
    });

    test('prefetchTracksWithResolver prefetches top 3 items of a list', () {
      final tracks = [
        makeTestTrack('s1'),
        makeTestTrack('s2'),
        makeTestTrack('s3'),
        makeTestTrack('s4'),
        makeTestTrack('s5'),
      ];

      prefetchTracksWithResolver(fakeResolver, tracks);

      expect(fakeResolver.prefetched, ['s1', 's2', 's3']);
    });
  });
}
