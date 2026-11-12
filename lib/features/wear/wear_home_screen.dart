import 'dart:async';

import 'package:awady_music/data/repositories/catalog_providers.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/data/repositories/stats_repository.dart';
import 'package:awady_music/player/audio_handler.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class WearHomeScreen extends ConsumerStatefulWidget {
  const WearHomeScreen({super.key});

  @override
  ConsumerState<WearHomeScreen> createState() => _WearHomeScreenState();
}

class _WearHomeScreenState extends ConsumerState<WearHomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            children: [
              _buildNowPlayingPage(context, ref),
              _buildQuickPicksPage(context, ref),
              _buildAiMixesPage(context, ref),
            ],
          ),
          Positioned(
            right: 4,
            top: 0,
            bottom: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  final active = _currentPage == index;
                  return Container(
                    width: 6,
                    height: active ? 16 : 6,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: active ? Colors.purpleAccent : Colors.white38,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlayingPage(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerControllerProvider);
    final track = playerState.current;
    final isPlaying = playerState.isPlaying;
    final audioHandler = ref.read(audioHandlerProvider);

    if (track == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.music, color: Colors.white70, size: 40),
              const SizedBox(height: 12),
              const Text(
                'Awady Music Wear',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tap a song to start listening',
                style: TextStyle(color: Colors.white54, fontSize: 11),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () => _pageController.jumpToPage(1),
                child: const Icon(LucideIcons.play, size: 20),
              ),
            ],
          ),
        ),
      );
    }

    final artUrl =
        track.artwork?.s1000 ??
        track.artwork?.s480 ??
        track.artwork?.s150 ??
        track.artwork?.fallback;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (artUrl != null && artUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: artUrl,
            fit: BoxFit.cover,
            errorWidget: (_, _, _) => Container(color: Colors.grey[900]),
          ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.6),
                Colors.black.withValues(alpha: 0.9),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: 120,
                child: Text(
                  track.artist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      LucideIcons.skipBack,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: audioHandler.skipToPrevious,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: () {
                      if (isPlaying) {
                        unawaited(audioHandler.pause());
                      } else {
                        unawaited(audioHandler.play());
                      }
                    },
                    child: Icon(
                      isPlaying ? LucideIcons.pause : LucideIcons.play,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.skipForward,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: audioHandler.skipToNext,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPicksPage(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingTracksProvider);
    final likedTracks = ref.watch(libraryRepositoryProvider).likedTracks;
    final mostPlayed = ref.watch(statsRepositoryProvider).mostPlayedTracks;

    final combined = [
      ...likedTracks,
      ...mostPlayed,
      ...(trendingAsync.asData?.value.items ?? []),
    ];
    final seen = <String>{};
    final unique = combined.where((t) => seen.add(t.id)).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Picks',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: unique.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.purpleAccent,
                    ),
                  )
                : ListView.builder(
                    itemCount: unique.take(15).length,
                    itemBuilder: (context, index) {
                      final track = unique[index];
                      final artUrl =
                          track.artwork?.s1000 ??
                          track.artwork?.s480 ??
                          track.artwork?.s150 ??
                          track.artwork?.fallback;
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: artUrl != null && artUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: CachedNetworkImage(
                                  imageUrl: artUrl,
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 32,
                                height: 32,
                                color: Colors.grey[800],
                              ),
                        title: Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        subtitle: Text(
                          track.artist.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                        onTap: () {
                          ref
                              .read(playerControllerProvider.notifier)
                              .playTrack(track);
                          _pageController.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiMixesPage(BuildContext context, WidgetRef ref) {
    final aiMixesAsync = ref.watch(aiMixesProvider);
    final aiMixes = aiMixesAsync.asData?.value ?? const [];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'AI Mixes & Liked',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (aiMixes.isNotEmpty) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              icon: const Icon(LucideIcons.wandSparkles, size: 15),
              label: Text(
                aiMixes.first.title,
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: () {
                final tracks = aiMixes.first.tracks;
                if (tracks.isNotEmpty) {
                  ref
                      .read(playerControllerProvider.notifier)
                      .playContext(tracks, 0);
                  _pageController.jumpToPage(0);
                }
              },
            ),
            const SizedBox(height: 6),
          ],
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            icon: const Icon(LucideIcons.heart, size: 15),
            label: const Text('Liked Songs', style: TextStyle(fontSize: 11)),
            onPressed: () {
              final liked = ref.read(libraryRepositoryProvider).likedTracks;
              if (liked.isNotEmpty) {
                ref
                    .read(playerControllerProvider.notifier)
                    .playContext(liked, 0);
                _pageController.jumpToPage(0);
              }
            },
          ),
          const SizedBox(height: 6),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            icon: const Icon(LucideIcons.sparkles, size: 15),
            label: const Text('Trending Mix', style: TextStyle(fontSize: 11)),
            onPressed: () {
              final trending =
                  ref.read(trendingTracksProvider).asData?.value.items ?? [];
              if (trending.isNotEmpty) {
                ref
                    .read(playerControllerProvider.notifier)
                    .playContext(trending, 0);
                _pageController.jumpToPage(0);
              }
            },
          ),
        ],
      ),
    );
  }
}
