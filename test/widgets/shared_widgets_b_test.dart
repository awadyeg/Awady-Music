import 'package:alchemist/alchemist.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/widgets/artist_card.dart';
import 'package:awady_music/widgets/collage_cover.dart';
import 'package:awady_music/widgets/glass_sheet.dart';
import 'package:awady_music/widgets/glass_slider.dart';
import 'package:awady_music/widgets/media_card.dart';
import 'package:awady_music/widgets/section_header.dart';
import 'package:awady_music/widgets/track_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildTrackTileHarness({
  required ThemeData theme,
  required TextDirection textDirection,
  required String title,
  required String artist,
  bool isPlaying = false,
  bool isPending = false,
  bool isDownloaded = false,
  int? duration = 215,
}) {
  return Theme(
    data: theme,
    child: Directionality(
      textDirection: textDirection,
      child: ProviderScope(
        child: Container(
          width: 360,
          color: theme.scaffoldBackgroundColor,
          child: Material(
            color: Colors.transparent,
            child: TrackTile(
              title: title,
              artist: artist,
              duration: duration,
              isPlaying: isPlaying,
              isPending: isPending,
              isDownloaded: isDownloaded,
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> main() async {
  group('TrackTile widget tests', () {
    testWidgets('renders title, artist, and duration', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: const Scaffold(
              body: TrackTile(
                title: 'Rolling in the Deep',
                artist: 'Adele',
                duration: 228,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Rolling in the Deep'), findsOneWidget);
      expect(find.text('Adele · 3:48'), findsOneWidget);
    });

    testWidgets('shows spinner when isPending is true', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: const Scaffold(
              body: TrackTile(
                title: 'Pending Song',
                artist: 'Artist',
                isPending: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('GlassSlider widget tests', () {
    testWidgets('renders elapsed and remaining labels and handles drags', (
      tester,
    ) async {
      double? scrubbed;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: Scaffold(
              body: SizedBox(
                width: 300,
                child: GlassSlider(
                  value: 60,
                  max: 200,
                  onChanged: (v) => scrubbed = v,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('1:00'), findsOneWidget);
      expect(find.text('-2:20'), findsOneWidget);

      await tester.drag(find.byType(GlassSlider), const Offset(50, 0));
      await tester.pumpAndSettle();
      expect(scrubbed, isNotNull);
    });
  });

  group('SectionHeader widget tests', () {
    testWidgets('renders title and triggers action', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: SectionHeader(
              title: 'Trending',
              actionLabel: 'See all',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Trending'), findsOneWidget);
      expect(find.text('See all'), findsOneWidget);
      await tester.tap(find.text('See all'));
      expect(tapped, isTrue);
    });
  });

  group('Shared widgets smoke tests', () {
    testWidgets('MediaCard, ArtistCard, CollageCover render properly', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    MediaCard(title: 'Album Title', subtitle: 'Album Subtitle'),
                    ArtistCard(name: 'Adele', isVerified: true),
                    CollageCover(artworks: []),
                    GlassSheet(child: Text('Sheet content')),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Album Title'), findsOneWidget);
      expect(find.text('Adele'), findsOneWidget);
      expect(find.text('Sheet content'), findsOneWidget);
    });
  });

  await goldenTest(
    'TrackTile states across dark, light, and RTL',
    fileName: 'track_tile_states',
    pumpBeforeTest: pumpOnce,
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'dark_normal',
          child: _buildTrackTileHarness(
            theme: AppTheme.dark(),
            textDirection: TextDirection.ltr,
            title: 'Rolling in the Deep',
            artist: 'Adele',
            duration: 228,
          ),
        ),
        GoldenTestScenario(
          name: 'dark_playing',
          child: _buildTrackTileHarness(
            theme: AppTheme.dark(),
            textDirection: TextDirection.ltr,
            title: 'Someone Like You',
            artist: 'Adele',
            isPlaying: true,
            duration: 285,
          ),
        ),
        GoldenTestScenario(
          name: 'dark_pending',
          child: _buildTrackTileHarness(
            theme: AppTheme.dark(),
            textDirection: TextDirection.ltr,
            title: 'Importing track...',
            artist: 'Unknown Artist',
            isPending: true,
          ),
        ),
        GoldenTestScenario(
          name: 'dark_downloaded',
          child: _buildTrackTileHarness(
            theme: AppTheme.dark(),
            textDirection: TextDirection.ltr,
            title: 'Easy On Me',
            artist: 'Adele',
            isDownloaded: true,
            duration: 224,
          ),
        ),
        GoldenTestScenario(
          name: 'light_normal',
          child: _buildTrackTileHarness(
            theme: AppTheme.light(),
            textDirection: TextDirection.ltr,
            title: 'Rolling in the Deep',
            artist: 'Adele',
            duration: 228,
          ),
        ),
        GoldenTestScenario(
          name: 'light_playing',
          child: _buildTrackTileHarness(
            theme: AppTheme.light(),
            textDirection: TextDirection.ltr,
            title: 'Someone Like You',
            artist: 'Adele',
            isPlaying: true,
            duration: 285,
          ),
        ),
        GoldenTestScenario(
          name: 'rtl_arabic_playing',
          child: _buildTrackTileHarness(
            theme: AppTheme.dark(),
            textDirection: TextDirection.rtl,
            title: 'أغنية جميلة',
            artist: 'فنان مميز',
            isPlaying: true,
            duration: 210,
          ),
        ),
        GoldenTestScenario(
          name: 'rtl_arabic_downloaded',
          child: _buildTrackTileHarness(
            theme: AppTheme.dark(),
            textDirection: TextDirection.rtl,
            title: 'أغنية محملة',
            artist: 'عمرو دياب',
            isDownloaded: true,
            duration: 195,
          ),
        ),
      ],
    ),
  );
}
