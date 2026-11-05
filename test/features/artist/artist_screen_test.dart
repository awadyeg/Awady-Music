import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/artist_page.dart';
import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/catalog_providers.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/features/artist/artist_screen.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:awady_music/widgets/media_card.dart';
import 'package:awady_music/widgets/track_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';

class MockLibraryRepository extends Mock implements LibraryRepository;

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
  required MockLibraryRepository libraryRepo,
  required FakePlayerController playerController,
  required String artistId,
  List<dynamic> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      libraryRepositoryProvider.overrideWithValue(libraryRepo),
      playerControllerProvider.overrideWith(() => playerController),
      ...overrides.cast(),
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
      home: Scaffold(body: ArtistScreen(id: artistId)),
    ),
  );
}

void main() {
  const sampleArtist = Artist(
    id: 'yt-adele',
    name: 'Adele',
    isVerified: true,
    followerCount: 52000000,
  );

  const sampleTrack = Track(
    id: 't_a_1',
    title: 'Hello',
    artist: sampleArtist,
    duration: 295,
  );

  const sampleAlbum = RemotePlaylist(
    id: 'pl_25',
    name: '25',
    owner: sampleArtist,
    trackCount: 11,
  );

  const sampleSingle = RemotePlaylist(
    id: 'pl_easy',
    name: 'Easy On Me',
    owner: sampleArtist,
    trackCount: 1,
  );

  late MockLibraryRepository libraryRepo;
  late FakePlayerController playerController;

  setUp(() {
    libraryRepo = MockLibraryRepository();
    playerController = FakePlayerController();

    when(() => libraryRepo.isFollowing('yt-adele')).thenReturn(false);
  });

  group('ArtistScreen widget tests', () {
    testWidgets('renders stretchy header, details, and sections', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const artistPage = ArtistPage(
        artist: sampleArtist,
        topSongs: [sampleTrack],
        albums: [sampleAlbum],
        singles: [sampleSingle],
        bio:
            'Adele Laurie Blue Adkins MBE is an English singer-songwriter. '
            'She is one of the best-selling music artists in the world, '
            'having sold over 120 million records worldwide.',
      );

      await tester.pumpWidget(
        _buildHarness(
          libraryRepo: libraryRepo,
          playerController: playerController,
          artistId: 'yt-adele',
          overrides: [
            artistPageProvider('yt-adele')
                .overrideWith((ref) async => artistPage),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Adele'), findsOneWidget);
      expect(find.text('Verified artist'), findsOneWidget);
      expect(find.byIcon(LucideIcons.badgeCheck), findsOneWidget);
      expect(find.text('52.0M monthly listeners'), findsOneWidget);

      // Buttons
      expect(find.widgetWithText(ElevatedButton, 'Play'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Shuffle'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Follow'), findsOneWidget);

      // Sections
      expect(find.text('Popular'), findsOneWidget);
      expect(find.byType(TrackTile), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('Albums'), findsOneWidget);
      expect(find.text('Singles & EPs'), findsOneWidget);
      expect(find.byType(MediaCard), findsNWidgets(2));
      expect(find.text('25'), findsOneWidget);
      expect(find.text('Easy On Me'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      expect(find.textContaining('Adele Laurie Blue Adkins'), findsOneWidget);
    });

    testWidgets('tapping Follow toggles follow state via LibraryRepository', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const artistPage = ArtistPage(
        artist: sampleArtist,
        topSongs: [sampleTrack],
      );

      await tester.pumpWidget(
        _buildHarness(
          libraryRepo: libraryRepo,
          playerController: playerController,
          artistId: 'yt-adele',
          overrides: [
            artistPageProvider('yt-adele')
                .overrideWith((ref) async => artistPage),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final followBtn = find.widgetWithText(OutlinedButton, 'Follow');
      await tester.tap(followBtn);
      await tester.pumpAndSettle();

      verify(() => libraryRepo.toggleFollow(sampleArtist)).called(1);
    });

    testWidgets('tapping Play button plays top tracks', (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const artistPage = ArtistPage(
        artist: sampleArtist,
        topSongs: [sampleTrack],
      );

      await tester.pumpWidget(
        _buildHarness(
          libraryRepo: libraryRepo,
          playerController: playerController,
          artistId: 'yt-adele',
          overrides: [
            artistPageProvider('yt-adele')
                .overrideWith((ref) async => artistPage),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final playBtn = find.widgetWithText(ElevatedButton, 'Play');
      await tester.tap(playBtn);
      await tester.pumpAndSettle();

      expect(playerController.playedTrack?.id, equals('t_a_1'));
      expect(playerController.playedContext?.length, equals(1));
    });

    testWidgets('shows not found error view when artist fails to load', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildHarness(
          libraryRepo: libraryRepo,
          playerController: playerController,
          artistId: 'yt-nonexistent',
          overrides: [
            artistPageProvider('yt-nonexistent').overrideWith(
              (ref) => Future.error(Exception('Artist not found')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Artist not found'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
