import 'dart:async';

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/data/models/artist_page.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/catalog_providers.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/widgets/artwork_image.dart';
import 'package:awady_music/widgets/media_card.dart';
import 'package:awady_music/widgets/section_header.dart';
import 'package:awady_music/widgets/skeletons.dart';
import 'package:awady_music/widgets/track_menu_sheet.dart';
import 'package:awady_music/widgets/track_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ArtistScreen extends ConsumerStatefulWidget {
  const ArtistScreen({required this.id, super.key, this.nameHint});

  final String id;
  final String? nameHint;

  @override
  ConsumerState<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends ConsumerState<ArtistScreen> {
  bool _showAllTracks = false;
  bool _bioExpanded = false;

  String _formatNumber(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  String get _providerKey =>
      (widget.nameHint != null && widget.nameHint!.trim().isNotEmpty)
      ? '${widget.id}\t${widget.nameHint!.trim()}'
      : widget.id;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = Theme.of(context).glass;
    final artistAsync = ref.watch(artistPageProvider(_providerKey));

    return Scaffold(
      backgroundColor: tokens.bg,
      body: artistAsync.when(
        data: (data) => _buildContent(context, tokens, l10n, data),
        loading: () => CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: tokens.bg,
              flexibleSpace: Container(color: tokens.bgElevated),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: RowsSkeleton(),
              ),
            ),
          ],
        ),
        error: (err, stack) => _buildError(context, tokens, l10n),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    GlassTokens tokens,
    L10n l10n,
    ArtistPage data,
  ) {
    final artist = data.artist;
    final isFollowed = ref.watch(
      libraryRepositoryProvider.select((repo) => repo.isFollowing(artist.id)),
    );

    final listenersText = artist.id.startsWith('yt-')
        ? l10n.artistMonthlyListeners(_formatNumber(artist.followerCount))
        : l10n.artistStats(
            _formatNumber(artist.followerCount),
            artist.trackCount.toString(),
          );

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        // 1. Stretchy Header with Artist Image & Details
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          stretch: true,
          backgroundColor: tokens.bg,
          leading: IconButton(
            tooltip: 'Back',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.arrowLeft, color: Colors.white),
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.blurBackground,
            ],
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Background cover/profile image
                if (artist.profilePicture != null || artist.coverPhoto != null)
                  ArtworkImage(
                    art: artist.profilePicture,
                    url: artist.coverPhoto,
                    radius: 0,
                  )
                else
                  Container(color: tokens.bgElevated),

                // Dark gradient overlay
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.6),
                        tokens.bg,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),

                // Artist info bottom-aligned
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Circular avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: ArtworkImage(
                          art: artist.profilePicture,
                          size: 76,
                          radius: 38,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (artist.isVerified)
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.badgeCheck,
                                    size: 15,
                                    color: tokens.accent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.artistVerified,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: tokens.accent,
                                    ),
                                  ),
                                ],
                              ),
                            Text(
                              artist.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textDirection:
                                  intl.Bidi.detectRtlDirectionality(artist.name)
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              listenersText,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Buttons Row: Play, Shuffle, Follow
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                if (data.topSongs.isNotEmpty) ...[
                  // Play button (accent capsule)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tokens.accent,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      ref
                          .read(playerControllerProvider.notifier)
                          .playTrack(data.topSongs.first, data.topSongs);
                    },
                    icon: const Icon(
                      LucideIcons.play,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(
                      l10n.artistPlay,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Shuffle button (glass capsule)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: tokens.textPrimary,
                      side: BorderSide(color: tokens.glassStroke),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      final shuffled = List<Track>.from(data.topSongs)
                        ..shuffle();
                      ref
                          .read(playerControllerProvider.notifier)
                          .playTrack(shuffled.first, shuffled);
                    },
                    icon: Icon(
                      LucideIcons.shuffle,
                      size: 16,
                      color: tokens.textPrimary,
                    ),
                    label: const Text(
                      'Shuffle',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],

                // Follow button (glass capsule)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isFollowed
                        ? tokens.accent
                        : tokens.textPrimary,
                    side: BorderSide(
                      color: isFollowed ? tokens.accent : tokens.glassStroke,
                    ),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    ref.read(libraryRepositoryProvider).toggleFollow(artist);
                  },
                  icon: Icon(
                    isFollowed ? LucideIcons.userCheck : LucideIcons.userPlus,
                    size: 16,
                  ),
                  label: Text(
                    isFollowed ? l10n.artistFollowing : l10n.artistFollow,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Popular Tracks Section (Top 5 or See All)
        if (data.topSongs.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SectionHeader(title: l10n.artistPopular),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final track = data.topSongs[index];
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
                        .playTrack(track, data.topSongs);
                  },
                  onMoreTap: () =>
                      showTrackMenuSheet(context: context, track: track),
                );
              },
              childCount: _showAllTracks
                  ? data.topSongs.length
                  : (data.topSongs.length > 5 ? 5 : data.topSongs.length),
            ),
          ),
          if (data.topSongs.length > 5)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _showAllTracks = !_showAllTracks;
                      });
                    },
                    child: Text(
                      _showAllTracks
                          ? l10n.artistShowLess
                          : l10n.artistShowAll(data.topSongs.length.toString()),
                      style: TextStyle(
                        color: tokens.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ] else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Text(
                l10n.artistNoTracks,
                style: TextStyle(fontSize: 14, color: tokens.textDim),
              ),
            ),
          ),

        // 4. Albums Carousel
        if (data.albums.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: SectionHeader(title: l10n.artistAlbums),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: data.albums.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, idx) {
                  final album = data.albums[idx];
                  return MediaCard(
                    title: album.name,
                    subtitle: album.trackCount > 0
                        ? '${album.trackCount} tracks'
                        : null,
                    artwork: album.artwork,
                    onTap: () =>
                        unawaited(context.push('/playlist/${album.id}')),
                  );
                },
              ),
            ),
          ),
        ],

        // 5. Singles Carousel
        if (data.singles.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: SectionHeader(title: l10n.artistSingles),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: data.singles.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, idx) {
                  final single = data.singles[idx];
                  return MediaCard(
                    title: single.name,
                    artwork: single.artwork,
                    onTap: () =>
                        unawaited(context.push('/playlist/${single.id}')),
                  );
                },
              ),
            ),
          ),
        ],

        // 6. About Section (Glass Card with expandable bio)
        if (data.bio != null && data.bio!.trim().isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: SectionHeader(title: l10n.artistAbout),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassSurface(
                radius: 16,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.bio!.trim(),
                      maxLines: _bioExpanded ? null : 4,
                      overflow: _bioExpanded ? null : TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: tokens.textDim,
                      ),
                    ),
                    if (data.bio!.trim().length > 180) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() => _bioExpanded = !_bioExpanded);
                        },
                        child: Text(
                          _bioExpanded ? 'Read less' : 'Read more',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: tokens.accent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],

        // Bottom inset
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  Widget _buildError(BuildContext context, GlassTokens tokens, L10n l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: tokens.bgElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.userX, color: tokens.textDim, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.artistNotFound,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.nameHint != null
                  ? l10n.artistNotFoundNamed(widget.nameHint!)
                  : l10n.artistNotFoundSub,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: tokens.textDim),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: tokens.textPrimary,
                side: BorderSide(color: tokens.glassStroke),
                shape: const StadiumBorder(),
              ),
              onPressed: () => ref.refresh(artistPageProvider(_providerKey)),
              child: Text(l10n.artistRetry),
            ),
          ],
        ),
      ),
    );
  }
}
