import 'dart:async';

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/catalog_providers.dart';
import 'package:awady_music/data/repositories/catalog_repository.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/data/repositories/stats_repository.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/rewind.dart';
import 'package:awady_music/widgets/artwork_image.dart';
import 'package:awady_music/widgets/large_title_scaffold.dart';
import 'package:awady_music/widgets/media_card.dart';
import 'package:awady_music/widgets/section_header.dart';
import 'package:awady_music/widgets/skeletons.dart';
import 'package:awady_music/widgets/update_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static String computeGreeting(L10n l10n, [DateTime? time]) {
    final hour = (time ?? DateTime.now()).hour;
    if (hour >= 5 && hour < 12) {
      return l10n.homeGreetingMorning;
    } else if (hour >= 12 && hour < 17) {
      return l10n.homeGreetingAfternoon;
    } else if (hour >= 17 && hour < 22) {
      return l10n.homeGreetingEvening;
    } else {
      return l10n.homeGreetingLate;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;
    final greeting = computeGreeting(l10n);

    final statsRepo = ref.watch(statsRepositoryProvider);
    final rewind = availableRewind(
      stats: statsRepo.state,
      locale: Localizations.localeOf(context).languageCode,
    );

    final libraryRepo = ref.watch(libraryRepositoryProvider);
    final recents = libraryRepo.recents;
    var hasLikesOrFollows = false;
    try {
      hasLikesOrFollows =
          libraryRepo.likedTracks.isNotEmpty ||
          libraryRepo.followedArtists.isNotEmpty;
    } on Object catch (_) {}

    final recommendedAsync = ref.watch(recommendedForYouProvider);
    final aiMixesAsync = ref.watch(aiMixesProvider);
    final showRecommended =
        hasLikesOrFollows ||
        (recommendedAsync.asData?.value.items.isNotEmpty ?? false);

    final trendingAsync = ref.watch(trendingTracksProvider);
    final newReleasesAsync = ref.watch(newReleasesProvider);
    final homePlaylistsAsync = ref.watch(homePlaylistsProvider);

    return Scaffold(
      backgroundColor: tokens.bg,
      body: LargeTitleScaffold(
        title: greeting,
        actions: [
          IconButton(
            icon: Icon(LucideIcons.settings, color: tokens.textPrimary),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
        onRefresh: () async {
          ref
            ..invalidate(recommendedForYouProvider)
            ..invalidate(aiMixesProvider)
            ..invalidate(trendingTracksProvider)
            ..invalidate(newReleasesProvider)
            ..invalidate(homePlaylistsProvider);
        },
        slivers: [
          // Update banner (Android)
          const SliverToBoxAdapter(child: UpdateBanner()),

          // 1. Rewind banner glass card if available
          if (rewind != null) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: GlassSurface(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: tokens.accent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.sparkles,
                          color: tokens.accent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rewind.partial
                                  ? l10n.homeRewindPartialReady(rewind.label)
                                  : l10n.homeRewindReady(rewind.label),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: tokens.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.homeRewindSub,
                              style: TextStyle(
                                fontSize: 12,
                                color: tokens.textDim,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tokens.accent,
                          foregroundColor: tokens.onAccent,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () {
                          ref
                              .read(rewindControllerProvider.notifier)
                              .open(rewind);
                          unawaited(context.push('/home/rewind/${rewind.key}'));
                        },
                        child: Text(
                          l10n.homeRewindWatch,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          // 2. Quick grid 2x3 of recently played
          if (recents.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: SectionHeader(title: l10n.libraryRecents),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.8,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final track = recents[index];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      ref
                          .read(playerControllerProvider.notifier)
                          .playTrack(track);
                    },
                    child: GlassSurface(
                      padding: const EdgeInsets.all(6),
                      child: Row(
                        children: [
                          ArtworkImage(art: track.artwork, size: 44, radius: 8),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              track.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textDirection:
                                  intl.Bidi.detectRtlDirectionality(track.title)
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: tokens.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: recents.length > 6 ? 6 : recents.length),
              ),
            ),
          ],
          // 2b. Carousels: Recommended based on likes
          if (showRecommended)
            SliverToBoxAdapter(
              child: _CarouselSection<Track>(
                title: l10n.homeNewForYou,
                asyncValue: recommendedAsync,
                onRetry: () => ref.refresh(recommendedForYouProvider),
                itemBuilder: (track) => MediaCard(
                  title: track.title,
                  subtitle: track.artist.name,
                  artwork: track.artwork,
                  onTap: () {
                    ref
                        .read(playerControllerProvider.notifier)
                        .playTrack(track, recommendedAsync.asData?.value.items);
                  },
                ),
              ),
            ),
          // AI Mixes based on likes
          aiMixesAsync.when(
            data: (mixes) {
              if (mixes.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(child: _AiMixesSection(mixes: mixes));
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
          // 3. Carousels: Trending this week
          SliverToBoxAdapter(
            child: _CarouselSection<Track>(
              title: l10n.homeTrending,
              asyncValue: trendingAsync,
              onRetry: () => ref.refresh(trendingTracksProvider),
              itemBuilder: (track) => MediaCard(
                title: track.title,
                subtitle: track.artist.name,
                artwork: track.artwork,
                onTap: () {
                  ref.read(playerControllerProvider.notifier).playTrack(track);
                },
              ),
            ),
          ),
          // 4. Carousels: New releases
          SliverToBoxAdapter(
            child: _CarouselSection<RemotePlaylist>(
              title: l10n.homeNewReleases,
              asyncValue: newReleasesAsync,
              onRetry: () => ref.refresh(newReleasesProvider),
              itemBuilder: (item) => MediaCard(
                title: item.name,
                subtitle: item.owner.name,
                artwork: item.artwork,
                onTap: () {
                  unawaited(context.push('/playlist/${item.id}'));
                },
              ),
            ),
          ),
          // 5. Carousels: Hot playlists
          SliverToBoxAdapter(
            child: _CarouselSection<RemotePlaylist>(
              title: l10n.homeHotPlaylists,
              asyncValue: homePlaylistsAsync,
              onRetry: () => ref.refresh(homePlaylistsProvider),
              itemBuilder: (item) => MediaCard(
                title: item.name,
                subtitle: item.owner.name,
                artwork: item.artwork,
                onTap: () {
                  unawaited(context.push('/playlist/${item.id}'));
                },
              ),
            ),
          ),
          // Bottom padding to ensure content is above the mini player & tab bar
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

class _CarouselSection<T> extends StatelessWidget {
  const _CarouselSection({
    required this.title,
    required this.asyncValue,
    required this.itemBuilder,
    required this.onRetry,
  });

  final String title;
  final AsyncValue<CatalogList<T>> asyncValue;
  final Widget Function(T item) itemBuilder;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: SectionHeader(title: title),
        ),
        asyncValue.when(
          data: (catalogList) {
            final items = catalogList.items;
            if (items.isEmpty) {
              return const SizedBox.shrink();
            }
            final textScaler = MediaQuery.textScalerOf(context);
            final rowHeight =
                (170.0 + textScaler.scale(35) + textScaler.scale(25)).clamp(
                  230.0,
                  360.0,
                );
            return SizedBox(
              height: rowHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (c, idx) => const SizedBox(width: 14),
                itemBuilder: (c, idx) => itemBuilder(items[idx]),
              ),
            );
          },
          loading: () => const CardsRowSkeleton(),
          error: (err, stack) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GlassSurface(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(LucideIcons.alertCircle, color: tokens.danger, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeLoadError,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: tokens.textPrimary,
                          ),
                        ),
                        Text(
                          l10n.homeLoadErrorHint,
                          style: TextStyle(fontSize: 12, color: tokens.textDim),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: tokens.textPrimary,
                      side: BorderSide(color: tokens.glassStroke),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: onRetry,
                    child: Text(l10n.homeRetry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AiMixesSection extends ConsumerWidget {
  const _AiMixesSection({required this.mixes});

  final List<AiMixPlaylist> mixes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).glass;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: SectionHeader(title: 'AI Mixes for You'),
        ),
        SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: mixes.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, idx) {
              final mix = mixes[idx];
              final firstArtwork = mix.tracks.isNotEmpty
                  ? mix.tracks.first.artwork
                  : null;

              return GestureDetector(
                onTap: () => _showAiMixSheet(context, ref, mix),
                child: SizedBox(
                  width: 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              GlassTokens.radiusCard,
                            ),
                            child: ArtworkImage(
                              art: firstArtwork,
                              size: 160,
                              radius: GlassTokens.radiusCard,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: tokens.accent.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(
                                  GlassTokens.radiusCapsule,
                                ),
                              ),
                              child: Text(
                                mix.badge,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: tokens.onAccent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mix.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${mix.tracks.length} tracks · '
                        '${mix.suggestedCount} new',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: tokens.textDim),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAiMixSheet(BuildContext context, WidgetRef ref, AiMixPlaylist mix) {
    final tokens = Theme.of(context).glass;

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.75,
            decoration: BoxDecoration(
              color: tokens.bgElevated,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(color: tokens.glassStroke),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tokens.textDim.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tokens.accent.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    mix.badge,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: tokens.accent,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    mix.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: tokens.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mix.subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: tokens.textDim,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: tokens.accent,
                          foregroundColor: tokens.onAccent,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () {
                          if (mix.tracks.isNotEmpty) {
                            ref
                                .read(playerControllerProvider.notifier)
                                .playTrack(mix.tracks.first, mix.tracks);
                            Navigator.pop(ctx);
                          }
                        },
                        icon: const Icon(LucideIcons.play, size: 16),
                        label: const Text('Play'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: mix.tracks.length,
                    itemBuilder: (c, i) {
                      final t = mix.tracks[i];
                      final isSuggested = mix.suggestedTrackIds.contains(t.id);

                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ArtworkImage(art: t.artwork, size: 44),
                        ),
                        title: Text(
                          t.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          t.artist.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: tokens.textDim),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSuggested
                                ? tokens.accent.withValues(alpha: 0.15)
                                : Colors.redAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isSuggested ? '✨ Suggested' : '❤️ Liked',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSuggested
                                  ? tokens.accent
                                  : Colors.redAccent,
                            ),
                          ),
                        ),
                        onTap: () {
                          ref
                              .read(playerControllerProvider.notifier)
                              .playTrack(t, mix.tracks);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
