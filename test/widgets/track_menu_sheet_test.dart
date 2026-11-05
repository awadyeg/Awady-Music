import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/album_ref.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/local_playlist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:awady_music/widgets/track_menu_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLibraryRepository extends Mock implements LibraryRepository;

class FakePlayerController extends Notifier<PlayerState>
    implements PlayerController {
  Track? enqueuedTrack;
  Track? playNextTrack;
  Track? radioTrack;

  @override
  PlayerState build() => const PlayerState();

  @override
  void enqueue(Track track) {
    enqueuedTrack = track;
  }

  @override
  void playNextUp(Track track) {
    playNextTrack = track;
  }

  @override
  Future<void> startRadio([Track? track]) async {
    radioTrack = track;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _buildHarness({
  required Track track,
  required FakePlayerController playerController,
  required MockLibraryRepository libraryRepo,
  String? localPlaylistId,
  ThemeData? theme,
  Locale locale = const Locale('en'),
  TextDirection textDirection = TextDirection.ltr,
}) {
  return ProviderScope(
    overrides: [
      playerControllerProvider.overrideWith(() => playerController),
      libraryRepositoryProvider.overrideWithValue(libraryRepo),
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
        child: Scaffold(
          body: TrackMenuSheet(track: track, localPlaylistId: localPlaylistId),
        ),
      ),
    ),
  );
}

void main() {
  const sampleTrack = Track(
    id: 't_menu_1',
    title: 'Easy On Me',
    artist: Artist(id: 'a_adele', name: 'Adele'),
    album: AlbumRef(id: 'alb_30', name: '30'),
    duration: 224,
  );

  late MockLibraryRepository libraryRepo;
  late FakePlayerController playerController;

  setUpAll(() {
    registerFallbackValue(sampleTrack);
  });

  setUp(() {
    libraryRepo = MockLibraryRepository();
    playerController = FakePlayerController();
    when(() => libraryRepo.isLiked(any())).thenReturn(false);
    when(() => libraryRepo.playlists).thenReturn([
      LocalPlaylist(
        id: 'pl_favorites',
        name: 'My Favorites',
        tracks: const [sampleTrack],
        createdAt: DateTime(2026),
      ),
    ]);
    when(() => libraryRepo.addToPlaylist(any(), any())).thenReturn(null);
    when(() => libraryRepo.removeFromPlaylist(any(), any())).thenReturn(null);
    when(() => libraryRepo.toggleLike(any())).thenReturn(null);
  });

  group('TrackMenuSheet widget tests', () {
    testWidgets('renders track info and menu options', (tester) async {
      await tester.pumpWidget(
        _buildHarness(
          track: sampleTrack,
          playerController: playerController,
          libraryRepo: libraryRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Easy On Me'), findsOneWidget);
      expect(find.textContaining('Adele'), findsOneWidget);
      expect(find.text('Save to Liked Songs'), findsOneWidget);
      expect(find.text('Add to playlist'), findsOneWidget);
      expect(find.text('Add to queue'), findsOneWidget);
      expect(find.text('Play next'), findsOneWidget);
      expect(find.text('Start radio from this song'), findsOneWidget);
      expect(find.text('Go to artist'), findsOneWidget);
      expect(find.text('Go to album'), findsOneWidget);
      expect(find.text('Share track'), findsOneWidget);
    });

    testWidgets('shows remove from playlist when localPlaylistId is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildHarness(
          track: sampleTrack,
          playerController: playerController,
          libraryRepo: libraryRepo,
          localPlaylistId: 'pl_favorites',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Remove from playlist'), findsOneWidget);

      await tester.tap(find.text('Remove from playlist'));
      await tester.pumpAndSettle();

      verify(() => libraryRepo.removeFromPlaylist('pl_favorites', 't_menu_1'))
          .called(1);
    });

    testWidgets('tapping Add to queue triggers player enqueue', (tester) async {
      await tester.pumpWidget(
        _buildHarness(
          track: sampleTrack,
          playerController: playerController,
          libraryRepo: libraryRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add to queue'));
      await tester.pumpAndSettle();

      expect(playerController.enqueuedTrack?.id, equals('t_menu_1'));
    });

    testWidgets('tapping Play next triggers playNextUp', (tester) async {
      await tester.pumpWidget(
        _buildHarness(
          track: sampleTrack,
          playerController: playerController,
          libraryRepo: libraryRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Play next'));
      await tester.pumpAndSettle();

      expect(playerController.playNextTrack?.id, equals('t_menu_1'));
    });

    testWidgets('tapping Start radio triggers startRadio', (tester) async {
      await tester.pumpWidget(
        _buildHarness(
          track: sampleTrack,
          playerController: playerController,
          libraryRepo: libraryRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start radio from this song'));
      await tester.pumpAndSettle();

      expect(playerController.radioTrack?.id, equals('t_menu_1'));
    });

    testWidgets('tapping Like calls toggleLike', (tester) async {
      await tester.pumpWidget(
        _buildHarness(
          track: sampleTrack,
          playerController: playerController,
          libraryRepo: libraryRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save to Liked Songs'));
      await tester.pumpAndSettle();

      verify(() => libraryRepo.toggleLike(sampleTrack)).called(1);
    });

    testWidgets('tapping Add to playlist opens sub-sheet with user playlists', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildHarness(
          track: sampleTrack,
          playerController: playerController,
          libraryRepo: libraryRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add to playlist'));
      await tester.pumpAndSettle();

      expect(find.text('New playlist'), findsOneWidget);
      expect(find.text('My Favorites'), findsOneWidget);

      await tester.tap(find.text('My Favorites'));
      await tester.pumpAndSettle();

      verify(() => libraryRepo.addToPlaylist('pl_favorites', sampleTrack))
          .called(1);
    });

    testWidgets('renders Arabic track menu in RTL', (tester) async {
      const arTrack = Track(
        id: 't_ar_menu',
        title: 'حب إيه',
        artist: Artist(id: 'a_k', name: 'أم كلثوم'),
        duration: 320,
      );

      await tester.pumpWidget(
        _buildHarness(
          track: arTrack,
          playerController: playerController,
          libraryRepo: libraryRepo,
          locale: const Locale('ar'),
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('حب إيه'), findsOneWidget);
      expect(find.textContaining('أم كلثوم'), findsOneWidget);
    });
  });
}
