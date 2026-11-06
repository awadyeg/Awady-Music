import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/local_playlist.dart';
import 'package:awady_music/data/models/lyrics.dart';
import 'package:awady_music/data/models/mood_models.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/catalog_providers.dart';
import 'package:awady_music/data/repositories/catalog_repository.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/data/repositories/lyrics_repository.dart';
import 'package:awady_music/features/tv/tv_home_screen.dart';
import 'package:awady_music/player/connect_receiver.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';

class MockLibraryRepository extends Mock implements LibraryRepository;

class FakeConnectReceiverNotifier extends Notifier<ConnectReceiverState>
    implements ConnectReceiverNotifier {
  @override
  ConnectReceiverState build() => const ConnectReceiverState();

  @override
  Future<void> start({int? port}) async {}

  @override
  void stop() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePlayerController extends Notifier<PlayerState>
    implements PlayerController {
  FakePlayerController({PlayerState? initial})
    : _initial = initial ?? const PlayerState();

  final PlayerState _initial;
  bool toggleCalled = false;
  bool nextCalled = false;
  bool prevCalled = false;

  @override
  PlayerState build() => _initial;

  @override
  Future<void> toggle() async {
    toggleCalled = true;
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  @override
  void next({bool auto = false}) {
    nextCalled = true;
  }

  @override
  void prev() {
    prevCalled = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _buildTvHarness({
  required FakePlayerController playerController,
  required MockLibraryRepository libraryRepo,
  VoidCallback? onExitTvMode,
  List<Track> sampleTracks = const [],
}) {
  return ProviderScope(
    overrides: [
      playerControllerProvider.overrideWith(() => playerController),
      connectReceiverProvider.overrideWith(FakeConnectReceiverNotifier.new),
      libraryRepositoryProvider.overrideWithValue(libraryRepo),
      trendingTracksProvider.overrideWith(
        (ref) async => CatalogList(sampleTracks),
      ),
      recommendedForYouProvider.overrideWith(
        (ref) async => CatalogList(sampleTracks),
      ),
      chartsProvider.overrideWith((ref) async => CatalogList(sampleTracks)),
      moodCategoriesProvider.overrideWith(
        (ref) async => const <MoodCategory>[],
      ),
      lyricsForTrackProvider.overrideWith(
        (ref, track) async => const NoLyrics(),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: TvHomeScreen(onExitTvMode: onExitTvMode),
    ),
  );
}

void main() {
  const sampleTrack = Track(
    id: 't_tv_1',
    title: 'Blinding Lights',
    artist: Artist(id: 'a_theweeknd', name: 'The Weeknd'),
    duration: 200,
  );

  late MockLibraryRepository libraryRepo;

  setUp(() {
    libraryRepo = MockLibraryRepository();
    when(() => libraryRepo.isLiked(any())).thenReturn(false);
    when(() => libraryRepo.likedTracks).thenReturn(<Track>[sampleTrack]);
    when(() => libraryRepo.playlists).thenReturn(<LocalPlaylist>[]);
  });

  testWidgets('TvHomeScreen renders TV sidebar navigation and starts in Home', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fakePlayer = FakePlayerController();
    await tester.pumpWidget(
      _buildTvHarness(
        playerController: fakePlayer,
        libraryRepo: libraryRepo,
        sampleTracks: const [sampleTrack],
      ),
    );
    await tester.pumpAndSettle();

    // Verify sidebar navigation icons
    expect(find.byIcon(LucideIcons.house), findsOneWidget);
    expect(find.byIcon(LucideIcons.search), findsOneWidget);
    expect(find.byIcon(LucideIcons.library), findsOneWidget);
    expect(find.byIcon(LucideIcons.disc), findsOneWidget);
    expect(find.byIcon(LucideIcons.settings), findsOneWidget);
    expect(find.byIcon(LucideIcons.minimize2), findsOneWidget);

    // Verify TV Home carousels are present
    expect(find.text('Trending Now'), findsOneWidget);
    expect(find.text('Recommended For You'), findsOneWidget);
    expect(find.text('Top Charts'), findsOneWidget);
  });

  testWidgets('TvHomeScreen switches between sidebar tabs', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fakePlayer = FakePlayerController();
    await tester.pumpWidget(
      _buildTvHarness(
        playerController: fakePlayer,
        libraryRepo: libraryRepo,
        sampleTracks: const [sampleTrack],
      ),
    );
    await tester.pumpAndSettle();

    // 1. Switch to Search tab
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    expect(find.text('Search songs, artists, or genres...'), findsOneWidget);
    expect(find.text('Browse Categories & Moods'), findsOneWidget);

    // 2. Switch to Library tab
    await tester.tap(find.byTooltip('Library'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Liked Songs'), findsOneWidget);

    // 3. Switch to Settings tab
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Awady Connect Receiver'), findsOneWidget);

    // 4. Switch back to Home tab
    await tester.tap(find.byTooltip('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Trending Now'), findsOneWidget);
  });

  testWidgets('TvHomeScreen renders track details and triggers controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fakePlayer = FakePlayerController(
      initial: const PlayerState(
        queue: [sampleTrack],
        index: 0,
        isPlaying: true,
        duration: Duration(seconds: 200),
      ),
    );

    await tester.pumpWidget(
      _buildTvHarness(
        playerController: fakePlayer,
        libraryRepo: libraryRepo,
        sampleTracks: const [sampleTrack],
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to Now Playing tab via sidebar
    await tester.tap(find.byTooltip('Now Playing'));
    await tester.pumpAndSettle();

    expect(find.text('Blinding Lights'), findsOneWidget);
    expect(find.text('The Weeknd'), findsOneWidget);

    // Tap pause button
    final pauseFinder = find.byIcon(LucideIcons.pause);
    expect(pauseFinder, findsOneWidget);
    await tester.tap(pauseFinder);
    expect(fakePlayer.toggleCalled, isTrue);

    // Tap next button
    final nextFinder = find.byIcon(LucideIcons.skipForward);
    expect(nextFinder, findsOneWidget);
    await tester.tap(nextFinder);
    expect(fakePlayer.nextCalled, isTrue);

    // Switch right panel to Up Next tab
    final upNextTab = find.text('Up Next (1)');
    expect(upNextTab, findsOneWidget);
    await tester.tap(upNextTab);
    await tester.pumpAndSettle();

    // Verify track is listed in Up Next queue
    expect(find.text('Blinding Lights'), findsWidgets);

    // Tap Back button in Now Playing
    final backFinder = find.byIcon(LucideIcons.arrowLeft);
    expect(backFinder, findsOneWidget);
    await tester.tap(backFinder);
    await tester.pumpAndSettle();

    // Should return to Home tab
    expect(find.text('Trending Now'), findsOneWidget);
  });

  testWidgets(
    'TvHomeScreen shows TV Mini Player when browsing with active track',
    (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakePlayer = FakePlayerController(
        initial: const PlayerState(
          queue: [sampleTrack],
          index: 0,
          isPlaying: true,
          duration: Duration(seconds: 200),
        ),
      );

      await tester.pumpWidget(
        _buildTvHarness(
          playerController: fakePlayer,
          libraryRepo: libraryRepo,
          sampleTracks: const [sampleTrack],
        ),
      );
      await tester.pumpAndSettle();

      // In Home tab, with track playing, mini player is visible.
      // Tap on the mini player's track info (e.g. artist text in mini player)
      final miniPlayerArtistFinder = find.text('The Weeknd').last;
      await tester.tap(miniPlayerArtistFinder);
      await tester.pumpAndSettle();

      // Should now be on Now Playing view: Back button is present
      expect(find.byIcon(LucideIcons.arrowLeft), findsOneWidget);
    },
  );

  testWidgets('TvHomeScreen handles Exit TV mode button', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var exitCalled = false;
    final fakePlayer = FakePlayerController();
    await tester.pumpWidget(
      _buildTvHarness(
        playerController: fakePlayer,
        libraryRepo: libraryRepo,
        onExitTvMode: () => exitCalled = true,
      ),
    );
    await tester.pumpAndSettle();

    // Tap Exit TV button
    await tester.tap(find.byTooltip('Exit TV Mode'));
    await tester.pumpAndSettle();

    expect(exitCalled, isTrue);
  });

  testWidgets('TvHomeScreen focuses Home sidebar button initially and handles '
      'D-pad Select activation', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fakePlayer = FakePlayerController();
    await tester.pumpWidget(
      _buildTvHarness(
        playerController: fakePlayer,
        libraryRepo: libraryRepo,
        sampleTracks: const [sampleTrack],
      ),
    );
    await tester.pumpAndSettle();

    // Home button in sidebar has autofocus: true
    // Pressing D-pad Down moves focus to Search
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    // Pressing D-pad Center (LogicalKeyboardKey.select) activates Search tab
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();

    // Search tab should now be visible
    expect(find.text('Search songs, artists, or genres...'), findsOneWidget);
    // Verify fakePlayer.toggle was NOT hijacked by the select key
    expect(fakePlayer.toggleCalled, isFalse);
  });
}
