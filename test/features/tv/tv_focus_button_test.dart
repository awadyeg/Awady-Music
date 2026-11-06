import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/features/tv/tv_focus_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildHarness({
    required VoidCallback onPressed,
    bool autofocus = true,
  }) {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: Center(
          child: TvFocusButton(
            autofocus: autofocus,
            onPressed: onPressed,
            child: const Text('TV Button'),
          ),
        ),
      ),
    );
  }

  testWidgets('TvFocusButton triggers onPressed on D-pad Center '
      '(LogicalKeyboardKey.select)', (tester) async {
    var pressed = false;
    await tester.pumpWidget(buildHarness(onPressed: () => pressed = true));
    await tester.pumpAndSettle();

    // Ensure button has primary focus
    expect(find.text('TV Button'), findsOneWidget);

    // Send D-pad center / Select key (Android TV remote center button)
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();

    expect(pressed, isTrue);
  });

  testWidgets('TvFocusButton triggers onPressed on Enter and NumpadEnter', (
    tester,
  ) async {
    var pressCount = 0;
    await tester.pumpWidget(buildHarness(onPressed: () => pressCount++));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(pressCount, equals(1));

    await tester.sendKeyEvent(LogicalKeyboardKey.numpadEnter);
    await tester.pumpAndSettle();
    expect(pressCount, equals(2));
  });

  testWidgets('TvFocusButton triggers onPressed on Space and GameButtonA', (
    tester,
  ) async {
    var pressCount = 0;
    await tester.pumpWidget(buildHarness(onPressed: () => pressCount++));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(pressCount, equals(1));

    await tester.sendKeyEvent(LogicalKeyboardKey.gameButtonA);
    await tester.pumpAndSettle();
    expect(pressCount, equals(2));
  });

  testWidgets('TvFocusButton triggers onPressed on tap', (tester) async {
    var pressed = false;
    await tester.pumpWidget(buildHarness(onPressed: () => pressed = true));
    await tester.pumpAndSettle();

    await tester.tap(find.text('TV Button'));
    await tester.pumpAndSettle();

    expect(pressed, isTrue);
  });
}
