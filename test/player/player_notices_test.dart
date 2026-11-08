import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/player/player_notices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('player notice keys map to localized copy', (tester) async {
    late L10n l10n;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        home: Builder(
          builder: (context) {
            l10n = context.l10n;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(
      playerNoticeMessage(l10n, 'core.noConnection'),
      l10n.coreNoConnection,
    );
    expect(playerNoticeMessage(l10n, 'core.unavailable'), l10n.coreUnavailable);
    expect(playerNoticeMessage(l10n, 'table.radioFail'), l10n.tableRadioFail);
    expect(playerNoticeMessage(l10n, null), isNull);
    expect(playerNoticeMessage(l10n, ''), isNull);
    expect(playerNoticeMessage(l10n, 'Already localized'), 'Already localized');
  });
}
