import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/features/queue/queue_screen.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLibraryRepository extends Mock implements LibraryRepository;

class FakePlayerController extends Notifier<PlayerState>
    implements PlayerController {
  FakePlayerController({PlayerState? initial})
    : _initial = initial ?? const PlayerState();

  final PlayerState _initial;
  bool autoplaySet = false;
  int? removedIndex;
  int? jumpedIndex;
  bool clearQueueCalled = false;

  @override
  PlayerState build() => _initial;

  @override
  void setAutoplay({required bool value}) {
    autoplaySet = true;
    state = state.copyWith(autoplay: value);
  }

  @override
  void removeAt(int i) {
    removedIndex = i;
    final newQueue = [...state.queue]..removeAt(i);
    state = state.copyWith(queue: newQueue);
  }

  @override
  void jumpTo(int index) {
    jumpedIndex = index;
    state = state.copyWith(index: index);
  }

  @override
  void clearQueue() {
    clearQueueCalled = true;
    state = state.copyWith(queue: [], index: -1);
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
        child: const QueueScreen(),
      ),
    ),
  );
}

void main() {
  const track1 = Track(
    id: 'q_1',
    title: 'Song One',
    artist: Artist(id: 'a_1', name: 'Artist One'),
    duration: 200,
  );
  const track2 = Track(
    id: 'q_2',
    title: 'Song Two',
    artist: Artist(id: 'a_2', name: 'Artist Two'),
    duration: 210,
  );
  const track3 = Track(
    id: 'q_3',
    title: 'Song Three',
    artist: Artist(id: 'a_3', name: 'Artist Three'),
    duration: 220,
  );

  late MockLibraryRepository libraryRepo;

  setUp(() {
    libraryRepo = MockLibraryRepository();
    when(() => libraryRepo.createPlaylist(any())).thenReturn('p_test_1');
    when(() => libraryRepo.addTracksToPlaylist(any(), any())).thenReturn(null);
  });

  group('QueueScreen widget tests', () {
    testWidgets('shows empty state when queue has no tracks', (tester) async {
      final fake = FakePlayerController();
      await tester.pumpWidget(
        _buildHarness(playerController: fake, libraryRepo: libraryRepo),
      );
      await tester.pumpAndSettle();

      expect(find.text('Queue is empty'), findsNWidgets(2));
      expect(find.byType(QueueScreen), findsOneWidget);
    });

    testWidgets('renders now playing and upcoming tracks', (tester) async {
      final fake = FakePlayerController(
        initial: const PlayerState(queue: [track1, track2, track3], index: 0),
      );

      await tester.pumpWidget(
        _buildHarness(playerController: fake, libraryRepo: libraryRepo),
      );
      await tester.pumpAndSettle();

      expect(find.text('Song One'), findsOneWidget);
      expect(find.text('Song Two'), findsOneWidget);
      expect(find.text('Song Three'), findsOneWidget);
      expect(find.text('Next up (2)'), findsOneWidget);
    });

    testWidgets('toggling autoplay calls setAutoplay', (tester) async {
      final fake = FakePlayerController(
        initial: const PlayerState(queue: [track1, track2], index: 0),
      );

      await tester.pumpWidget(
        _buildHarness(playerController: fake, libraryRepo: libraryRepo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(fake.autoplaySet, isTrue);
    });

    testWidgets('tapping save as playlist invokes library repo', (
      tester,
    ) async {
      final fake = FakePlayerController(
        initial: const PlayerState(queue: [track1, track2], index: 0),
      );

      await tester.pumpWidget(
        _buildHarness(playerController: fake, libraryRepo: libraryRepo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save queue as playlist'));
      await tester.pumpAndSettle();

      verify(() => libraryRepo.createPlaylist(any())).called(1);
      verify(() => libraryRepo.addTracksToPlaylist('p_test_1', any()))
          .called(1);
    });

    testWidgets('clear queue button opens dialog and confirms', (tester) async {
      final fake = FakePlayerController(
        initial: const PlayerState(queue: [track1, track2], index: 0),
      );

      await tester.pumpWidget(
        _buildHarness(playerController: fake, libraryRepo: libraryRepo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear queue'));
      await tester.pumpAndSettle();

      expect(find.text('Clear the entire playback queue?'), findsOneWidget);

      // Confirm in dialog
      await tester.tap(find.widgetWithText(TextButton, 'Clear queue'));
      await tester.pumpAndSettle();

      expect(fake.clearQueueCalled, isTrue);
    });

    testWidgets('renders Arabic queue in RTL', (tester) async {
      const arTrack1 = Track(
        id: 'qar_1',
        title: 'أنت عمري',
        artist: Artist(id: 'a_k', name: 'أم كلثوم'),
        duration: 300,
      );

      final fake = FakePlayerController(
        initial: const PlayerState(queue: [arTrack1], index: 0),
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

      expect(find.text('أنت عمري'), findsOneWidget);
      expect(find.textContaining('أم كلثوم'), findsOneWidget);
    });
  });
}
