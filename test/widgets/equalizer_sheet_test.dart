import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:awady_music/widgets/equalizer_sheet.dart';
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
  String? lastPreset;
  int? lastBandIndex;
  double? lastBandGain;
  bool? lastNormOn;
  int? lastFadeSecs;

  @override
  PlayerState build() => _initial;

  @override
  void setEqPreset(String presetKey) {
    lastPreset = presetKey;
  }

  @override
  void setEqBand(int index, double gainDb) {
    lastBandIndex = index;
    lastBandGain = gainDb;
  }

  @override
  void setNormOn({required bool value}) {
    lastNormOn = value;
  }

  @override
  void setFadeSecs(int secs) {
    lastFadeSecs = secs;
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
      home: const Scaffold(body: EqualizerSheet()),
    ),
  );
}

void main() {
  testWidgets('Renders all EQ controls, presets, sliders, and switches', (
    tester,
  ) async {
    final controller = FakePlayerController();
    await tester.pumpWidget(_buildHarness(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Equalizer'), findsOneWidget);
    expect(find.text('Flat'), findsOneWidget);
    expect(find.text('Bass boost'), findsOneWidget);
    expect(find.text('Bright'), findsOneWidget);
    expect(find.text('Vocal boost'), findsOneWidget);
    expect(find.text('V-Shape'), findsOneWidget);

    // 7 band labels
    expect(find.text('60'), findsOneWidget);
    expect(find.text('250'), findsOneWidget);
    expect(find.text('500'), findsOneWidget);
    expect(find.text('1K'), findsOneWidget);
    expect(find.text('4K'), findsOneWidget);
    expect(find.text('8K'), findsOneWidget);
    expect(find.text('14K'), findsOneWidget);

    // Normalize and crossfade
    expect(find.text('Normalize volume'), findsOneWidget);
    expect(find.text('Crossfade'), findsOneWidget);
  });

  testWidgets('Tapping preset chip calls setEqPreset', (tester) async {
    final controller = FakePlayerController();
    await tester.pumpWidget(_buildHarness(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bass boost'));
    await tester.pump();

    expect(controller.lastPreset, equals('bass'));
  });

  testWidgets('Tapping reset button calls setEqPreset(flat)', (tester) async {
    final controller = FakePlayerController();
    await tester.pumpWidget(_buildHarness(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.rotateCcw));
    await tester.pump();

    expect(controller.lastPreset, equals('flat'));
  });

  testWidgets('Toggling normalize volume calls setNormOn', (tester) async {
    final controller = FakePlayerController();
    await tester.pumpWidget(_buildHarness(controller: controller));
    await tester.pumpAndSettle();

    // Find the second Switch in the sheet (1st: EQ enable, 2nd: Normalize)
    final switches = find.byType(Switch);
    expect(switches, findsNWidgets(2));

    await tester.tap(switches.at(1));
    await tester.pump();

    expect(controller.lastNormOn, isFalse);
  });

  testWidgets('Renders Arabic RTL and Light theme cleanly', (tester) async {
    final controller = FakePlayerController();
    await tester.pumpWidget(
      _buildHarness(
        controller: controller,
        theme: AppTheme.light(),
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(LucideIcons.sliders), findsOneWidget);
  });
}
