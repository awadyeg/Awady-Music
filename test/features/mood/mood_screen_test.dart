import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/mood_models.dart';
import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/catalog_providers.dart';
import 'package:awady_music/features/mood/mood_screen.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:awady_music/widgets/large_title_scaffold.dart';
import 'package:awady_music/widgets/media_card.dart';
import 'package:awady_music/widgets/track_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakePlayerController extends Notifier<PlayerState>
    implements PlayerController {
  Track? playedTrack;
  List<Track>? playedContext;

  @override
  PlayerState build() => const PlayerState();

  @override
  void playTrack(Track track, [List<Track>? context]) {
    playedTrack = track;
    playedContext = context;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _buildHarness({
  required FakePlayerController playerController,
  required String params,
  String? name,
  List<dynamic> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      playerControllerProvider.overrideWith(() => playerController),
      ...overrides.cast(),
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
        body: MoodScreen(params: params, name: name),
      ),
    ),
  );
}

void main() {
  const sampleTrack = Track(
    id: 't_m_1',
    title: 'Weightless',
    artist: Artist(id: 'a_marconi', name: 'Marconi Union'),
    duration: 480,
  );

  const samplePlaylist = RemotePlaylist(
    id: 'pl_m_chill',
    name: 'Chill Vibes',
    owner: Artist(id: 'a_yt', name: 'YouTube Music'),
    trackCount: 30,
  );

  late FakePlayerController playerController;

  setUp(() {
    playerController = FakePlayerController();
  });

  group('MoodScreen widget tests', () {
    testWidgets('renders mood playlists carousel and top tracks', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const moodData = MoodPageData(
        name: 'Relax',
        playlists: [samplePlaylist],
        tracks: [sampleTrack],
      );

      await tester.pumpWidget(
        _buildHarness(
          playerController: playerController,
          params: 'p_relax',
          name: 'Relax',
          overrides: [
            moodPageProvider('p_relax').overrideWith((ref) async => moodData),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LargeTitleScaffold), findsOneWidget);
      expect(find.text('Relax'), findsWidgets);
      expect(find.text('Relax playlists'), findsOneWidget);
      expect(find.byType(MediaCard), findsOneWidget);
      expect(find.text('Chill Vibes'), findsOneWidget);
      expect(find.text('Top tracks'), findsOneWidget);
      expect(find.byType(TrackTile), findsOneWidget);
      expect(find.text('Weightless'), findsOneWidget);
    });

    testWidgets('tapping track in mood page calls playTrack', (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const moodData = MoodPageData(name: 'Focus', tracks: [sampleTrack]);

      await tester.pumpWidget(
        _buildHarness(
          playerController: playerController,
          params: 'p_focus',
          overrides: [
            moodPageProvider('p_focus').overrideWith((ref) async => moodData),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TrackTile).first);
      await tester.pumpAndSettle();

      expect(playerController.playedTrack?.id, equals('t_m_1'));
    });

    testWidgets('shows error state and retry button on load failure', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildHarness(
          playerController: playerController,
          params: 'p_fail',
          overrides: [
            moodPageProvider('p_fail').overrideWith(
              (ref) => Future.error(Exception('Failed to load mood')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Couldn't load this mood"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
