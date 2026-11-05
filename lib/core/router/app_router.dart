import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/features/home/home_screen.dart';
import 'package:awady_music/features/now_playing/now_playing_screen.dart';
import 'package:awady_music/features/queue/queue_screen.dart';
import 'package:awady_music/features/search/search_screen.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/widgets/glass_tab_bar.dart';
import 'package:awady_music/widgets/mini_player.dart';
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
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasTrack = ref.watch(
      playerControllerProvider.select((s) => s.current != null),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(child: navigationShell),
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
                  currentIndex: navigationShell.currentIndex,
                  onTap: (index) {
                    navigationShell.goBranch(
                      index,
                      initialLocation: index == navigationShell.currentIndex,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
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
                    builder: (context, state) => PlaceholderScreen(
                      'RewindScreen: ${state.pathParameters['month']}',
                    ),
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
                    builder: (context, state) => PlaceholderScreen(
                      'GenreScreen: ${state.pathParameters['name']}',
                    ),
                  ),
                  GoRoute(
                    path: 'mood/:params',
                    builder: (context, state) => PlaceholderScreen(
                      'MoodScreen: ${state.pathParameters['params']}',
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
                builder: (context, state) =>
                    const PlaceholderScreen('LibraryScreen'),
                routes: [
                  GoRoute(
                    path: 'liked',
                    builder: (context, state) =>
                        const PlaceholderScreen('PlaylistScreen(kind: liked)'),
                  ),
                  GoRoute(
                    path: 'downloads',
                    builder: (context, state) =>
                        const PlaceholderScreen('DownloadsScreen'),
                  ),
                  GoRoute(
                    path: 'recent',
                    builder: (context, state) =>
                        const PlaceholderScreen('RecentScreen'),
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
                builder: (context, state) =>
                    const PlaceholderScreen('StatsScreen'),
              ),
            ],
          ),
        ],
      ),
      // Shared routes (pushed within tabs)
      GoRoute(
        path: '/artist/:id',
        builder: (context, state) =>
            PlaceholderScreen('ArtistScreen: ${state.pathParameters['id']}'),
      ),
      GoRoute(
        path: '/playlist/:id',
        builder: (context, state) =>
            PlaceholderScreen('PlaylistScreen: ${state.pathParameters['id']}'),
      ),
      // Root-level modal routes
      GoRoute(
        path: '/now-playing',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NowPlayingScreen(),
      ),
      GoRoute(
        path: '/queue',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const QueueScreen(),
      ),
      GoRoute(
        path: '/import',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => PlaceholderScreen(
          'ImportScreen: ${state.uri.queryParameters['url'] ?? ''}',
        ),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PlaceholderScreen('SettingsScreen'),
        routes: [
          GoRoute(
            path: 'eq',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) =>
                const PlaceholderScreen('EqualizerScreen'),
          ),
          GoRoute(
            path: 'legal',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const PlaceholderScreen('LegalScreen'),
          ),
        ],
      ),
    ],
  );
});
