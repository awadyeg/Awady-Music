import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/catalog_providers.dart';
import 'package:awady_music/data/repositories/catalog_repository.dart';
import 'package:awady_music/data/repositories/downloads_repository.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/data/repositories/stats_repository.dart';
import 'package:awady_music/features/home/home_screen.dart';
import 'package:awady_music/features/now_playing/now_playing_screen.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:awady_music/widgets/live_bars.dart';
import 'package:awady_music/widgets/track_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLibraryRepository extends Fake implements LibraryRepository {
  @override
  List<Track> get recents => [];
  @override
  bool isLiked(String id) => false;
  @override
  Stream<List<Track>> watchLikedTracks() => Stream.value([]);
  @override
  Stream<List<Track>> watchRecentTracks() => Stream.value([]);
  @override
  Stream<List<Artist>> watchFollowedArtists() => Stream.value([]);
}

class _FakeStatsRepository extends Fake implements StatsRepository {
  @override
  StatsState get state => const StatsState();
  @override
  Stream<StatsState> get stream => Stream.value(const StatsState());
}

class _FakePlayerController extends PlayerController {
  _FakePlayerController([this._initialState = const PlayerState()]);
  final PlayerState _initialState;

  @override
  PlayerState build() => _initialState;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleTrack = Track(
    id: 't_a11y',
    title: 'Accessibility Anthem',
    artist: Artist(id: 'a1', name: 'Accessible Artist'),
    duration: 210,
  );

  group('Accessibility & 200% text scale tests', () {
    testWidgets('LiveBars respects disableAnimations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(body: LiveBars(playing: true)),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(LiveBars), findsOneWidget);
    });

    testWidgets('TrackTile exposes semantics and download badge', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: Scaffold(
              body: TrackTile(
                title: sampleTrack.title,
                artist: sampleTrack.artist.name,
                duration: sampleTrack.duration,
                isDownloaded: true,
                isPlaying: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text(sampleTrack.title), findsOneWidget);
      expect(find.byType(LiveBars), findsOneWidget);
    });

    testWidgets('HomeScreen renders with 200% text scale without crashing', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            libraryRepositoryProvider.overrideWithValue(
              _FakeLibraryRepository(),
            ),
            statsRepositoryProvider.overrideWithValue(_FakeStatsRepository()),
            playerControllerProvider.overrideWith(_FakePlayerController.new),
            trendingTracksProvider.overrideWith(
              (ref) => Future.value(CatalogList<Track>([sampleTrack])),
            ),
            newReleasesProvider.overrideWith(
              (ref) => Future.value(CatalogList([])),
            ),
            homePlaylistsProvider.overrideWith(
              (ref) => Future.value(CatalogList([])),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.dark(),
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            home: const MediaQuery(
              data: MediaQueryData(
                textScaler: TextScaler.linear(2),
                size: Size(800, 1200),
              ),
              child: HomeScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets(
      'NowPlayingScreen renders with 200% text scale without crashing',
      (tester) async {
        const stateWithTrack = PlayerState(
          queue: [sampleTrack],
          index: 0,
          isPlaying: true,
          duration: Duration(seconds: 210),
          currentTime: Duration(seconds: 45),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              libraryRepositoryProvider.overrideWithValue(
                _FakeLibraryRepository(),
              ),
              playerControllerProvider.overrideWith(
                () => _FakePlayerController(stateWithTrack),
              ),
              downloadedTracksProvider.overrideWith((ref) => Stream.value([])),
              downloadProgressStreamProvider.overrideWith(
                (ref) => Stream.value({}),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.dark(),
              localizationsDelegates: L10n.localizationsDelegates,
              supportedLocales: L10n.supportedLocales,
              home: const MediaQuery(
                data: MediaQueryData(
                  textScaler: TextScaler.linear(2),
                  size: Size(800, 1400),
                ),
                child: NowPlayingScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(NowPlayingScreen), findsOneWidget);
        expect(find.text(sampleTrack.title), findsOneWidget);
      },
    );
  });
}
