import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/mood_models.dart';
import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/search_results.dart';
import 'package:awady_music/data/models/stream_info.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/catalog_providers.dart';
import 'package:awady_music/data/repositories/catalog_repository.dart';
import 'package:awady_music/data/sources/ytstream/stream_resolver_impl.dart';
import 'package:awady_music/data/sources/ytstream/stream_resolver_provider.dart';
import 'package:awady_music/features/search/search_screen.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:awady_music/widgets/artist_card.dart';
import 'package:awady_music/widgets/large_title_scaffold.dart';
import 'package:awady_music/widgets/media_card.dart';
import 'package:awady_music/widgets/track_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogRepository extends Mock implements CatalogRepository;

class MockStreamResolver extends Mock implements StreamResolver;

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
  required MockStreamResolver streamResolver,
  required FakePlayerController playerController,
  List<dynamic> overrides = const [],
  ThemeData? theme,
  Locale locale = const Locale('en'),
  TextDirection textDirection = TextDirection.ltr,
}) {
  return ProviderScope(
    overrides: [
      catalogRepositoryProvider.overrideWithValue(catalogRepo),
      streamResolverProvider.overrideWithValue(streamResolver),
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
        child: const Scaffold(body: SearchScreen()),
      ),
    ),
  );
}

void main() {
  const sampleTrack = Track(
    id: 't_s_1',
    title: 'Blinding Lights',
    artist: Artist(id: 'a_weeknd', name: 'The Weeknd'),
    duration: 200,
  );

  const sampleArtist = Artist(id: 'a_weeknd', name: 'The Weeknd');

  const samplePlaylist = RemotePlaylist(
    id: 'pl_after_hours',
    name: 'After Hours',
    owner: Artist(id: 'a_weeknd', name: 'The Weeknd'),
    trackCount: 14,
  );

  late MockCatalogRepository catalogRepo;
  late MockStreamResolver streamResolver;
  late FakePlayerController playerController;

  setUp(() {
    catalogRepo = MockCatalogRepository();
    streamResolver = MockStreamResolver();
    playerController = FakePlayerController();

    when(() => streamResolver.resolve(any<String>())).thenAnswer(
      (_) async => StreamInfo(
        url: Uri.parse('https://example.com/stream.m4a'),
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      ),
    );
  });

  group('SearchScreen widget tests', () {
    testWidgets('renders empty browse state with genres and moods', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildHarness(
          catalogRepo: catalogRepo,
          streamResolver: streamResolver,
          playerController: playerController,
          overrides: [
            moodCategoriesProvider.overrideWith(
              (ref) async => const [
                MoodCategory(name: 'Chill', params: 'chill_p'),
                MoodCategory(name: 'Workout', params: 'workout_p'),
              ],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LargeTitleScaffold), findsOneWidget);
      expect(find.text('Moods & moments'), findsOneWidget);
      expect(find.text('Chill'), findsOneWidget);
      expect(find.text('Workout'), findsOneWidget);
      expect(find.text('Browse genres'), findsOneWidget);
      expect(find.text('Electronic'), findsOneWidget);
      expect(find.text('Hip-Hop/Rap'), findsOneWidget);
    });

    testWidgets('typing debounces suggestions by 250ms and shows list', (
      tester,
    ) async {
      when(() => catalogRepo.suggest('week'))
          .thenAnswer((_) async => ['The Weeknd', 'Weekend', 'Weeknd hits']);

      await tester.pumpWidget(
        _buildHarness(
          catalogRepo: catalogRepo,
          streamResolver: streamResolver,
          playerController: playerController,
          overrides: [
            moodCategoriesProvider.overrideWith((ref) async => const []),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final input = find.byType(TextField);
      await tester.enterText(input, 'week');
      await tester.pump();

      // Before 250ms, suggestions are not yet loaded
      expect(find.text('The Weeknd'), findsNothing);

      // Advance clock past 250ms
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('The Weeknd'), findsOneWidget);
      expect(find.text('Weekend'), findsOneWidget);
    });

    testWidgets(
      'submitting search loads results with top card, songs, and carousels',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        const searchResults = SearchResults(
          top: sampleTrack,
          songs: [sampleTrack],
          artists: [sampleArtist],
          playlists: [samplePlaylist],
        );

        await tester.pumpWidget(
          _buildHarness(
            catalogRepo: catalogRepo,
            streamResolver: streamResolver,
            playerController: playerController,
            overrides: [
              searchProvider('Blinding Lights')
                  .overrideWith((ref) async => searchResults),
            ],
          ),
        );
        await tester.pump();

        // Submit search
        final input = find.byType(TextField);
        await tester.enterText(input, 'Blinding Lights');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();

        expect(find.text('All'), findsOneWidget);
        expect(find.text('Top result'), findsOneWidget);
        expect(find.text('Blinding Lights'), findsWidgets);
        expect(find.text('Songs'), findsOneWidget);
        expect(find.byType(TrackTile), findsOneWidget);
        expect(find.text('Artists'), findsOneWidget);
        expect(find.byType(ArtistCard), findsOneWidget);
        expect(find.text('Playlists & albums'), findsOneWidget);
        expect(find.byType(MediaCard), findsOneWidget);
      },
    );

    testWidgets('tapping track tile in search results plays track', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      const searchResults = SearchResults(
        top: sampleTrack,
        songs: [sampleTrack],
      );

      await tester.pumpWidget(
        _buildHarness(
          catalogRepo: catalogRepo,
          streamResolver: streamResolver,
          playerController: playerController,
          overrides: [
            searchProvider('Blinding')
                .overrideWith((ref) async => searchResults),
          ],
        ),
      );
      await tester.pump();

      final input = find.byType(TextField);
      await tester.enterText(input, 'Blinding');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TrackTile).first);
      await tester.pumpAndSettle();

      expect(playerController.playedTrack?.id, equals('t_s_1'));
    });

    testWidgets('filter chips filter results views', (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const searchResults = SearchResults(
        top: sampleTrack,
        songs: [sampleTrack],
        artists: [sampleArtist],
        playlists: [samplePlaylist],
      );

      await tester.pumpWidget(
        _buildHarness(
          catalogRepo: catalogRepo,
          streamResolver: streamResolver,
          playerController: playerController,
          overrides: [
            searchProvider('test').overrideWith((ref) async => searchResults),
          ],
        ),
      );
      await tester.pump();

      final input = find.byType(TextField);
      await tester.enterText(input, 'test');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // Tap Artists filter chip
      await tester.tap(find.text('Artists (1)'));
      await tester.pumpAndSettle();

      // Top result and Songs header should be hidden
      expect(find.text('Top result'), findsNothing);
      expect(find.byType(ArtistCard), findsOneWidget);

      // Tap Playlists filter chip
      await tester.tap(find.text('Playlists & albums (1)'));
      await tester.pumpAndSettle();

      expect(find.byType(MediaCard), findsOneWidget);
    });

    testWidgets('shows empty state when no results found', (tester) async {
      const emptyResults = SearchResults();

      await tester.pumpWidget(
        _buildHarness(
          catalogRepo: catalogRepo,
          streamResolver: streamResolver,
          playerController: playerController,
          overrides: [
            searchProvider('unknownxyz')
                .overrideWith((ref) async => emptyResults),
          ],
        ),
      );
      await tester.pump();

      final input = find.byType(TextField);
      await tester.enterText(input, 'unknownxyz');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('No results for “unknownxyz”'), findsOneWidget);
      expect(
        find.text(
          'Check your spelling or try searching for another '
          'song, artist, or album',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows error state and retry on network failure', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildHarness(
          catalogRepo: catalogRepo,
          streamResolver: streamResolver,
          playerController: playerController,
          overrides: [
            searchProvider(
              'fail',
            ).overrideWith((ref) => Future.error(Exception('Network error'))),
          ],
        ),
      );
      await tester.pump();

      final input = find.byType(TextField);
      await tester.enterText(input, 'fail');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('Search failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('clear button resets query back to browse view', (
      tester,
    ) async {
      when(() => catalogRepo.suggest('abc'))
          .thenAnswer((_) async => ['abc def']);

      await tester.pumpWidget(
        _buildHarness(
          catalogRepo: catalogRepo,
          streamResolver: streamResolver,
          playerController: playerController,
          overrides: [
            moodCategoriesProvider.overrideWith((ref) async => const []),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final input = find.byType(TextField);
      await tester.enterText(input, 'abc');
      await tester.pumpAndSettle();

      final clearBtn = find.byIcon(LucideIcons.x);
      expect(clearBtn, findsOneWidget);

      await tester.tap(clearBtn);
      await tester.pumpAndSettle();

      expect(find.text('Browse genres'), findsOneWidget);
    });

    testWidgets('Arabic locale and RTL rendering', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      const arTrack = Track(
        id: 't_ar_1',
        title: 'ألف ليلة وليلة',
        artist: Artist(id: 'a_k', name: 'أم كلثوم'),
        duration: 400,
      );

      const searchResults = SearchResults(top: arTrack, songs: [arTrack]);

      await tester.pumpWidget(
        _buildHarness(
          catalogRepo: catalogRepo,
          streamResolver: streamResolver,
          playerController: playerController,
          locale: const Locale('ar'),
          textDirection: TextDirection.rtl,
          overrides: [
            searchProvider('أم كلثوم')
                .overrideWith((ref) async => searchResults),
          ],
        ),
      );
      await tester.pump();

      final input = find.byType(TextField);
      await tester.enterText(input, 'أم كلثوم');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('ألف ليلة وليلة'), findsWidgets);
      expect(find.text('الأغاني'), findsWidgets);
    });
  });
}
