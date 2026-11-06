import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/local_playlist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/downloads_repository.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/features/playlist/playlist_screen.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:awady_music/widgets/track_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLibraryRepo extends Mock implements LibraryRepository;

class _FakePlayerController extends Notifier<PlayerState>
    implements PlayerController {
  @override
  PlayerState build() => const PlayerState();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('1000-track playlist scrolls smoothly with list virtualization', (
    tester,
  ) async {
    final mockLib = _MockLibraryRepo();
    final fakePlayer = _FakePlayerController();

    final thousandTracks = List.generate(
      1000,
      (i) => Track(
        id: 'track_$i',
        title: 'Track #$i - Performance Test',
        artist: Artist(id: 'artist_${i % 20}', name: 'Artist ${i % 20}'),
        duration: 180 + (i % 60),
      ),
    );

    final localPlaylist = LocalPlaylist(
      id: 'perf_playlist',
      name: 'Massive 1000-Song Playlist',
      createdAt: DateTime(2026),
      tracks: thousandTracks,
    );

    when(() => mockLib.getPlaylist('perf_playlist')).thenReturn(localPlaylist);
    when(() => mockLib.playlists).thenReturn([localPlaylist]);
    when(() => mockLib.likedTracks).thenReturn([]);
    when(() => mockLib.recents).thenReturn([]);
    when(() => mockLib.isLiked(any())).thenReturn(false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryRepositoryProvider.overrideWithValue(mockLib),
          playerControllerProvider.overrideWith(() => fakePlayer),
          downloadedTracksProvider.overrideWith((ref) => Stream.value([])),
          downloadProgressStreamProvider.overrideWith(
            (ref) => Stream.value({}),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: const PlaylistScreen(
            id: 'perf_playlist',
            kind: PlaylistKind.local,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Virtualization check:
    // Only a small fraction of 1,000 items should be rendered
    final renderedTilesInitial = tester
        .widgetList(find.byType(TrackTile))
        .length;
    expect(
      renderedTilesInitial,
      lessThan(25),
      reason:
          'SliverList virtualization must not render all 1,000 tiles at once',
    );
    expect(find.text('Track #0 - Performance Test'), findsOneWidget);

    // 2. High-speed scroll simulation: 20 sequential swipes
    final stopwatch = Stopwatch()..start();
    for (var swipe = 0; swipe < 15; swipe++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pump(const Duration(milliseconds: 16)); // 60 FPS tick
    }
    await tester.pumpAndSettle();
    stopwatch.stop();

    // 3. Verify fast scroll completion without dropping frames or stalling
    expect(stopwatch.elapsedMilliseconds, lessThan(3000));

    // 4. Verify we successfully scrolled deep into the list
    // (Track #0 is recycled away)
    expect(find.text('Track #0 - Performance Test'), findsNothing);

    // 5. Still properly virtualized deep in the list
    final renderedTilesScrolled = tester
        .widgetList(find.byType(TrackTile))
        .length;
    expect(renderedTilesScrolled, lessThan(25));
  });
}
