import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/artwork.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/stats_models.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/stats_repository.dart';
import 'package:awady_music/features/stats/stats_screen.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';

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
  required MockStatsRepository statsRepo,
  FakePlayerController? playerController,
  List<dynamic> overrides = const [],
  ThemeData? theme,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: [
      statsRepositoryProvider.overrideWithValue(statsRepo),
      if (playerController != null)
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
      home: const Scaffold(body: StatsScreen()),
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

  late MockStatsRepository statsRepo;
  late FakePlayerController playerController;

  setUp(() {
    statsRepo = MockStatsRepository();
    playerController = FakePlayerController();
  });

  testWidgets('Renders empty state when totalPlays is 0', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    when(() => statsRepo.state).thenReturn(const StatsState());

    await tester.pumpWidget(
      _buildHarness(statsRepo: statsRepo, playerController: playerController),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your stats'), findsWidgets);
    expect(find.text('No listening stats yet'), findsOneWidget);
    expect(
      find.text(
        'Start playing songs to track your favorite artists, tracks, '
        'and listening habits',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'Renders 4 stat cards, 7-day bar chart, top tracks and top artists',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final today = dayKey();
      final statsState = StatsState(
        totalPlays: 42,
        totalMs: 7200000,
        days: {today: 3600000},
        tracks: {'tr-1': TrackAgg(track: sampleTrack, plays: 15, ms: 3000000)},
        artists: {
          'Awady Legend': ArtistAgg(
            name: 'Awady Legend',
            plays: 20,
            ms: 4000000,
          ),
        },
      );
      when(() => statsRepo.state).thenReturn(statsState);

      await tester.pumpWidget(
        _buildHarness(statsRepo: statsRepo, playerController: playerController),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your stats'), findsWidgets);

      // Stat cards
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('Total plays'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('Tracks played'), findsOneWidget);
      expect(find.text('Artists heard'), findsOneWidget);

      // Custom painter Bar Chart
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('Listening time'), findsOneWidget);

      // Top tracks
      expect(find.text('Top tracks'), findsOneWidget);
      expect(find.text('Favorite Track'), findsOneWidget);

      // Tap top track to play
      await tester.tap(find.text('Favorite Track'));
      await tester.pumpAndSettle();
      expect(playerController.playedTrack?.id, equals('tr-1'));

      // Top artists
      expect(find.text('Top artists'), findsOneWidget);
      expect(find.text('Awady Legend'), findsNWidgets(2));
    },
  );

  testWidgets('Rewind banner appears when availableRewind exists', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final curMonth = monthKey();
    final statsState = StatsState(
      totalPlays: 10,
      totalMs: 1200000,
      months: {
        curMonth: MonthAgg(
          plays: 10,
          ms: 1200000,
          tracks: {
            'tr-1': TrackAgg(track: sampleTrack, plays: 10, ms: 1200000),
          },
          artists: {
            'Awady Legend': ArtistAgg(
              name: 'Awady Legend',
              plays: 10,
              ms: 1200000,
            ),
          },
        ),
      },
    );
    when(() => statsRepo.state).thenReturn(statsState);

    await tester.pumpWidget(
      _buildHarness(statsRepo: statsRepo, playerController: playerController),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(LucideIcons.sparkles), findsOneWidget);
    expect(find.textContaining('so far'), findsOneWidget);
  });

  testWidgets('RTL Arabic and Light theme render without error', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    when(() => statsRepo.state).thenReturn(const StatsState());

    // Arabic / RTL
    await tester.pumpWidget(
      _buildHarness(
        statsRepo: statsRepo,
        playerController: playerController,
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(StatsScreen), findsOneWidget);

    // Light theme
    await tester.pumpWidget(
      _buildHarness(
        statsRepo: statsRepo,
        playerController: playerController,
        theme: AppTheme.light(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(StatsScreen), findsOneWidget);
  });
}
