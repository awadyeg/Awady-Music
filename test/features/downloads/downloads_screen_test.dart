import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/downloads_repository.dart';
import 'package:awady_music/features/downloads/downloads_screen.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePlayerController extends PlayerController {
  final List<Track> playedTracks = [];

  @override
  PlayerState build() => const PlayerState();

  @override
  void playContext(List<Track> tracks, int index) {
    playedTracks.addAll(tracks);
  }
}

void main() {
  Widget buildTestWidget({
    List<Track> downloadedTracks = const [],
    Map<String, DownloadProgress> progressMap = const {},
  }) {
    return ProviderScope(
      overrides: [
        downloadedTracksProvider.overrideWith(
          (ref) => Stream.value(downloadedTracks),
        ),
        downloadProgressStreamProvider.overrideWith(
          (ref) => Stream.value(progressMap),
        ),
        playerControllerProvider.overrideWith(_FakePlayerController.new),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        home: const DownloadsScreen(),
      ),
    );
  }

  group('DownloadsScreen tests', () {
    testWidgets('renders empty state when no downloads', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('downloads_empty_title')), findsOneWidget);
      expect(find.byKey(const Key('downloads_empty_cta')), findsOneWidget);
    });

    testWidgets('renders downloaded tracks and Play all button', (
      tester,
    ) async {
      const sampleTracks = [
        Track(
          id: 'dl1',
          title: 'Offline Song 1',
          artist: Artist(id: 'a1', name: 'Singer A'),
          duration: 210,
        ),
        Track(
          id: 'dl2',
          title: 'Offline Song 2',
          artist: Artist(id: 'a2', name: 'Singer B'),
          duration: 185,
        ),
      ];

      await tester.pumpWidget(buildTestWidget(downloadedTracks: sampleTracks));
      await tester.pumpAndSettle();

      expect(find.text('Offline Song 1'), findsOneWidget);
      expect(find.text('Offline Song 2'), findsOneWidget);
      expect(find.byKey(const Key('downloads_play_all')), findsOneWidget);
    });
  });
}
