import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/lyrics.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/data/repositories/lyrics_repository.dart';
import 'package:awady_music/features/tv/tv_home_screen.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';

class MockLibraryRepository extends Mock implements LibraryRepository;

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
}) {
  return ProviderScope(
    overrides: [
      playerControllerProvider.overrideWith(() => playerController),
      libraryRepositoryProvider.overrideWithValue(libraryRepo),
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
      home: const TvHomeScreen(),
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
  });

  testWidgets('TvHomeScreen displays header and empty state when idle', (
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
      _buildTvHarness(playerController: fakePlayer, libraryRepo: libraryRepo),
    );
    await tester.pumpAndSettle();

    expect(find.text('Awady Music TV'), findsOneWidget);
    expect(find.text('Awady Music TV Mode'), findsOneWidget);
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
      _buildTvHarness(playerController: fakePlayer, libraryRepo: libraryRepo),
    );
    await tester.pumpAndSettle();

    expect(find.text('Blinding Lights'), findsOneWidget);
    expect(find.text('The Weeknd'), findsOneWidget);

    // Tap pause button
    final pauseFinder = find.byIcon(LucideIcons.pause);
    expect(pauseFinder, findsOneWidget);
    await tester.tap(pauseFinder);
    expect(fakePlayer.toggleCalled, isTrue);

    // Switch right panel to Up Next tab
    final upNextTab = find.text('Up Next (1)');
    expect(upNextTab, findsOneWidget);
    await tester.tap(upNextTab);
    await tester.pumpAndSettle();

    // Verify track is listed in Up Next queue
    expect(find.text('Blinding Lights'), findsWidgets);
  });
}
