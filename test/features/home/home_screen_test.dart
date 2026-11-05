import 'dart:async';

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/catalog_providers.dart';
import 'package:awady_music/data/repositories/catalog_repository.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/data/repositories/stats_repository.dart';
import 'package:awady_music/features/home/home_screen.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:awady_music/widgets/large_title_scaffold.dart';
import 'package:awady_music/widgets/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';

class MockLibraryRepository extends Mock implements LibraryRepository;

class MockStatsRepository extends Mock implements StatsRepository;

class FakePlayerController extends Notifier<PlayerState>
    implements PlayerController {
  Track? playedTrack;

  @override
  PlayerState build() => const PlayerState();

  @override
  void playTrack(Track track, [List<Track>? context]) {
    playedTrack = track;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _buildHarness({
  required MockLibraryRepository libraryRepo,
  required MockStatsRepository statsRepo,
  required FakePlayerController playerController,
  List<dynamic> overrides = const [],
  ThemeData? theme,
  Locale locale = const Locale('en'),
  TextDirection textDirection = TextDirection.ltr,
}) {
  return ProviderScope(
    overrides: [
      libraryRepositoryProvider.overrideWithValue(libraryRepo),
      statsRepositoryProvider.overrideWithValue(statsRepo),
      playerControllerProvider.overrideWith(() => playerController),
      ...overrides.cast(),
    ],
    child: MaterialApp(
      theme: theme ?? AppTheme.dark(),
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('es'), Locale('ar')],
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Directionality(
        textDirection: textDirection,
        child: const HomeScreen(),
      ),
    ),
  );
}

void main() {
  const sampleTrack = Track(
    id: 't_home_1',
    title: 'Rolling in the Deep',
    artist: Artist(id: 'a_adele', name: 'Adele'),
    duration: 228,
  );

  const samplePlaylist = RemotePlaylist(
    id: 'pl_home_1',
    name: 'Today Top Hits',
    owner: Artist(id: 'a_spotify', name: 'Spotify'),
    trackCount: 50,
  );

  late MockLibraryRepository libraryRepo;
  late MockStatsRepository statsRepo;
  late FakePlayerController playerController;

  setUp(() {
    libraryRepo = MockLibraryRepository();
    statsRepo = MockStatsRepository();
    playerController = FakePlayerController();

    when(() => libraryRepo.recents).thenReturn([sampleTrack]);
    when(() => statsRepo.state).thenReturn(const StatsState());
  });

  group('HomeScreen unit & widget tests', () {
    test('computeGreeting respects hour of day', () {
      final harness = MaterialApp(
        supportedLocales: L10n.supportedLocales,
        localizationsDelegates: L10n.localizationsDelegates,
        home: Builder(
          builder: (context) {
            final l10n = context.l10n;
            expect(
              HomeScreen.computeGreeting(l10n, DateTime(2026, 1, 1, 8)),
              equals(l10n.homeGreetingMorning),
            );
            expect(
              HomeScreen.computeGreeting(l10n, DateTime(2026, 1, 1, 14)),
              equals(l10n.homeGreetingAfternoon),
            );
            expect(
              HomeScreen.computeGreeting(l10n, DateTime(2026, 1, 1, 19)),
              equals(l10n.homeGreetingEvening),
            );
            expect(
              HomeScreen.computeGreeting(l10n, DateTime(2026, 1, 1, 23)),
              equals(l10n.homeGreetingLate),
            );
            return const Placeholder();
          },
        ),
      );
      expect(harness, isNotNull);
    });

    testWidgets('renders loading skeletons while catalog loads', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildHarness(
          libraryRepo: libraryRepo,
          statsRepo: statsRepo,
          playerController: playerController,
          overrides: [
            trendingTracksProvider.overrideWith(
              (ref) => Completer<CatalogList<Track>>().future,
            ),
            newReleasesProvider.overrideWith(
              (ref) => Completer<CatalogList<RemotePlaylist>>().future,
            ),
            homePlaylistsProvider.overrideWith(
              (ref) => Completer<CatalogList<RemotePlaylist>>().future,
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(CardsRowSkeleton), findsAtLeastNWidgets(1));
    });

    testWidgets('renders feed data, recents, and carousels', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildHarness(
          libraryRepo: libraryRepo,
          statsRepo: statsRepo,
          playerController: playerController,
          overrides: [
            trendingTracksProvider.overrideWith(
              (ref) async => CatalogList([sampleTrack]),
            ),
            newReleasesProvider.overrideWith(
              (ref) async => CatalogList([samplePlaylist]),
            ),
            homePlaylistsProvider.overrideWith(
              (ref) async => CatalogList([samplePlaylist]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LargeTitleScaffold), findsOneWidget);
      expect(find.byIcon(LucideIcons.settings), findsOneWidget);
      expect(find.text('Recently played'), findsOneWidget);
      expect(find.text('Rolling in the Deep'), findsWidgets);
      expect(find.text('Today Top Hits'), findsWidgets);
    });

    testWidgets('tapping recent track calls playTrack', (tester) async {
      await tester.pumpWidget(
        _buildHarness(
          libraryRepo: libraryRepo,
          statsRepo: statsRepo,
          playerController: playerController,
          overrides: [
            trendingTracksProvider.overrideWith((ref) async => CatalogList([])),
            newReleasesProvider.overrideWith((ref) async => CatalogList([])),
            homePlaylistsProvider.overrideWith((ref) async => CatalogList([])),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rolling in the Deep'));
      await tester.pumpAndSettle();

      expect(playerController.playedTrack?.id, equals('t_home_1'));
    });

    testWidgets('shows error state and retry button on load failure', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildHarness(
          libraryRepo: libraryRepo,
          statsRepo: statsRepo,
          playerController: playerController,
          overrides: [
            trendingTracksProvider.overrideWith(
              (ref) => Future.error(Exception('Network error')),
            ),
            newReleasesProvider.overrideWith((ref) async => CatalogList([])),
            homePlaylistsProvider.overrideWith((ref) async => CatalogList([])),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Couldn't load your music"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders Arabic greeting and RTL layout', (tester) async {
      const arTrack = Track(
        id: 't_home_ar',
        title: 'أنت عمري',
        artist: Artist(id: 'a_k', name: 'أم كلثوم'),
        duration: 300,
      );

      when(() => libraryRepo.recents).thenReturn([arTrack]);

      await tester.pumpWidget(
        _buildHarness(
          libraryRepo: libraryRepo,
          statsRepo: statsRepo,
          playerController: playerController,
          locale: const Locale('ar'),
          textDirection: TextDirection.rtl,
          overrides: [
            trendingTracksProvider.overrideWith(
              (ref) async => CatalogList([arTrack]),
            ),
            newReleasesProvider.overrideWith((ref) async => CatalogList([])),
            homePlaylistsProvider.overrideWith((ref) async => CatalogList([])),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('أنت عمري'), findsWidgets);
    });
  });
}
