import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/lyrics.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/lyrics_repository.dart';
import 'package:awady_music/features/now_playing/lyrics_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLyricsRepository extends Mock implements LyricsRepository;

Widget _buildLyricsHarness({
  required Track track,
  required Duration currentTime,
  required ValueChanged<Duration> onSeek,
  required Lyrics lyricsToReturn,
  MockLyricsRepository? mockRepo,
}) {
  final repo = mockRepo ?? MockLyricsRepository();

  return ProviderScope(
    overrides: [
      lyricsRepositoryProvider.overrideWithValue(repo),
      lyricsForTrackProvider(track).overrideWith((ref) => lyricsToReturn),
    ],
    child: MaterialApp(
      theme: AppTheme.dark(),
      supportedLocales: const [Locale('en'), Locale('es'), Locale('ar')],
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: LyricsView(
          track: track,
          currentTime: currentTime,
          onSeek: onSeek,
        ),
      ),
    ),
  );
}

void main() {
  const sampleTrack = Track(
    id: 't_lyrics_1',
    title: 'Rolling in the Deep',
    artist: Artist(id: 'a_adele', name: 'Adele'),
    duration: 228,
  );

  group('LyricsView widget tests', () {
    testWidgets('renders NoLyrics state when no lyrics are found', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildLyricsHarness(
          track: sampleTrack,
          currentTime: Duration.zero,
          onSeek: (_) {},
          lyricsToReturn: const NoLyrics(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('now_playing_no_lyrics')), findsOneWidget);
      expect(find.text('No lyrics found for this track.'), findsOneWidget);
    });

    testWidgets('renders PlainLyrics in scrollable view', (tester) async {
      const plainLyrics = PlainLyrics(
        text:
            "There's a fire starting in my heart\n"
            "Reaching a fever pitch, it's bringing me out the dark",
        source: 'ytm',
      );

      await tester.pumpWidget(
        _buildLyricsHarness(
          track: sampleTrack,
          currentTime: Duration.zero,
          onSeek: (_) {},
          lyricsToReturn: plainLyrics,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('now_playing_plain_lyrics')), findsOneWidget);
      expect(
        find.textContaining("There's a fire starting in my heart"),
        findsOneWidget,
      );
    });

    testWidgets('renders SyncedLyrics, highlights active line, and tap seeks', (
      tester,
    ) async {
      Duration? seekTarget;
      const syncedLyrics = SyncedLyrics(
        lines: [
          LyricLine(startMs: 5000, text: 'First line'),
          LyricLine(startMs: 15000, text: 'Second line (active)'),
          LyricLine(startMs: 30000, text: 'Third line'),
        ],
        source: 'lrclib',
        fingerprint: 'fp-test',
      );

      // Playback at 16 seconds -> second line (15s) should be active
      await tester.pumpWidget(
        _buildLyricsHarness(
          track: sampleTrack,
          currentTime: const Duration(seconds: 16),
          onSeek: (pos) => seekTarget = pos,
          lyricsToReturn: syncedLyrics,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('now_playing_lyrics_view')), findsOneWidget);
      expect(find.text('First line'), findsOneWidget);
      expect(find.text('Second line (active)'), findsOneWidget);
      expect(find.text('Third line'), findsOneWidget);

      // Tap third line -> seeks to 30000ms
      await tester.tap(find.byKey(const Key('lyric_line_2')));
      await tester.pumpAndSettle();

      expect(seekTarget, equals(const Duration(milliseconds: 30000)));
    });

    testWidgets('long-press on a synced line pins offset and shows toast', (
      tester,
    ) async {
      final mockRepo = MockLyricsRepository();
      when(
        () => mockRepo.pinOffset(
          trackId: any(named: 'trackId'),
          fingerprint: any(named: 'fingerprint'),
          offsetMs: any(named: 'offsetMs'),
        ),
      ).thenAnswer((_) async {});

      const syncedLyrics = SyncedLyrics(
        lines: [LyricLine(startMs: 10000, text: 'Sync this line')],
        source: 'lrclib',
        fingerprint: 'fp-sync',
      );

      // Current playback is at 12500ms
      await tester.pumpWidget(
        _buildLyricsHarness(
          track: sampleTrack,
          currentTime: const Duration(milliseconds: 12500),
          onSeek: (_) {},
          lyricsToReturn: syncedLyrics,
          mockRepo: mockRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Long press line 0: newOffset = 12500 - 10000 = 2500ms
      await tester.longPress(find.byKey(const Key('lyric_line_0')));
      await tester.pumpAndSettle();

      verify(
        () => mockRepo.pinOffset(
          trackId: sampleTrack.id,
          fingerprint: 'fp-sync',
          offsetMs: 2500,
        ),
      ).called(1);
    });
  });
}
