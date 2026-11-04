import 'package:awady_music/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('L10n supports en, es, and ar locales', () {
    expect(L10n.supportedLocales, contains(const Locale('en')));
    expect(L10n.supportedLocales, contains(const Locale('es')));
    expect(L10n.supportedLocales, contains(const Locale('ar')));
  });

  testWidgets('L10n loads translations for en, es, and ar', (tester) async {
    for (final locale in [
      const Locale('en'),
      const Locale('es'),
      const Locale('ar'),
    ]) {
      late L10n l10n;
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: Builder(
            builder: (context) {
              l10n = L10n.of(context)!;
              return Text(l10n.homeGreetingMorning);
            },
          ),
        ),
      );

      expect(l10n.homeGreetingMorning.isNotEmpty, isTrue);
      expect(l10n.appOffline.isNotEmpty, isTrue);
      expect(l10n.nowPlaying.isNotEmpty, isTrue);
      expect(l10n.queueNowPlaying.isNotEmpty, isTrue);
    }
  });
}
