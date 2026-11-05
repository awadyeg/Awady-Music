import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:awady_music/widgets/sleep_timer_sheet.dart';
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
  int? lastSetMins;
  Duration? lastSetDuration;

  @override
  PlayerState build() => _initial;

  @override
  void setSleepTimer(int? mins) {
    lastSetMins = mins;
  }

  @override
  void setSleepTimerDuration(Duration? duration) {
    lastSetDuration = duration;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _buildHarness({
  required FakePlayerController controller,
  ThemeData? theme,
  Locale locale = const Locale('en'),
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
      home: const Scaffold(body: SleepTimerSheet()),
    ),
  );
}

void main() {
  testWidgets('Renders all options with Off as default', (tester) async {
    final controller = FakePlayerController();
    await tester.pumpWidget(_buildHarness(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Sleep timer'), findsOneWidget);
    expect(find.text('Off'), findsNWidgets(2)); // in header and option
    expect(find.text('5 minutes'), findsOneWidget);
    expect(find.text('15 minutes'), findsOneWidget);
    expect(find.text('30 minutes'), findsOneWidget);
    expect(find.text('45 minutes'), findsOneWidget);
    expect(find.text('60 minutes'), findsOneWidget);
    expect(find.text('End of current track'), findsOneWidget);
    expect(find.byIcon(LucideIcons.check), findsOneWidget);
  });

  testWidgets('Shows remaining time and selected checkmark when active', (
    tester,
  ) async {
    final sleepAt = DateTime.now().add(const Duration(minutes: 30));
    final controller = FakePlayerController(
      initial: PlayerState(sleepAt: sleepAt),
    );

    await tester.pumpWidget(_buildHarness(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('in 30 min'), findsOneWidget);
    expect(find.byIcon(LucideIcons.check), findsOneWidget);
  });

  testWidgets('Tapping 15 minutes calls setSleepTimer(15)', (tester) async {
    final controller = FakePlayerController();
    await tester.pumpWidget(_buildHarness(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('15 minutes'));
    await tester.pump();

    expect(controller.lastSetMins, equals(15));
  });

  testWidgets('Tapping End of current track calls setSleepTimerDuration', (
    tester,
  ) async {
    final controller = FakePlayerController(
      initial: const PlayerState(
        currentTime: Duration(seconds: 30),
        duration: Duration(seconds: 180),
      ),
    );
    await tester.pumpWidget(_buildHarness(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('End of current track'));
    await tester.pump();

    expect(controller.lastSetDuration, equals(const Duration(seconds: 150)));
  });

  testWidgets('Renders in Arabic RTL and Light theme cleanly', (tester) async {
    final controller = FakePlayerController();
    await tester.pumpWidget(
      _buildHarness(
        controller: controller,
        theme: AppTheme.light(),
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(LucideIcons.timer), findsOneWidget);
  });
}
