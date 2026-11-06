import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/local_playlist.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/data/repositories/stats_repository.dart';
import 'package:awady_music/features/settings/settings_screen.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:awady_music/widgets/glass_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLibraryRepository extends Mock implements LibraryRepository;

class MockStatsRepository extends Mock implements StatsRepository;

class FakePlayerController extends Notifier<PlayerState>
    implements PlayerController {
  FakePlayerController({PlayerState? initial})
    : _initial = initial ?? const PlayerState();

  final PlayerState _initial;
  bool? lastNormOn;
  int? lastFadeSecs;
  bool? lastAutoplay;

  @override
  PlayerState build() => _initial;

  @override
  void setNormOn({required bool value}) {
    lastNormOn = value;
  }

  @override
  void setFadeSecs(int secs) {
    lastFadeSecs = secs;
  }

  @override
  void setAutoplay({required bool value}) {
    lastAutoplay = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSettingsNotifier extends Notifier<AppSettings>
    implements SettingsNotifier {
  FakeSettingsNotifier({AppSettings? initial})
    : _initial = initial ?? const AppSettings();

  final AppSettings _initial;
  ThemeMode? lastThemeMode;
  bool? lastReduceTransparency;
  bool? lastAutoplay;
  Locale? lastLocale;
  String? lastCountryCode;

  @override
  AppSettings build() => _initial;

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    lastThemeMode = mode;
  }

  @override
  Future<void> setReduceTransparency({required bool reduce}) async {
    lastReduceTransparency = reduce;
  }

  @override
  Future<void> setAutoplay({required bool autoplay}) async {
    lastAutoplay = autoplay;
  }

  @override
  Future<void> setLocale(Locale? locale) async {
    lastLocale = locale;
  }

  @override
  Future<void> setCountryCode(String code) async {
    lastCountryCode = code;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _buildHarness({
  required MockLibraryRepository libraryRepo,
  required MockStatsRepository statsRepo,
  FakePlayerController? playerController,
  FakeSettingsNotifier? settingsNotifier,
  ThemeData? theme,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: [
      libraryRepositoryProvider.overrideWithValue(libraryRepo),
      statsRepositoryProvider.overrideWithValue(statsRepo),
      if (playerController != null)
        playerControllerProvider.overrideWith(() => playerController),
      if (settingsNotifier != null)
        settingsProvider.overrideWith(() => settingsNotifier),
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
      home: const Scaffold(
        body: Stack(children: [SettingsScreen(), GlassToast()]),
      ),
    ),
  );
}

void main() {
  late MockLibraryRepository libraryRepo;
  late MockStatsRepository statsRepo;
  late FakePlayerController playerController;
  late FakeSettingsNotifier settingsNotifier;

  setUp(() {
    libraryRepo = MockLibraryRepository();
    statsRepo = MockStatsRepository();
    playerController = FakePlayerController();
    settingsNotifier = FakeSettingsNotifier();

    when(() => libraryRepo.likedTracks).thenReturn([]);
    when(() => libraryRepo.playlists).thenReturn([
      LocalPlaylist(
        id: 'p1',
        name: 'My Playlist',
        tracks: const [],
        createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
      ),
    ]);
    when(() => statsRepo.flush()).thenReturn(null);
  });

  testWidgets(
    'Renders all 4 sections, app title, version, and constitution attribution',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildHarness(
          libraryRepo: libraryRepo,
          statsRepo: statsRepo,
          playerController: playerController,
          settingsNotifier: settingsNotifier,
        ),
      );
      await tester.pumpAndSettle();

      // Section headers
      expect(find.text('Settings'), findsWidgets);
      expect(find.text('Playback'), findsOneWidget);
      expect(find.text('Theme'), findsWidgets);
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);

      // App name & version
      expect(find.text('Awady Music'), findsOneWidget);
      expect(find.text('v1.0.0 (build 1)'), findsOneWidget);

      // Attribution line (Mandatory Constitution requirement)
      expect(
        find.text('Based on the open-source Freebify design and concept'),
        findsOneWidget,
      );

      // Readout stats
      expect(
        find.text(
          '0 liked songs · 1 playlists, stored locally on this device.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('Toggling switches invokes notifiers', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _buildHarness(
        libraryRepo: libraryRepo,
        statsRepo: statsRepo,
        playerController: playerController,
        settingsNotifier: settingsNotifier,
      ),
    );
    await tester.pumpAndSettle();

    final switches = find.byType(Switch);
    expect(switches, findsWidgets);

    // Toggle autoplay (first switch)
    await tester.tap(switches.first);
    await tester.pump();
    expect(settingsNotifier.lastAutoplay, isFalse);
    expect(playerController.lastAutoplay, isFalse);

    // Toggle normalize volume (second switch)
    await tester.tap(switches.at(1));
    await tester.pump();
    expect(playerController.lastNormOn, isFalse);
  });

  testWidgets('Clear cache and Check for updates display toasts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _buildHarness(
        libraryRepo: libraryRepo,
        statsRepo: statsRepo,
        playerController: playerController,
        settingsNotifier: settingsNotifier,
      ),
    );
    await tester.pumpAndSettle();

    // Tap clear cache
    await tester.tap(find.text('Clear artwork & lyrics cache'));
    await tester.pump();
    expect(
      find.text('Cache cleared. Your library is untouched'),
      findsOneWidget,
    );

    // Tap check for updates
    await tester.tap(find.text('Check for updates'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text("You're up to date"), findsOneWidget);
  });

  testWidgets('Renders Arabic RTL and Light theme cleanly', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _buildHarness(
        libraryRepo: libraryRepo,
        statsRepo: statsRepo,
        playerController: playerController,
        settingsNotifier: settingsNotifier,
        theme: AppTheme.light(),
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Awady Music'), findsOneWidget);
  });

  testWidgets('Country selector dialog updates countryCode', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _buildHarness(
        libraryRepo: libraryRepo,
        statsRepo: statsRepo,
        playerController: playerController,
        settingsNotifier: settingsNotifier,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Country & Region (Recommendations)'), findsOneWidget);
    await tester.tap(find.text('Country & Region (Recommendations)'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Saudi Arabia'), findsOneWidget);
    await tester.tap(find.textContaining('Saudi Arabia'));
    await tester.pumpAndSettle();

    expect(settingsNotifier.lastCountryCode, equals('SA'));
  });
}
