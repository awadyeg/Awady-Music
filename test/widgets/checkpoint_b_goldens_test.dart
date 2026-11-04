import 'package:alchemist/alchemist.dart';
import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/widgets/artist_card.dart';
import 'package:awady_music/widgets/glass_tab_bar.dart';
import 'package:awady_music/widgets/media_card.dart';
import 'package:awady_music/widgets/track_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildCheckpointBView({
  required ThemeData theme,
  required Locale locale,
}) {
  return SizedBox(
    width: 390,
    height: 720,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      locale: locale,
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      home: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              // TrackTile normal
              const TrackTile(
                title: 'Rolling in the Deep',
                artist: 'Adele',
                duration: 228,
              ),
              // TrackTile playing
              const TrackTile(
                title: 'Someone Like You',
                artist: 'Adele',
                duration: 285,
                isPlaying: true,
              ),
              // TrackTile pending
              const TrackTile(
                title: 'Set Fire to the Rain',
                artist: 'Adele',
                isPending: true,
              ),
              const SizedBox(height: 16),
              // Cards row
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MediaCard(
                      title: '21 (Deluxe)',
                      subtitle: 'Adele · Album',
                      size: 130,
                    ),
                    ArtistCard(
                      name: 'Adele',
                      subtitle: '54M monthly listeners',
                      isVerified: true,
                      size: 130,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Glass tab bar
              GlassTabBar(currentIndex: 0, onTap: (_) {}),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> main() async {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  await goldenTest(
    'Checkpoint B design system preview',
    fileName: 'checkpoint_b_preview',
    pumpBeforeTest: pumpOnce,
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'dark_en',
          child: ProviderScope(
            child: _buildCheckpointBView(
              theme: AppTheme.dark(),
              locale: const Locale('en'),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'light_en',
          child: ProviderScope(
            child: _buildCheckpointBView(
              theme: AppTheme.light(),
              locale: const Locale('en'),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'dark_ar',
          child: ProviderScope(
            child: _buildCheckpointBView(
              theme: AppTheme.dark(),
              locale: const Locale('ar'),
            ),
          ),
        ),
      ],
    ),
  );
}
