import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/widgets/cast_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'CastSheet renders header and IP button without System Cast & Media Output',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: const Scaffold(body: CastSheetContent()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cast / Media Output'), findsOneWidget);
      expect(find.text('Connect via IP Address'), findsOneWidget);
      expect(find.text('System Cast & Media Output'), findsNothing);
    },
  );
}
