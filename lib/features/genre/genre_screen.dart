import 'dart:async';

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/catalog_providers.dart';
import 'package:awady_music/data/sources/audius/audius_client.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/widgets/large_title_scaffold.dart';
import 'package:awady_music/widgets/skeletons.dart';
import 'package:awady_music/widgets/track_menu_sheet.dart';
import 'package:awady_music/widgets/track_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Period filter for genre trending tracks.
enum GenreTimeFilter { topHits, week, month, allTime }

class GenreScreen extends ConsumerStatefulWidget {
  const GenreScreen({required this.name, super.key});

  final String name;

  @override
  ConsumerState<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends ConsumerState<GenreScreen> {
  GenreTimeFilter _filter = GenreTimeFilter.topHits;
  int _retryTick = 0;

  Future<List<Track>> _loadTracks() async {
    final genreName = widget.name;
    if (_filter == GenreTimeFilter.topHits) {
      final searchRes = await ref
          .read(catalogRepositoryProvider)
          .search('$genreName hits');
      if (searchRes.songs.isNotEmpty) {
        return searchRes.songs;
      }
    }

    final audiusTime = switch (_filter) {
      GenreTimeFilter.topHits => 'week',
      GenreTimeFilter.week => 'week',
      GenreTimeFilter.month => 'month',
      GenreTimeFilter.allTime => 'all',
    };

    final audius = ref.read(audiusClientProvider);
    return await audius.trendingTracks(
      genre: genreName,
      time: audiusTime,
      limit: 60,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = Theme.of(context).glass;

    return LargeTitleScaffold(
      title: widget.name,
      slivers: [
        // Subtitle kicker + Filter segmented chips
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _filter == GenreTimeFilter.topHits
                      ? l10n.genreKicker
                      : '${l10n.genreKicker} ${l10n.genreTrending}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: tokens.textDim,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip(
                        label: l10n.genreTopHits,
                        filter: GenreTimeFilter.topHits,
                        tokens: tokens,
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        label: l10n.genreTimeWeek,
                        filter: GenreTimeFilter.week,
                        tokens: tokens,
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        label: l10n.genreTimeMonth,
                        filter: GenreTimeFilter.month,
                        tokens: tokens,
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        label: l10n.genreTimeAllTime,
                        filter: GenreTimeFilter.allTime,
                        tokens: tokens,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Content
        FutureBuilder<List<Track>>(
          key: ValueKey('${widget.name}_${_filter.name}_$_retryTick'),
          future: _loadTracks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: RowsSkeleton(count: 10),
                ),
              );
            }

            if (snapshot.hasError) {
              return SliverToBoxAdapter(
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
                            l10n.genreLoadError,
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
                          onPressed: () {
                            setState(() => _retryTick++);
                          },
                          child: Text(l10n.genreRetry),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final tracks = snapshot.data ?? const [];
            if (tracks.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 60,
                  ),
                  child: Center(
                    child: Text(
                      l10n.genreLoadError,
                      style: TextStyle(fontSize: 15, color: tokens.textDim),
                    ),
                  ),
                ),
              );
            }

            return SliverMainAxisGroup(
              slivers: [
                // Big Play accent capsule
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tokens.accent,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          ref
                              .read(playerControllerProvider.notifier)
                              .playTrack(tracks.first, tracks);
                        },
                        icon: const Icon(
                          LucideIcons.play,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: Text(
                          l10n.genrePlay,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Tracks list
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final track = tracks[index];
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
                            .playTrack(track, tracks);
                      },
                      onMoreTap: () =>
                          showTrackMenuSheet(context: context, track: track),
                    );
                  }, childCount: tracks.length),
                ),
              ],
            );
          },
        ),

        // Bottom padding for player bar
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required GenreTimeFilter filter,
    required GlassTokens tokens,
  }) {
    final isSelected = _filter == filter;

    return InkWell(
      onTap: () => setState(() => _filter = filter),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? tokens.accent.withValues(alpha: 0.22) : null,
        ),
        child: ContentSurface(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? tokens.accent : tokens.textDim,
            ),
          ),
        ),
      ),
    );
  }
}
