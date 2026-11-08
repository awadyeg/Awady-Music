import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/local_playlist.dart';
import 'package:awady_music/data/models/lyrics.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/downloads_repository.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/data/repositories/lyrics_repository.dart';
import 'package:awady_music/features/library/library_screen.dart';
import 'package:awady_music/features/now_playing/now_playing_screen.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';

class MockLibraryRepository extends Mock implements LibraryRepository;

class _FakePlayer extends Notifier<PlayerState> implements PlayerController {
  _FakePlayer({PlayerState? initial})
    : _initial = initial ?? const PlayerState();

  final PlayerState _initial;

  @override
  PlayerState build() => _initial;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _artist = Artist(id: 'art-1', name: 'Awady Legend');

const _track = Track(
  id: 'tr-1',
  title: 'Top Song',
  artist: _artist,
  duration: 210,
  source: TrackSource.yt,
);

final _playlist = LocalPlaylist(
  id: 'local-test',
  name: 'Workout Grooves',
  tracks: const [_track],
  createdAt: DateTime(2026, 3),
);

final _older = LocalPlaylist(
  id: 'local-old',
  name: 'Alpha Nights',
  tracks: const [_track, _track],
  createdAt: DateTime(2025),
);

const _pixelRatio = 2.0;

Widget _app({
  required Key appKey,
  required Widget home,
  required ThemeData theme,
  required List<dynamic> overrides,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    key: appKey,
    overrides: overrides.cast(),
    child: MaterialApp(
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.light,
      locale: locale,
      debugShowCheckedModeBanner: false,
      supportedLocales: const [Locale('en'), Locale('es'), Locale('ar')],
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: RepaintBoundary(key: const Key('capture-root'), child: home),
    ),
  );
}

/// Ahem draws every glyph as a solid em square. Real fonts leave gaps.
class _GlyphScan {
  _GlyphScan({required this.inkColumns, required this.solidColumns});

  final int inkColumns;
  final int solidColumns;

  double get solidRatio => inkColumns == 0 ? 1 : solidColumns / inkColumns;
}

_GlyphScan _scanText({
  required ByteData bytes,
  required int width,
  required Rect logicalRect,
}) {
  final left = (logicalRect.left * _pixelRatio).floor().clamp(0, width - 1);
  final right = (logicalRect.right * _pixelRatio).ceil().clamp(left + 1, width);
  final top = (logicalRect.top * _pixelRatio).floor();
  final bottom = (logicalRect.bottom * _pixelRatio).ceil();
  final height = bytes.lengthInBytes ~/ (width * 4);
  final y0 = top.clamp(0, height - 1);
  final y1 = bottom.clamp(y0 + 1, height);

  var inkColumns = 0;
  var solidColumns = 0;
  for (var x = left; x < right; x++) {
    var ink = 0;
    final rows = y1 - y0;
    for (var y = y0; y < y1; y++) {
      final i = (y * width + x) * 4;
      final r = bytes.getUint8(i);
      final g = bytes.getUint8(i + 1);
      final b = bytes.getUint8(i + 2);
      final lum = (0.2126 * r) + (0.7152 * g) + (0.0722 * b);
      final bg = lum > 180 || lum < 28;
      if (!bg) ink++;
    }
    if (ink == 0) continue;
    inkColumns++;
    if (ink / rows > 0.85) solidColumns++;
  }
  return _GlyphScan(inkColumns: inkColumns, solidColumns: solidColumns);
}

double _lumAt(ByteData bytes, int width, int x, int y) {
  final i = (y * width + x) * 4;
  return (0.2126 * bytes.getUint8(i)) +
      (0.7152 * bytes.getUint8(i + 1)) +
      (0.0722 * bytes.getUint8(i + 2));
}

int _interiorInk({
  required ByteData bytes,
  required int width,
  required Rect logicalRect,
}) {
  final height = bytes.lengthInBytes ~/ (width * 4);
  final left = (logicalRect.left * _pixelRatio).floor().clamp(0, width - 1);
  final right = (logicalRect.right * _pixelRatio).ceil().clamp(left + 1, width);
  final top = (logicalRect.top * _pixelRatio).floor().clamp(0, height - 1);
  final bottom = (logicalRect.bottom * _pixelRatio).ceil().clamp(
    top + 1,
    height,
  );
  final corners = [
    _lumAt(bytes, width, left, top),
    _lumAt(bytes, width, right - 1, top),
    _lumAt(bytes, width, left, bottom - 1),
    _lumAt(bytes, width, right - 1, bottom - 1),
  ]..sort();
  final background = corners[corners.length ~/ 2];
  final insetX = ((right - left) * 0.2).round();
  final insetY = ((bottom - top) * 0.2).round();
  final x0 = (left + insetX).clamp(0, width - 1);
  final x1 = (right - insetX).clamp(x0 + 1, width);
  final y0 = (top + insetY).clamp(0, height - 1);
  final y1 = (bottom - insetY).clamp(y0 + 1, height);
  var ink = 0;
  for (var y = y0; y < y1; y++) {
    for (var x = x0; x < x1; x++) {
      if ((_lumAt(bytes, width, x, y) - background).abs() > 28) ink++;
    }
  }
  return ink;
}

Future<ui.Image> _raster(WidgetTester tester) async {
  await tester.pump();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('capture-root')),
  );
  final image = await tester.runAsync(
    () => boundary.toImage(pixelRatio: _pixelRatio),
  );
  if (image == null) {
    throw StateError('RepaintBoundary produced no image');
  }
  return image;
}

