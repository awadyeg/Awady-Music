import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/search_results.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/catalog_providers.dart';
import 'package:awady_music/data/repositories/catalog_repository.dart';
import 'package:awady_music/data/sources/audius/audius_client.dart';
import 'package:awady_music/features/genre/genre_screen.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:awady_music/widgets/large_title_scaffold.dart';
import 'package:awady_music/widgets/track_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogRepository extends Mock implements CatalogRepository;

class MockAudiusClient extends Mock implements AudiusClient;

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
  required MockCatalogRepository catalogRepo,
  required MockAudiusClient audiusClient,
  required FakePlayerController playerController,
  String genre = 'Electronic',
}) {
  return ProviderScope(
    overrides: [
      catalogRepositoryProvider.overrideWithValue(catalogRepo),
      audiusClientProvider.overrideWithValue(audiusClient),
      playerControllerProvider.overrideWith(() => playerController),
    ],
    child: MaterialApp(
      theme: AppTheme.dark(),
      supportedLocales: const [Locale('en'), Locale('es'), Locale('ar')],
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: GenreScreen(name: genre)),
    ),
  );
}

void main() {
  const sampleTrack = Track(
    id: 't_g_1',
    title: 'Strobe',
    artist: Artist(id: 'a_deadmau5', name: 'deadmau5'),
    duration: 630,
  );

  late MockCatalogRepository catalogRepo;
  late MockAudiusClient audiusClient;
  late FakePlayerController playerController;

  setUp(() {
    catalogRepo = MockCatalogRepository();
    audiusClient = MockAudiusClient();
    playerController = FakePlayerController();
    when(() => catalogRepo.search(any()))
        .thenAnswer((_) async => const SearchResults(songs: [sampleTrack]));
  });

  group('GenreScreen widget tests', () {
    testWidgets('renders genre name, kicker, and filter chips', (tester) async {
      when(() => catalogRepo.search('Electronic hits'))
          .thenAnswer((_) async => const SearchResults(songs: [sampleTrack]));

      await tester.pumpWidget(
        _buildHarness(
          catalogRepo: catalogRepo,
          audiusClient: audiusClient,
          playerController: playerController,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LargeTitleScaffold), findsOneWidget);
      expect(find.text('Electronic'), findsWidgets);
      expect(find.text('Genre'), findsOneWidget);
      expect(find.text('Top hits'), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('This month'), findsOneWidget);
      expect(find.text('All time'), findsOneWidget);
      expect(find.byType(TrackTile), findsOneWidget);
      expect(find.text('Strobe'), findsOneWidget);
    });

    testWidgets('tapping big play button plays all tracks in genre', (
      tester,
    ) async {
      when(() => catalogRepo.search('Electronic hits'))
          .thenAnswer((_) async => const SearchResults(songs: [sampleTrack]));

      await tester.pumpWidget(
        _buildHarness(
          catalogRepo: catalogRepo,
          audiusClient: audiusClient,
          playerController: playerController,
        ),
      );
      await tester.pumpAndSettle();

      final playButton = find.widgetWithText(ElevatedButton, 'Play');
      expect(playButton, findsOneWidget);

      await tester.tap(playButton);
      await tester.pumpAndSettle();

      expect(playerController.playedTrack?.id, equals('t_g_1'));
      expect(playerController.playedContext?.length, equals(1));
    });

    testWidgets('switching time chips fetches trending from Audius', (
      tester,
    ) async {
      when(() => catalogRepo.search('Electronic trending songs this week'))
          .thenAnswer((_) async => const SearchResults());

      const audiusTrack = Track(
        id: 't_g_audius',
        title: 'Faded',
        artist: Artist(id: 'a_walker', name: 'Alan Walker'),
        duration: 210,
      );

      when(
        () => audiusClient.trendingTracks(
          genre: 'Electronic',
          time: 'week',
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => [audiusTrack]);

      await tester.pumpWidget(
        _buildHarness(
          catalogRepo: catalogRepo,
          audiusClient: audiusClient,
          playerController: playerController,
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'This week'
      await tester.tap(find.text('This week'));
      await tester.pumpAndSettle();

      expect(find.text('Faded'), findsOneWidget);
    });

    testWidgets('shows error state and retry button on load failure', (
      tester,
    ) async {
      when(() => catalogRepo.search(any()))
          .thenThrow(Exception('Catalog network failure'));

      when(
        () => audiusClient.trendingTracks(
          genre: 'Electronic',
          time: any(named: 'time'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('Audius failure'));

      await tester.pumpWidget(
        _buildHarness(
          catalogRepo: catalogRepo,
          audiusClient: audiusClient,
          playerController: playerController,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Couldn't load this genre right now."), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
