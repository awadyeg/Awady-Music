import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:awady_music/widgets/mini_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
  Future<void> next({bool auto = false}) async {
    nextCalled = true;
  }

  @override
  Future<void> prev() async {
    prevCalled = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _buildHarness({
  required FakePlayerController controller,
  ThemeData? theme,
  Locale locale = const Locale('en'),
  TextDirection textDirection = TextDirection.ltr,
}) {
  return ProviderScope(
    overrides: [playerControllerProvider.overrideWith(() => controller)],
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
        child: const Scaffold(body: Center(child: MiniPlayer())),
      ),
    ),
  );
}

void main() {
  const sampleTrack = Track(
    id: 'test_1',
    title: 'Hello',
    artist: Artist(id: 'a1', name: 'Adele'),
    duration: 300,
  );

  group('MiniPlayer widget tests', () {
    testWidgets('renders empty when queue is empty', (tester) async {
      final fake = FakePlayerController();
      await tester.pumpWidget(_buildHarness(controller: fake));
      await tester.pumpAndSettle();

      expect(find.byType(MiniPlayer), findsOneWidget);
      expect(find.text('Hello'), findsNothing);
      expect(find.byIcon(LucideIcons.play), findsNothing);
    });

    testWidgets(
      'renders track title, artist, and buttons when track is active',
      (tester) async {
        final fake = FakePlayerController(
          initial: const PlayerState(
            queue: [sampleTrack],
            index: 0,
            currentTime: Duration(seconds: 60),
            duration: Duration(seconds: 300),
          ),
        );

        await tester.pumpWidget(_buildHarness(controller: fake));
        await tester.pumpAndSettle();

        expect(find.text('Hello'), findsOneWidget);
        expect(find.text('Adele'), findsOneWidget);
        expect(find.byIcon(LucideIcons.play), findsOneWidget);
        expect(find.byIcon(LucideIcons.skipForward), findsOneWidget);
      },
    );

    testWidgets('tapping play/pause triggers toggle()', (tester) async {
      final fake = FakePlayerController(
        initial: const PlayerState(queue: [sampleTrack], index: 0),
      );

      await tester.pumpWidget(_buildHarness(controller: fake));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.play));
      await tester.pumpAndSettle();

      expect(fake.toggleCalled, isTrue);
      expect(find.byIcon(LucideIcons.pause), findsOneWidget);
    });

    testWidgets('tapping next button triggers next()', (tester) async {
      final fake = FakePlayerController(
        initial: const PlayerState(
          queue: [sampleTrack],
          index: 0,
          isPlaying: true,
        ),
      );

      await tester.pumpWidget(_buildHarness(controller: fake));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.skipForward));
      await tester.pumpAndSettle();

      expect(fake.nextCalled, isTrue);
    });

    testWidgets('horizontal swipe left triggers next() in LTR', (tester) async {
      final fake = FakePlayerController(
        initial: const PlayerState(queue: [sampleTrack], index: 0),
      );

      await tester.pumpWidget(_buildHarness(controller: fake));
      await tester.pumpAndSettle();

      await tester.fling(find.byType(MiniPlayer), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();

      expect(fake.nextCalled, isTrue);
    });

    testWidgets('horizontal swipe right triggers prev() in LTR', (
      tester,
    ) async {
      final fake = FakePlayerController(
        initial: const PlayerState(queue: [sampleTrack], index: 0),
      );

      await tester.pumpWidget(_buildHarness(controller: fake));
      await tester.pumpAndSettle();

      await tester.fling(find.byType(MiniPlayer), const Offset(300, 0), 1000);
      await tester.pumpAndSettle();

      expect(fake.prevCalled, isTrue);
    });

    testWidgets('renders properly in RTL Arabic', (tester) async {
      const arabicTrack = Track(
        id: 'test_ar',
        title: 'أنت عمري',
        artist: Artist(id: 'a2', name: 'أم كلثوم'),
        duration: 300,
      );

      final fake = FakePlayerController(
        initial: const PlayerState(
          queue: [arabicTrack],
          index: 0,
          isPlaying: true,
        ),
      );

      await tester.pumpWidget(
        _buildHarness(
          controller: fake,
          locale: const Locale('ar'),
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('أنت عمري'), findsOneWidget);
      expect(find.text('أم كلثوم'), findsOneWidget);
      expect(find.byIcon(LucideIcons.pause), findsOneWidget);
    });
  });
}
