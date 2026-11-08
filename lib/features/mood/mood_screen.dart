import 'dart:async';

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/data/repositories/catalog_providers.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/widgets/large_title_scaffold.dart';
import 'package:awady_music/widgets/media_card.dart';
import 'package:awady_music/widgets/mood_visual_style.dart';
import 'package:awady_music/widgets/section_header.dart';
import 'package:awady_music/widgets/skeletons.dart';
import 'package:awady_music/widgets/track_menu_sheet.dart';
import 'package:awady_music/widgets/track_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MoodScreen extends ConsumerWidget {
  const MoodScreen({required this.params, super.key, this.name});

  final String params;
  final String? name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tokens = Theme.of(context).glass;
    final moodAsync = ref.watch(moodPageProvider(params));

    final title = (name != null && name!.isNotEmpty)
        ? name!
        : moodAsync.value?.name ?? l10n.moodMixes;

    return LargeTitleScaffold(
      title: title,
      onRefresh: () async {
        ref.invalidate(moodPageProvider(params));
        await ref.read(moodPageProvider(params).future);
      },
      slivers: [
        moodAsync.when(
          data: (data) {
            final hasPlaylists = data.playlists.isNotEmpty;
            final hasTracks = data.tracks.isNotEmpty;

            if (!hasPlaylists && !hasTracks) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 60,
                  ),
                  child: Center(
                    child: Text(
                      l10n.moodLoadError,
                      style: TextStyle(fontSize: 15, color: tokens.textDim),
                    ),
                  ),
                ),
              );
            }

            final style = MoodVisualStyle.forTitle(title);
            return SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 96,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: style.colors,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -10,
                              bottom: -15,
                              child: Opacity(
                                opacity: 0.22,
                                child: Icon(
                                  style.icon,
                                  size: 100,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    style.icon,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 4,
                                          color: Color(0x66000000),
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // 1. Playlists carousel
                if (hasPlaylists) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: SectionHeader(title: l10n.moodPlaylists(title)),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 230,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: data.playlists.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, idx) {
                          final pl = data.playlists[idx];
                          return MediaCard(
                            title: pl.name,
                            subtitle: pl.owner.name,
                            artwork: pl.artwork,
                            onTap: () =>
                                unawaited(context.push('/playlist/${pl.id}')),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // 2. Top tracks list
                if (hasTracks) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: SectionHeader(title: l10n.moodTopTracks),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final track = data.tracks[index];
                      final isPlaying = ref.watch(
                        playerControllerProvider.select(
                          (s) => s.current?.id == track.id && s.isPlaying,
                        ),
                      );
                      return TrackTile(
                        title: track.title,
                        artist: track.artist.name,
                        artwork: track.artwork,
                        duration: track.duration,
                        isPlaying: isPlaying,
                        onTap: () {
                          ref
                              .read(playerControllerProvider.notifier)
                              .playTrack(track, data.tracks);
                        },
                        onMoreTap: () =>
                            showTrackMenuSheet(context: context, track: track),
                      );
                    }, childCount: data.tracks.length),
                  ),
                ],
              ],
            );
          },
          loading: () => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: CardsRowSkeleton(),
            ),
          ),
          error: (err, stack) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ContentSurface(
                radius: 16,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.alertCircle,
                      color: tokens.danger,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.moodLoadError,
                        style: TextStyle(
                          fontSize: 14,
                          color: tokens.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: tokens.textPrimary,
                        side: BorderSide(color: tokens.glassStroke),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => ref.refresh(moodPageProvider(params)),
                      child: Text(l10n.moodRetry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Bottom space for mini player and navigation bar
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}
