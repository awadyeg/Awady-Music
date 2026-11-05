import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/artwork.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/stats_models.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/stats_repository.dart';
import 'package:awady_music/features/rewind/rewind_screen.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:awady_music/player/rewind.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';

class MockStatsRepository extends Mock implements StatsRepository;

class FakeRewindController extends RewindController {
  FakeRewindController(this.initial);
  final RewindData? initial;

  @override
  RewindData? build() => initial;
}

class FakePlayerController extends Notifier<PlayerState>
    implements PlayerController {
  Track? playedTrack;
  List<Track>? playedContext;

  @override
  PlayerState build() => const PlayerState();

  @override
  void playTrack(Track track, [List<Track>? context]) {
    playedTrack = track;
    playedContext = context;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _buildHarness({
  required MockStatsRepository statsRepo,
  FakePlayerController? playerController,
  RewindData? activeRewind,
  String? month,
  ThemeData? theme,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: [
      statsRepositoryProvider.overrideWithValue(statsRepo),
      if (playerController != null)
        playerControllerProvider.overrideWith(() => playerController),
      if (activeRewind != null)
        rewindControllerProvider.overrideWith(
          () => FakeRewindController(activeRewind),
        ),
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
      home: RewindScreen(month: month),
    ),
  );
}

void main() {
  const sampleArtist = Artist(id: 'art-1', name: 'Awady Legend');
  const sampleTrack = Track(
    id: 'tr-1',
    title: 'Favorite Track',
    artist: sampleArtist,
    duration: 200,
    source: TrackSource.yt,
    artwork: Artwork(s150: 'https://example.com/art.jpg'),
  );

  final sampleRewind = RewindData(
    key: '2026-10',
    label: 'October',
    full: 'October 2026',
    partial: false,
    ms: 3600000,
    plays: 25,
    tracks: [
      TrackAgg(track: sampleTrack, ms: 1200000, plays: 10),
      TrackAgg(
        track: sampleTrack.copyWith(id: 'tr-2', title: 'Second Song'),
        ms: 900000,
        plays: 8,
      ),
    ],
    artists: [
      ArtistAgg(
        name: 'Awady Legend',
        ms: 2100000,
        plays: 18,
        art: 'https://example.com/artist.jpg',
      ),
    ],
    trackCount: 15,
    artistCount: 8,
  );

  late MockStatsRepository statsRepo;
  late FakePlayerController playerController;

  setUp(() {
    statsRepo = MockStatsRepository();
    playerController = FakePlayerController();
  });

  testWidgets('Renders empty fallback when no RewindData is available', (
    tester,
  ) async {
    when(() => statsRepo.state).thenReturn(const StatsState());

    await tester.pumpWidget(
      _buildHarness(statsRepo: statsRepo, playerController: playerController),
    );
    await tester.pumpAndSettle();

    expect(find.text('No listening stats yet'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('Renders Intro slide and walks through all 5 slides', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    when(() => statsRepo.state).thenReturn(const StatsState());

    await tester.pumpWidget(
      _buildHarness(
        statsRepo: statsRepo,
        playerController: playerController,
        activeRewind: sampleRewind,
      ),
    );
    await tester.pump();

    // Slide 0: Intro
    expect(find.text('OCTOBER'), findsOneWidget);
    expect(find.text('REWIND'), findsOneWidget);
    expect(find.byIcon(LucideIcons.x), findsOneWidget);

    // Tap right side (> 30% of width) to advance to Slide 1 (Minutes)
    await tester.tapAt(const Offset(900, 600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Slide 1: Minutes
    expect(find.text('YOU LISTENED FOR'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
    expect(find.text('min'), findsOneWidget);
    expect(find.text('15 tracks'), findsOneWidget);
    expect(find.text('8 artists'), findsOneWidget);

    // Tap right to advance to Slide 2 (Artist)
    await tester.tapAt(const Offset(900, 600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Slide 2: Top Artist
    expect(find.text('YOUR #1 ARTIST'), findsOneWidget);
    expect(find.text('Awady Legend'), findsOneWidget);
    expect(find.text('1'), findsWidgets);

    // Tap right to advance to Slide 3 (Tracks)
    await tester.tapAt(const Offset(900, 600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Slide 3: Tracks
    expect(find.text("The songs you couldn't stop"), findsOneWidget);
    expect(find.text('Favorite Track'), findsOneWidget);
    expect(find.text('Second Song'), findsOneWidget);
    expect(find.text('Play your top tracks'), findsOneWidget);

    // Tapping "Play your top tracks" plays the songs
    await tester.tap(find.text('Play your top tracks'));
    await tester.pump();
    expect(playerController.playedTrack?.id, equals('tr-1'));
    expect(playerController.playedContext?.length, equals(2));

    // Tap right to advance to Slide 4 (Outro)
    await tester.tapAt(const Offset(900, 600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Slide 4: Outro
    expect(find.text('THAT WAS'), findsOneWidget);
    expect(find.text('October.'), findsOneWidget);
    expect(find.text('Play it again'), findsOneWidget);
    expect(find.text('Keep listening'), findsOneWidget);

    // Tap left side (< 30% width) goes back to previous slide
    await tester.tapAt(const Offset(100, 600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Back to Slide 3 (Tracks)
    expect(find.text("The songs you couldn't stop"), findsOneWidget);
  });

  testWidgets('Renders Arabic RTL and Light theme cleanly', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    when(() => statsRepo.state).thenReturn(const StatsState());

    await tester.pumpWidget(
      _buildHarness(
        statsRepo: statsRepo,
        playerController: playerController,
        activeRewind: sampleRewind,
        theme: AppTheme.light(),
        locale: const Locale('ar'),
      ),
    );
    await tester.pump();

    expect(find.text('OCTOBER'), findsOneWidget);
    expect(find.text('REWIND'), findsOneWidget);
  });
}
