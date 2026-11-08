import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/artwork.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/local_playlist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/features/library/library_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';

class MockLibraryRepository extends Mock implements LibraryRepository;

Widget _buildHarness({
  required MockLibraryRepository libraryRepo,
  int downloadsCount = 5,
  List<dynamic> overrides = const [],
  ThemeData? theme,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: [
      libraryRepositoryProvider.overrideWithValue(libraryRepo),
      downloadsCountProvider.overrideWith(
        (ref) => Stream.value(downloadsCount),
      ),
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
      home: const Scaffold(body: LibraryScreen()),
    ),
  );
}

void main() {
  const sampleArtist = Artist(
    id: 'art-1',
    name: 'Awady Legend',
    profilePicture: Artwork(s150: 'https://example.com/artist.jpg'),
  );

  const sampleTrack = Track(
    id: 'tr-1',
    title: 'Top Song',
    artist: sampleArtist,
    duration: 210,
    source: TrackSource.yt,
    artwork: Artwork(s150: 'https://example.com/song.jpg'),
  );

  final samplePlaylist = LocalPlaylist(
    id: 'local-test',
    name: 'Workout Grooves',
    tracks: const [sampleTrack],
    createdAt: DateTime(2026),
  );

  late MockLibraryRepository libraryRepo;

  setUp(() {
    libraryRepo = MockLibraryRepository();
    when(() => libraryRepo.likedTracks).thenReturn([sampleTrack]);
    when(() => libraryRepo.recents).thenReturn([sampleTrack]);
    when(() => libraryRepo.playlists).thenReturn([samplePlaylist]);
    when(() => libraryRepo.followedArtists).thenReturn([sampleArtist]);
    when(() => libraryRepo.createPlaylist(any())).thenReturn('local-created');
  });

  testWidgets('Renders Your library title, header actions, pinned rows, '
      'playlists and artists', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _buildHarness(libraryRepo: libraryRepo, downloadsCount: 7),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your library'), findsWidgets);
    expect(find.byIcon(LucideIcons.link2), findsOneWidget);
    expect(find.byIcon(LucideIcons.settings), findsOneWidget);

    // Pinned rows
    expect(find.text('Liked Songs'), findsOneWidget);
    expect(find.text('Downloads'), findsWidgets);
    expect(find.text('Recently played'), findsOneWidget);

    // Playlists section
    expect(find.text('Your playlists'), findsOneWidget);
    expect(find.text('Workout Grooves'), findsOneWidget);

    // Artists section
    expect(find.text('Artists you follow'), findsOneWidget);
    expect(find.text('Awady Legend'), findsOneWidget);

    // New playlist FAB
    expect(find.text('New playlist'), findsOneWidget);
  });

  testWidgets('Filter chips filter content correctly', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildHarness(libraryRepo: libraryRepo));
    await tester.pumpAndSettle();

    // Tap Artists filter
    await tester.tap(find.text('Artists'));
    await tester.pumpAndSettle();

    expect(find.text('Artists you follow'), findsOneWidget);
    expect(find.text('Awady Legend'), findsOneWidget);
    expect(find.text('Workout Grooves'), findsNothing);
    expect(find.text('Liked Songs'), findsNothing);

    // Tap Playlist filter
    await tester.tap(find.text('Playlist'));
    await tester.pumpAndSettle();

    expect(find.text('Your playlists'), findsOneWidget);
    expect(find.text('Workout Grooves'), findsOneWidget);
    expect(find.text('Awady Legend'), findsNothing);

    // Tap Downloads filter
    await tester.tap(find.text('Downloads').first);
    await tester.pumpAndSettle();

    expect(find.text('Downloads'), findsWidgets);
    expect(find.text('Workout Grooves'), findsNothing);
    expect(find.text('Awady Legend'), findsNothing);
  });

  testWidgets('Empty playlists state renders empty hint', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    when(() => libraryRepo.playlists).thenReturn([]);
    when(() => libraryRepo.followedArtists).thenReturn([]);

    await tester.pumpWidget(_buildHarness(libraryRepo: libraryRepo));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Create a playlist and add songs from the ··· menu on any track.',
      ),
      findsOneWidget,
    );
    expect(find.text('No followed artists yet.'), findsOneWidget);
  });

  testWidgets('New playlist dialog creates playlist via repository', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildHarness(libraryRepo: libraryRepo));
    await tester.pumpAndSettle();

    // Tap New playlist FAB
    await tester.tap(find.text('New playlist'));
    await tester.pumpAndSettle();

    expect(find.text('Create playlist'), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'My Chill Beats',
    );
    await tester.tap(find.text('Create playlist'));
    await tester.pumpAndSettle();

    verify(() => libraryRepo.createPlaylist('My Chill Beats')).called(1);
  });

  testWidgets('RTL Arabic and Light theme render without error', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Arabic / RTL
    await tester.pumpWidget(
      _buildHarness(libraryRepo: libraryRepo, locale: const Locale('ar')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Workout Grooves'), findsOneWidget);

    // Light theme
    await tester.pumpWidget(
      _buildHarness(libraryRepo: libraryRepo, theme: AppTheme.light()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Workout Grooves'), findsOneWidget);
  });

  testWidgets('Search filters playlists and artists', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildHarness(libraryRepo: libraryRepo));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('library_search_field')),
      'Workout',
    );
    await tester.pump();

    expect(find.text('Workout Grooves'), findsOneWidget);
    expect(find.text('Awady Legend'), findsNothing);
    expect(find.text('Liked Songs'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('library_search_field')),
      'Legend',
    );
    await tester.pump();

    expect(find.text('Awady Legend'), findsWidgets);
    expect(find.text('Matching songs'), findsOneWidget);
    expect(find.text('Top Song'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('library_search_field')),
      'zzz-no-match',
    );
    await tester.pump();

    expect(find.text('No matches in your library'), findsOneWidget);
    expect(find.text('Workout Grooves'), findsNothing);
  });

  testWidgets('Sorts playlists by name', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    when(() => libraryRepo.playlists).thenReturn([
      LocalPlaylist(
        id: 'newer',
        name: 'Zulu',
        tracks: const [],
        createdAt: DateTime(2026, 2),
      ),
      LocalPlaylist(
        id: 'older',
        name: 'Alpha',
        tracks: const [sampleTrack],
        createdAt: DateTime(2026),
      ),
    ]);

    await tester.pumpWidget(_buildHarness(libraryRepo: libraryRepo));
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('Zulu')).dy,
      lessThan(tester.getTopLeft(find.text('Alpha')).dy),
    );

    await tester.tap(find.byKey(const Key('library_sort_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Name').last);
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('Alpha')).dy,
      lessThan(tester.getTopLeft(find.text('Zulu')).dy),
    );
  });
}
