import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/artwork.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/local_playlist.dart';
import 'package:awady_music/data/models/playlist_page.dart';
import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/catalog_providers.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/features/playlist/playlist_screen.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';

class MockLibraryRepository extends Mock implements LibraryRepository;

class FakePlayerController extends Notifier<PlayerState>
    implements PlayerController {
  List<Track>? playedContext;
  int? playedIndex;

  @override
  PlayerState build() => const PlayerState();

  @override
  void playContext(List<Track> tracks, int index) {
    playedContext = tracks;
    playedIndex = index;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _buildHarness({
  required MockLibraryRepository libraryRepo,
  required FakePlayerController playerController,
  required String playlistId,
  PlaylistKind? kind,
  List<dynamic> overrides = const [],
  ThemeData? theme,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: [
      libraryRepositoryProvider.overrideWithValue(libraryRepo),
      playerControllerProvider.overrideWith(() => playerController),
      ...overrides.cast(),
    ],
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
      home: Scaffold(
        body: PlaylistScreen(id: playlistId, kind: kind),
      ),
    ),
  );
}

void main() {
  const sampleArtist = Artist(id: 'art-1', name: 'Awady Artist');
  const sampleTrack1 = Track(
    id: 'tr-1',
    title: 'Track One',
    artist: sampleArtist,
    duration: 180,
    source: TrackSource.yt,
    artwork: Artwork(s150: 'https://example.com/art1.jpg'),
  );
  const sampleTrack2 = Track(
    id: 'tr-2',
    title: 'Track Two',
    artist: sampleArtist,
    duration: 240,
    source: TrackSource.yt,
    artwork: Artwork(s150: 'https://example.com/art2.jpg'),
  );

  final sampleLocalPlaylist = LocalPlaylist(
    id: 'local-123',
    name: 'My Road Trip',
    tracks: const [sampleTrack1, sampleTrack2],
    createdAt: DateTime(2026),
  );

  late MockLibraryRepository libraryRepo;
  late FakePlayerController playerController;

  setUpAll(() {
    registerFallbackValue(PlaylistSortMode.title);
  });

  setUp(() {
    libraryRepo = MockLibraryRepository();
    playerController = FakePlayerController();

    when(() => libraryRepo.getPlaylist(any())).thenReturn(null);
    when(() => libraryRepo.getPlaylist('local-123'))
        .thenReturn(sampleLocalPlaylist);
    when(() => libraryRepo.likedTracks).thenReturn([sampleTrack1]);
    when(() => libraryRepo.recents).thenReturn([sampleTrack2]);
    when(() => libraryRepo.playlists).thenReturn([sampleLocalPlaylist]);
    when(() => libraryRepo.sortPlaylist(any(), any())).thenReturn(null);
    when(() => libraryRepo.renamePlaylist(any(), any())).thenReturn(null);
    when(() => libraryRepo.deletePlaylist(any())).thenReturn(null);
    when(() => libraryRepo.moveInPlaylist(any(), any(), any()))
        .thenReturn(null);
    when(() => libraryRepo.createPlaylist(any())).thenReturn('local-new');
    when(() => libraryRepo.addTracksToPlaylist(any(), any())).thenReturn(null);
    when(() => libraryRepo.isLiked(any())).thenReturn(false);
  });

  testWidgets('Renders local playlist with tracks, header, and plays on tap', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _buildHarness(
        libraryRepo: libraryRepo,
        playerController: playerController,
        playlistId: 'local-123',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Road Trip'), findsWidgets);
    expect(find.text('Track One'), findsOneWidget);
    expect(find.text('Track Two'), findsOneWidget);

    // Tap Play button
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    expect(playerController.playedContext?.length, 2);
    expect(playerController.playedIndex, 0);

    // Tap Shuffle button
    await tester.tap(find.byIcon(LucideIcons.shuffle));
    await tester.pumpAndSettle();
    expect(playerController.playedContext?.length, 2);

    // Tap individual track
    await tester.tap(find.text('Track Two'));
    await tester.pumpAndSettle();
    expect(playerController.playedIndex, 1);
  });

  testWidgets('Toggles edit mode and allows reordering', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _buildHarness(
        libraryRepo: libraryRepo,
        playerController: playerController,
        playlistId: 'local-123',
      ),
    );
    await tester.pumpAndSettle();

    // Tap edit button
    await tester.tap(find.byIcon(LucideIcons.pencil));
    await tester.pumpAndSettle();

    expect(find.byIcon(LucideIcons.gripVertical), findsNWidgets(2));
    expect(find.byIcon(LucideIcons.check), findsOneWidget);
  });

  testWidgets('More menu actions: Rename, Sort, Delete for local playlist', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _buildHarness(
        libraryRepo: libraryRepo,
        playerController: playerController,
        playlistId: 'local-123',
      ),
    );
    await tester.pumpAndSettle();

    // Open More menu
    await tester.tap(find.byIcon(LucideIcons.ellipsis).first);
    await tester.pumpAndSettle();

    expect(find.text('Rename'), findsOneWidget);
    expect(find.text('Sort'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    // Tap Sort
    await tester.tap(find.text('Sort'));
    await tester.pumpAndSettle();

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Artist'), findsOneWidget);
    expect(find.text('Length'), findsOneWidget);

    await tester.tap(find.text('Title'));
    await tester.pumpAndSettle();
    verify(() => libraryRepo.sortPlaylist('local-123', PlaylistSortMode.title))
        .called(1);
  });

  testWidgets('Renders empty local playlist with Find songs CTA', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final emptyPlaylist = LocalPlaylist(
      id: 'local-empty',
      name: 'Empty Jams',
      tracks: const [],
      createdAt: DateTime(2026),
    );
    when(() => libraryRepo.getPlaylist('local-empty'))
        .thenReturn(emptyPlaylist);

    await tester.pumpWidget(
      _buildHarness(
        libraryRepo: libraryRepo,
        playerController: playerController,
        playlistId: 'local-empty',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Songs you add will live here'), findsOneWidget);
    expect(find.text('Find songs'), findsOneWidget);
  });

  testWidgets('Renders Liked Songs and Recent tracks', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Liked songs
    await tester.pumpWidget(
      _buildHarness(
        libraryRepo: libraryRepo,
        playerController: playerController,
        playlistId: 'liked',
        kind: PlaylistKind.liked,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Liked Songs'), findsWidgets);
    expect(find.text('Track One'), findsOneWidget);

    // Recent tracks
    await tester.pumpWidget(
      _buildHarness(
        libraryRepo: libraryRepo,
        playerController: playerController,
        playlistId: 'recent',
        kind: PlaylistKind.recent,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recently played'), findsWidgets);
    expect(find.text('Track Two'), findsOneWidget);
  });

  testWidgets(
    'Renders Remote playlist from provider and handles Save to Library',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const remotePlaylist = RemotePlaylist(
        id: 'ytpl-123',
        name: 'Chill Vibes Remote',
        owner: Artist(id: 'yt-curator', name: 'Awady Curator'),
      );
      const remotePage = PlaylistPage(
        playlist: remotePlaylist,
        tracks: [sampleTrack1, sampleTrack2],
      );

      await tester.pumpWidget(
        _buildHarness(
          libraryRepo: libraryRepo,
          playerController: playerController,
          playlistId: 'ytpl-123',
          kind: PlaylistKind.remote,
          overrides: [
            playlistPageProvider('ytpl-123')
                .overrideWith((ref) => Future.value(remotePage)),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Chill Vibes Remote'), findsWidgets);
      expect(find.text('Track One'), findsOneWidget);

      // Open More menu and Save to Library
      await tester.tap(find.byIcon(LucideIcons.ellipsis).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Save to Library'), findsOneWidget);
      await tester.tap(find.text('Save to Library'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(() => libraryRepo.createPlaylist('Chill Vibes Remote')).called(1);
      verify(
        () => libraryRepo.addTracksToPlaylist('local-new', const [
          sampleTrack1,
          sampleTrack2,
        ]),
      ).called(1);
    },
  );

  testWidgets('Renders Remote playlist error state and retries', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var shouldFail = true;
    await tester.pumpWidget(
      _buildHarness(
        libraryRepo: libraryRepo,
        playerController: playerController,
        playlistId: 'ytpl-err',
        kind: PlaylistKind.remote,
        overrides: [
          playlistPageProvider('ytpl-err').overrideWith((ref) {
            if (shouldFail) {
              return Future.error(Exception('Network error'));
            }
            return Future.value(
              const PlaylistPage(
                playlist: RemotePlaylist(
                  id: 'ytpl-err',
                  name: 'Recovered Playlist',
                  owner: sampleArtist,
                ),
                tracks: [sampleTrack1],
              ),
            );
          }),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't load the tracks. The playlist itself is fine."),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);

    shouldFail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Recovered Playlist'), findsWidgets);
  });

  testWidgets(
    'Renders pending matching progress pill when pending tracks exist',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const pendingTrack = Track(
        id: 'tr-pending',
        title: 'Pending Track',
        artist: sampleArtist,
        duration: 200,
        source: TrackSource.yt,
        pending: true,
      );

      final pendingPlaylist = LocalPlaylist(
        id: 'local-pending',
        name: 'Importing Mix',
        tracks: const [sampleTrack1, pendingTrack],
        createdAt: DateTime(2026),
      );
      when(() => libraryRepo.getPlaylist('local-pending'))
          .thenReturn(pendingPlaylist);

      await tester.pumpWidget(
        _buildHarness(
          libraryRepo: libraryRepo,
          playerController: playerController,
          playlistId: 'local-pending',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Matching 1 of 2 tracks'), findsOneWidget);
    },
  );

  testWidgets('RTL and Light theme render without error', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Arabic / RTL
    await tester.pumpWidget(
      _buildHarness(
        libraryRepo: libraryRepo,
        playerController: playerController,
        playlistId: 'local-123',
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Track One'), findsOneWidget);

    // Light theme
    await tester.pumpWidget(
      _buildHarness(
        libraryRepo: libraryRepo,
        playerController: playerController,
        playlistId: 'local-123',
        theme: AppTheme.light(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Track One'), findsOneWidget);
  });
}
