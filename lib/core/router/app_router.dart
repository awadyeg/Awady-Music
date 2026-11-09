import 'dart:async';

import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/core/util/tv_detector.dart';
import 'package:awady_music/features/artist/artist_screen.dart';
import 'package:awady_music/features/downloads/downloads_screen.dart';
import 'package:awady_music/features/genre/genre_screen.dart';
import 'package:awady_music/features/home/home_screen.dart';
import 'package:awady_music/features/legal/legal_screen.dart';
import 'package:awady_music/features/library/library_screen.dart';
import 'package:awady_music/features/mood/mood_screen.dart';
import 'package:awady_music/features/now_playing/now_playing_screen.dart';
import 'package:awady_music/features/playlist/playlist_screen.dart';
import 'package:awady_music/features/queue/queue_screen.dart';
import 'package:awady_music/features/rewind/rewind_screen.dart';
import 'package:awady_music/features/search/search_screen.dart';
import 'package:awady_music/features/settings/settings_screen.dart';
import 'package:awady_music/features/stats/stats_screen.dart';
import 'package:awady_music/features/tv/tv_home_screen.dart';
import 'package:awady_music/player/connect_receiver.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/widgets/equalizer_sheet.dart';
import 'package:awady_music/widgets/glass_tab_bar.dart';
import 'package:awady_music/widgets/import_sheet.dart';
import 'package:awady_music/widgets/mini_player.dart';
import 'package:awady_music/widgets/offline_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen(this.name, {super.key});
  final String name;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;
    return Scaffold(
      backgroundColor: tokens.bg,
      body: Center(
        child: Text(
          name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: tokens.textPrimary,
          ),
        ),
      ),
    );
  }
}

class AppShell extends ConsumerWidget {
  const AppShell({required this.child, required this.currentPath, super.key});

  final Widget child;
  final String currentPath;

  int _calculateIndex(String path) {
    if (path.startsWith('/search') ||
        path.startsWith('/genre') ||
        path.startsWith('/mood')) {
      return 1;
    }
    if (path.startsWith('/library') || path.startsWith('/import')) {
      return 2;
    }
    if (path.startsWith('/stats')) {
      return 3;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(settingsProvider.select((s) => s.enableConnectReceiver), (
      prev,
      next,
    ) {
      if (next) {
        unawaited(ref.read(connectReceiverProvider.notifier).start());
      } else {
        ref.read(connectReceiverProvider.notifier).stop();
      }
    });

    final isTv = ref.watch(isTvModeProvider);
    if (isTv) {
      return TvHomeScreen(
        onExitTvMode: () {
          unawaited(ref.read(settingsProvider.notifier).setTvMode('off'));
        },
      );
    }

    final hasTrack = ref.watch(
      playerControllerProvider.select((s) => s.current != null),
    );

    final currentIndex = _calculateIndex(currentPath);

    return RepaintBoundary(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(child: child),
            const Positioned(left: 0, right: 0, top: 0, child: OfflineBanner()),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasTrack) ...[
                    const MiniPlayer(),
                    const SizedBox(height: 8),
                  ],
                  GlassTabBar(
                    currentIndex: currentIndex,
                    onTap: (index) {
                      if (index == 1 && currentIndex == 1) {
                        ref.read(searchFocusTriggerProvider.notifier).trigger();
                      }
                      switch (index) {
                        case 0:
                          context.go('/home');
                        case 1:
                          context.go('/search');
                        case 2:
                          context.go('/library');
                        case 3:
                          context.go('/stats');
                      }
                    },
                    onDoubleTap: (index) {
                      if (index == 1) {
                        ref.read(searchFocusTriggerProvider.notifier).trigger();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      if (state.uri.path == '/') {
        return '/home';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(currentPath: state.uri.path, child: child);
        },
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return navigationShell;
            },
            branches: [
              // Branch 0: Home
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home',
                    builder: (context, state) => const HomeScreen(),
                    routes: [
                      GoRoute(
                        path: 'rewind/:month',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) =>
                            RewindScreen(month: state.pathParameters['month']),
                      ),
                    ],
                  ),
                ],
              ),
              // Branch 1: Search
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/search',
                    builder: (context, state) => const SearchScreen(),
                    routes: [
                      GoRoute(
                        path: 'genre/:name',
                        builder: (context, state) => GenreScreen(
                          name: state.pathParameters['name'] ?? '',
                        ),
                      ),
                      GoRoute(
                        path: 'mood/:params',
                        builder: (context, state) => MoodScreen(
                          params: state.pathParameters['params'] ?? '',
                          name: state.extra as String?,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Branch 2: Library
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/library',
                    builder: (context, state) => const LibraryScreen(),
                    routes: [
                      GoRoute(
                        path: 'liked',
                        builder: (context, state) => const PlaylistScreen(
                          id: 'liked',
                          kind: PlaylistKind.liked,
                        ),
                      ),
                      GoRoute(
                        path: 'downloads',
                        builder: (context, state) => const DownloadsScreen(),
                      ),
                      GoRoute(
                        path: 'recent',
                        builder: (context, state) => const PlaylistScreen(
                          id: 'recent',
                          kind: PlaylistKind.recent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Branch 3: Stats
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/stats',
                    builder: (context, state) => const StatsScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Shared routes (now inside the shell, so MiniPlayer and
          // GlassTabBar are permanently visible)
          GoRoute(
            path: '/artist/:id',
            builder: (context, state) => ArtistScreen(
              id: state.pathParameters['id'] ?? '',
              nameHint: state.uri.queryParameters['n'],
            ),
          ),
          GoRoute(
            path: '/playlist/:id',
            builder: (context, state) => PlaylistScreen(
              id: state.pathParameters['id'] ?? '',
              kind: state.extra as PlaylistKind?,
            ),
          ),
          GoRoute(
            path: '/genre/:name',
            builder: (context, state) =>
                GenreScreen(name: state.pathParameters['name'] ?? ''),
          ),
          GoRoute(
            path: '/mood/:params',
            builder: (context, state) => MoodScreen(
              params: state.pathParameters['params'] ?? '',
              name: state.extra as String?,
            ),
          ),
          GoRoute(
            path: '/queue',
            builder: (context, state) => const QueueScreen(),
          ),
          GoRoute(
            path: '/import',
            builder: (context, state) => Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/library');
                    }
                  },
                ),
              ),
              body: SafeArea(
                child: ImportSheet(
                  initialUrl: state.uri.queryParameters['url'],
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'eq',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) =>
                    const Scaffold(body: SafeArea(child: EqualizerSheet())),
              ),
              GoRoute(
                path: 'legal',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const LegalScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/tv',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => TvHomeScreen(
          onExitTvMode: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      // Root-level modal routes
      GoRoute(
        path: '/now-playing',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          opaque: false,
          barrierColor: Colors.transparent,
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 240),
          child: const NowPlayingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curved),
              child: RepaintBoundary(child: child),
            );
          },
        ),
      ),
    ],
  );
});
