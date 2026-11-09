import 'package:awady_music/app.dart';
import 'package:awady_music/core/router/app_router.dart';
import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/features/artist/artist_screen.dart';
import 'package:awady_music/features/genre/genre_screen.dart';
import 'package:awady_music/features/home/home_screen.dart';
import 'package:awady_music/features/legal/legal_screen.dart';
import 'package:awady_music/features/library/library_screen.dart';
import 'package:awady_music/features/mood/mood_screen.dart';
import 'package:awady_music/features/now_playing/now_playing_screen.dart';
import 'package:awady_music/features/search/search_screen.dart';
import 'package:awady_music/features/settings/settings_screen.dart';
import 'package:awady_music/features/stats/stats_screen.dart';
import 'package:awady_music/widgets/glass_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App launches at /home and displays HomeScreen and GlassTabBar', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: AwadyMusicApp()));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(GlassTabBar), findsOneWidget);
  });

  testWidgets('Tapping tabs switches branch and preserves state', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: AwadyMusicApp()));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);

    // Tap Search tab
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);

    // Tap Library tab
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryScreen), findsOneWidget);

    // Tap Stats tab
    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.byType(StatsScreen), findsOneWidget);

    // Tap Home tab again
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Navigating to modal and shared routes displays placeholders', (
    tester,
  ) async {
    late WidgetRef testRef;

    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, child) {
            testRef = ref;
            return const AwadyMusicApp();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to /artist/adele-123
    testRef.read(appRouterProvider).go('/artist/adele-123');
    await tester.pumpAndSettle();
    expect(find.byType(ArtistScreen), findsOneWidget);

    // Navigate to /now-playing
    testRef.read(appRouterProvider).go('/now-playing');
    await tester.pumpAndSettle();
    expect(find.byType(NowPlayingScreen), findsOneWidget);

    // Navigate to /settings
    testRef.read(appRouterProvider).go('/settings');
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    // Navigate to /settings/legal
    testRef.read(appRouterProvider).go('/settings/legal');
    await tester.pumpAndSettle();
    expect(find.byType(LegalScreen), findsOneWidget);
  });

  testWidgets('Navigating to /search/mood and /search/genre resolves screens and keeps '
      'GlassTabBar mounted', (tester) async {
    late WidgetRef testRef;

    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, child) {
            testRef = ref;
            return const AwadyMusicApp();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to /search/genre/Pop
    testRef.read(appRouterProvider).go('/search/genre/Pop');
    await tester.pumpAndSettle();
    expect(find.byType(GenreScreen), findsOneWidget);
    expect(find.byType(GlassTabBar), findsOneWidget);

    // Navigate to /search/mood/...
    const moodPath =
        '/search/mood/custom%3A%F0%9F%87%AA%F0%9F%87%AC%20Egypt%20Hits%7Ctop%20music%20Egypt';
    testRef.read(appRouterProvider).go(moodPath);
    await tester.pumpAndSettle();
    expect(find.byType(MoodScreen), findsOneWidget);
    expect(find.byType(GlassTabBar), findsOneWidget);
  });

  testWidgets('SettingsProvider updates theme and locale', (tester) async {
    late WidgetRef testRef;

    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, child) {
            testRef = ref;
            return const AwadyMusicApp();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Change to Arabic locale
    await testRef.read(settingsProvider.notifier).setLocale(const Locale('ar'));
    await tester.pumpAndSettle();

    // Verify Arabic tab label "الرئيسية"
    expect(find.text('الرئيسية'), findsOneWidget);
  });
}