Future<void> _writePng(WidgetTester tester, ui.Image image, String name) async {
  final dir = Platform.environment['AWADY_SCREENSHOT_DIR'];
  if (dir == null || dir.isEmpty) return;
  final bytes = await tester.runAsync(
    () => image.toByteData(format: ui.ImageByteFormat.png),
  );
  if (bytes == null) return;
  final file = File('$dir/$name.png');
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes.buffer.asUint8List());
}

void _expectReadableText(String label, _GlyphScan scan) {
  expect(
    scan.inkColumns,
    greaterThan(12),
    reason: '$label did not paint enough glyph ink',
  );
  expect(
    scan.solidRatio,
    lessThan(0.72),
    reason:
        '$label looks like the Ahem test font '
        '(solidRatio ${scan.solidRatio.toStringAsFixed(2)}, '
        'ink ${scan.inkColumns})',
  );
}

void main() {
  late MockLibraryRepository libraryRepo;

  setUp(() {
    libraryRepo = MockLibraryRepository();
    when(() => libraryRepo.likedTracks).thenReturn([_track]);
    when(() => libraryRepo.recents).thenReturn([_track]);
    when(() => libraryRepo.playlists).thenReturn([_playlist, _older]);
    when(() => libraryRepo.followedArtists).thenReturn([_artist]);
    when(() => libraryRepo.isLiked(any())).thenReturn(false);
  });

  void phone(WidgetTester tester) {
    // Tall enough that the library's floating "New playlist" button
    // sits below the followed-artists header instead of covering it.
    tester.view.physicalSize = const Size(840, 2200);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  List<dynamic> libraryOverrides() => [
    libraryRepositoryProvider.overrideWithValue(libraryRepo),
    downloadsCountProvider.overrideWith((ref) => Stream.value(7)),
  ];

  testWidgets('library and now playing render real fonts and icons', (
    tester,
  ) async {
    phone(tester);

    Future<void> captureLibrary({
      required String name,
      required ThemeData theme,
      required String title,
      Locale locale = const Locale('en'),
    }) async {
      await tester.pumpWidget(
        _app(
          appKey: Key(name),
          home: const LibraryScreen(),
          theme: theme,
          locale: locale,
          overrides: libraryOverrides(),
        ),
      );
      final titleFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data == title &&
            (widget.style?.fontSize ?? 0) >= 30,
      );
      expect(titleFinder, findsOneWidget);
      expect(find.byIcon(LucideIcons.search), findsOneWidget);
      final image = await _raster(tester);
      final bytes = await tester.runAsync(image.toByteData);
      expect(bytes, isNotNull);
      final titleScan = _scanText(
        bytes: bytes!,
        width: image.width,
        logicalRect: tester.getRect(titleFinder),
      );
      _expectReadableText(name, titleScan);
      final iconInk = _interiorInk(
        bytes: bytes,
        width: image.width,
        logicalRect: tester.getRect(find.byIcon(LucideIcons.search)),
      );
      expect(
        iconInk,
        greaterThan(8),
        reason: '$name search icon is an empty box ($iconInk interior px)',
      );
      await _writePng(tester, image, name);
      image.dispose();
    }

    await captureLibrary(
      name: 'library-dark',
      theme: AppTheme.dark(),
      title: 'Your library',
    );
    await captureLibrary(
      name: 'library-light',
      theme: AppTheme.light(),
      title: 'Your library',
    );
    await captureLibrary(
      name: 'library-arabic',
      theme: AppTheme.dark(),
      title: 'مكتبتك',
      locale: const Locale('ar'),
    );

    await tester.pumpWidget(
      _app(
        appKey: const Key('now-playing-track'),
        home: const NowPlayingScreen(),
        theme: AppTheme.dark(),
        overrides: [
          playerControllerProvider.overrideWith(
            () => _FakePlayer(
              initial: const PlayerState(
                queue: [_track],
                index: 0,
                isPlaying: true,
                shuffle: true,
                repeat: RepeatMode.all,
                currentTime: Duration(seconds: 48),
                duration: Duration(seconds: 210),
              ),
            ),
          ),
          libraryRepositoryProvider.overrideWithValue(libraryRepo),
          downloadedTracksProvider.overrideWith(
            (ref) => Stream.value(const <Track>[]),
          ),
          downloadProgressStreamProvider.overrideWith(
            (ref) => Stream.value(const <String, DownloadProgress>{}),
          ),
          lyricsForTrackProvider.overrideWith(
            (ref, track) async => const NoLyrics(),
          ),
        ],
      ),
    );
    expect(find.text('Top Song'), findsOneWidget);
    expect(find.text('Awady Legend'), findsOneWidget);
    final image = await _raster(tester);
    final bytes = await tester.runAsync(image.toByteData);
    final titleScan = _scanText(
      bytes: bytes!,
      width: image.width,
      logicalRect: tester.getRect(find.text('Top Song')),
    );
    _expectReadableText('now-playing-track', titleScan);
    final playInk = _interiorInk(
      bytes: bytes,
      width: image.width,
      logicalRect: tester.getRect(find.byIcon(LucideIcons.pause)),
    );
    expect(playInk, greaterThan(8), reason: 'pause icon did not draw');
    await _writePng(tester, image, 'now-playing-track');
    image.dispose();
  });
}
