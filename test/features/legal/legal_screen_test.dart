import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/features/legal/legal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildHarness({
  LegalTab initialTab = LegalTab.disclaimer,
  ThemeData? theme,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    child: MaterialApp(
      theme: theme ?? AppTheme.dark(),
      locale: locale,
      home: LegalScreen(initialTab: initialTab),
    ),
  );
}

void main() {
  testWidgets(
    'Renders LegalScreen header, tabs, and initial disclaimer content',
    (tester) async {
      await tester.pumpWidget(_buildHarness());
      await tester.pumpAndSettle();

      expect(find.text('Legal & Licenses'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Disclaimer'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Terms'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Privacy'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Licenses'), findsOneWidget);

      // Initial tab is Disclaimer
      expect(find.text('What Awady Music is (and is not)'), findsOneWidget);
    },
  );

  testWidgets(
    'Switching tabs switches documents to Terms, Privacy, and Licenses',
    (tester) async {
      await tester.pumpWidget(_buildHarness());
      await tester.pumpAndSettle();

      // Tap Terms
      await tester.tap(find.text('Terms'));
      await tester.pumpAndSettle();
      expect(find.text('1. What the Software is'), findsOneWidget);

      // Tap Privacy
      await tester.tap(find.text('Privacy'));
      await tester.pumpAndSettle();
      expect(find.text('What stays on your device'), findsOneWidget);

      // Tap Licenses
      await tester.tap(find.text('Licenses'));
      await tester.pumpAndSettle();
      expect(find.text('Open Source Attribution'), findsOneWidget);
      expect(
        find.textContaining('Based on the open-source Freebify design'),
        findsOneWidget,
      );
    },
  );

  testWidgets('Renders RTL Arabic and Light theme cleanly without crashes', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildHarness(
        theme: AppTheme.light(),
        locale: const Locale('ar'),
        initialTab: LegalTab.privacy,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Legal & Licenses'), findsOneWidget);
    expect(find.text('What stays on your device'), findsOneWidget);
  });
}
