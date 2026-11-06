import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/lyrics.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/data/repositories/lyrics_repository.dart';
import 'package:awady_music/features/now_playing/now_playing_screen.dart';
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
  bool shuffleCalled = false;
  bool cycleRepeatCalled = false;
  Duration? seekCalled;

  @override
  PlayerState build() => _initial;

  @override
  Future<void> toggle() async {
    toggleCalled = true;
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  @override
  Future<void> next({bool auto = false}) async {
    nextCalled = true;
  }

  @override
  Future<void> prev() async {
    prevCalled = true;
  }

  @override
  void toggleShuffle() {
    shuffleCalled = true;
    state = state.copyWith(shuffle: !state.shuffle);
  }

  @override
  Future<void> cycleRepeat() async {
    cycleRepeatCalled = true;
    state = state.copyWith(
      repeat: switch (state.repeat) {
        RepeatMode.off => RepeatMode.all,
        RepeatMode.all => RepeatMode.one,
        RepeatMode.one => RepeatMode.off,
      },
    );
  }

  @override
  Future<void> seek(Duration position) async {
    seekCalled = position;
    state = state.copyWith(currentTime: position);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _buildHarness({
  required FakePlayerController playerController,
  required MockLibraryRepository libraryRepo,
  ThemeData? theme,
  Locale locale = const Locale('en'),
  TextDirection textDirection = TextDirection.ltr,
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
        child: const NowPlayingScreen(),
      ),
    ),
  );
}

void main() {
  const sampleTrack = Track(
    id: 't_now_1',
    title: 'Skyfall',
    artist: Artist(id: 'a_adele', name: 'Adele'),
    duration: 286,
  );

  late MockLibraryRepository libraryRepo;

  setUp(() {
    libraryRepo = MockLibraryRepository();
    when(() => libraryRepo.isLiked(any())).thenReturn(false);
  });

  group('NowPlayingScreen widget tests', () {
    testWidgets('shows empty state when no track is active', (tester) async {
      final fake = FakePlayerController();
      await tester.pumpWidget(
        _buildHarness(playerController: fake, libraryRepo: libraryRepo),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NowPlayingScreen), findsOneWidget);
      expect(find.text('Pick something to play'), findsOneWidget);
    });

    testWidgets('renders active track details and controls', (tester) async {
      final fake = FakePlayerController(
        initial: const PlayerState(
          queue: [sampleTrack],
          index: 0,
          currentTime: Duration(seconds: 45),
          duration: Duration(seconds: 286),
        ),
      );

      await tester.pumpWidget(
        _buildHarness(playerController: fake, libraryRepo: libraryRepo),
      );
      await tester.pumpAndSettle();

      expect(find.text('Skyfall'), findsOneWidget);
      expect(find.text('Adele'), findsOneWidget);
      expect(find.byIcon(LucideIcons.play), findsOneWidget);
      expect(find.byIcon(LucideIcons.skipBack), findsOneWidget);
      expect(find.byIcon(LucideIcons.skipForward), findsOneWidget);
      expect(find.byIcon(LucideIcons.shuffle), findsOneWidget);
      expect(find.byIcon(LucideIcons.repeat), findsOneWidget);
    });

    testWidgets('play/pause button toggles playback', (tester) async {
      final fake = FakePlayerController(
        initial: const PlayerState(queue: [sampleTrack], index: 0),
      );

      await tester.pumpWidget(
        _buildHarness(playerController: fake, libraryRepo: libraryRepo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.play));
      await tester.pumpAndSettle();

      expect(fake.toggleCalled, isTrue);
      expect(find.byIcon(LucideIcons.pause), findsOneWidget);
    });

    testWidgets('skip buttons trigger next and prev', (tester) async {
      final fake = FakePlayerController(
        initial: const PlayerState(queue: [sampleTrack], index: 0),
      );

      await tester.pumpWidget(
        _buildHarness(playerController: fake, libraryRepo: libraryRepo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.skipForward));
      await tester.pumpAndSettle();
      expect(fake.nextCalled, isTrue);

      await tester.tap(find.byIcon(LucideIcons.skipBack));
      await tester.pumpAndSettle();
      expect(fake.prevCalled, isTrue);
    });

    testWidgets('shuffle and repeat buttons trigger controller actions', (
      tester,
    ) async {
      final fake = FakePlayerController(
        initial: const PlayerState(queue: [sampleTrack], index: 0),
      );

      await tester.pumpWidget(
        _buildHarness(playerController: fake, libraryRepo: libraryRepo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.shuffle));
      await tester.pumpAndSettle();
      expect(fake.shuffleCalled, isTrue);

      await tester.tap(find.byIcon(LucideIcons.repeat));
      await tester.pumpAndSettle();
      expect(fake.cycleRepeatCalled, isTrue);
    });

    testWidgets('renders Arabic track in RTL layout', (tester) async {
      const arabicTrack = Track(
        id: 't_now_ar',
        title: 'ألف ليلة وليلة',
        artist: Artist(id: 'a_kalthoum', name: 'أم كلثوم'),
        duration: 360,
      );

      final fake = FakePlayerController(
        initial: const PlayerState(
          queue: [arabicTrack],
          index: 0,
          isPlaying: true,
          currentTime: Duration(seconds: 120),
          duration: Duration(seconds: 360),
        ),
      );

      await tester.pumpWidget(
        _buildHarness(
          playerController: fake,
          libraryRepo: libraryRepo,
          locale: const Locale('ar'),
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ألف ليلة وليلة'), findsOneWidget);
      expect(find.text('أم كلثوم'), findsOneWidget);
      expect(find.byIcon(LucideIcons.pause), findsOneWidget);
    });

    testWidgets(
      'lyrics toggle button toggles lyrics mode and shrunken header',
      (tester) async {
        final fake = FakePlayerController(
          initial: const PlayerState(
            queue: [sampleTrack],
            index: 0,
            isPlaying: true,
            duration: Duration(seconds: 286),
          ),
        );

        await tester.pumpWidget(
          _buildHarness(playerController: fake, libraryRepo: libraryRepo),
        );
        await tester.pumpAndSettle();

        // Lyrics toggle button exists
        final toggleFinder = find.byKey(const Key('now_playing_lyrics_toggle'));
        expect(toggleFinder, findsOneWidget);

        // Tap toggle to open lyrics
        await tester.tap(toggleFinder);
        await tester.pumpAndSettle();

        // In lyrics mode, lyrics view is present
        expect(find.byType(NowPlayingScreen), findsOneWidget);

        // Tap toggle again to return to big artwork mode
        await tester.tap(toggleFinder);
        await tester.pumpAndSettle();

        expect(find.byType(NowPlayingScreen), findsOneWidget);
      },
    );
  });
}
