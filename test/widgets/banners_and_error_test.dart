import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/widgets/global_error_screen.dart';
import 'package:awady_music/widgets/offline_banner.dart';
import 'package:awady_music/widgets/update_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FakeOfflineNotifier extends OfflineNotifier {
  FakeOfflineNotifier({required this.initial});
  final bool initial;
  @override
  bool build() => initial;
}

class FakeUpdateNotifier extends UpdateNotifier {
  FakeUpdateNotifier({this.initial});
  final AppUpdateInfo? initial;
  @override
  AppUpdateInfo? build() => initial;
}

Widget _buildHarness({
  required Widget child,
  List<dynamic> overrides = const [],
  ThemeData? theme,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: overrides.cast(),
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
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('OfflineBanner', () {
    testWidgets('Renders nothing when online', (tester) async {
      await tester.pumpWidget(
        _buildHarness(
          child: const OfflineBanner(),
          overrides: [
            isOfflineProvider.overrideWith(
              () => FakeOfflineNotifier(initial: false),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.wifiOff), findsNothing);
    });

    testWidgets('Renders thin glass strip when offline', (tester) async {
      await tester.pumpWidget(
        _buildHarness(
          child: const OfflineBanner(),
          overrides: [
            isOfflineProvider.overrideWith(
              () => FakeOfflineNotifier(initial: true),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.wifiOff), findsOneWidget);
      expect(
        find.text('You are offline. Showing downloaded and cached music'),
        findsOneWidget,
      );
    });
  });

  group('UpdateBanner', () {
    testWidgets('Renders nothing when no update is present', (tester) async {
      await tester.pumpWidget(
        _buildHarness(
          child: const UpdateBanner(),
          overrides: [updateInfoProvider.overrideWith(FakeUpdateNotifier.new)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.arrowUpCircle), findsNothing);
    });

    testWidgets('Renders update info and dismiss button works', (tester) async {
      final container = ProviderContainer(
        overrides: [
          updateInfoProvider.overrideWith(
            () => FakeUpdateNotifier(
              initial: const AppUpdateInfo(
                version: '1.2.0',
                downloadUrl: 'https://example.com/app.apk',
                releaseNotes: 'Performance improvements',
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: [
              L10n.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(body: UpdateBanner()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Update available (v1.2.0)'), findsOneWidget);
      expect(find.text('Performance improvements'), findsOneWidget);
      expect(find.text('Download update'), findsOneWidget);

      // Dismiss
      await tester.tap(find.byIcon(LucideIcons.x));
      await tester.pumpAndSettle();
      expect(container.read(updateInfoProvider), isNull);
    });
  });

  group('GlobalErrorScreen', () {
    testWidgets('Renders error UI with reload button', (tester) async {
      var reloaded = false;

      await tester.pumpWidget(
        _buildHarness(
          child: GlobalErrorScreen(
            details: 'NetworkException: 500',
            onReload: () => reloaded = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.triangleAlert), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(
        find.text('An unexpected error occurred while loading this view.'),
        findsOneWidget,
      );
      expect(find.text('NetworkException: 500'), findsOneWidget);

      await tester.tap(find.text('Reload'));
      await tester.pumpAndSettle();
      expect(reloaded, isTrue);
    });

    testWidgets('Renders cleanly in Arabic RTL and Light theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildHarness(
          theme: AppTheme.light(),
          locale: const Locale('ar'),
          child: const GlobalErrorScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.triangleAlert), findsOneWidget);
      expect(find.text('حدث خطأ ما'), findsOneWidget);
    });
  });
}
