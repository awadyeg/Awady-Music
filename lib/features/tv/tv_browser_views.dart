import 'dart:async';

import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/data/models/mood_models.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/catalog_providers.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/features/tv/tv_focus_button.dart';
import 'package:awady_music/widgets/artwork_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// TV Home View with horizontally scrollable D-pad navigable carousels.
class TvHomeView extends ConsumerWidget {
  const TvHomeView({required this.onSelectTrack, super.key});

  final void Function(Track track, List<Track> queue, int index) onSelectTrack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).glass;
    final trendingAsync = ref.watch(trendingTracksProvider);
    final recommendedAsync = ref.watch(recommendedForYouProvider);
    final chartsAsync = ref.watch(chartsProvider);
    final libraryRepo = ref.watch(libraryRepositoryProvider);
    final likedTracks = libraryRepo.likedTracks;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 24, 72),
      children: [
        // 1. Trending Now
        _buildSectionHeader('Trending Now', LucideIcons.flame, tokens),
        const SizedBox(height: 8),
        trendingAsync.when(
          data: (page) => _buildTrackCarousel(page.items, tokens),
          loading: () => _buildLoadingStrip(tokens),
          error: (_, _) => _buildErrorStrip('Trending unavailable', tokens),
        ),
        const SizedBox(height: 20),

        // 2. Liked / Quick Picks (if user has likes)
        if (likedTracks.isNotEmpty) ...[
          _buildSectionHeader('Your Quick Picks', LucideIcons.heart, tokens),
          const SizedBox(height: 8),
          _buildTrackCarousel(likedTracks, tokens),
          const SizedBox(height: 20),
        ],

        // 3. Recommended For You
        _buildSectionHeader(
          'Recommended For You',
          LucideIcons.sparkles,
          tokens,
        ),
        const SizedBox(height: 8),
        recommendedAsync.when(
          data: (page) => _buildTrackCarousel(page.items, tokens),
          loading: () => _buildLoadingStrip(tokens),
          error: (_, _) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 20),

        // 4. Top Charts
        _buildSectionHeader('Top Charts', LucideIcons.trophy, tokens),
        const SizedBox(height: 8),
        chartsAsync.when(
          data: (page) => _buildTrackCarousel(page.items, tokens),
          loading: () => _buildLoadingStrip(tokens),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, GlassTokens tokens) {
    return Row(
      children: [
        Icon(icon, color: tokens.accent, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: tokens.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTrackCarousel(List<Track> tracks, GlassTokens tokens) {
    if (tracks.isEmpty) {
      return Text(
        'No tracks available',
        style: TextStyle(fontSize: 13, color: tokens.textDim),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tracks.length,
        itemBuilder: (context, i) {
          final t = tracks[i];
          return Container(
            width: 124,
            margin: const EdgeInsets.only(right: 14),
            child: TvFocusButton(
              onPressed: () => onSelectTrack(t, tracks, i),
              borderRadius: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 124,
                      height: 104,
                      child: ArtworkImage(art: t.artwork, size: 240),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
                  ),
                  Text(
                    t.artist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: tokens.textDim),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingStrip(GlassTokens tokens) {
    return SizedBox(
      height: 140,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: tokens.accent,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorStrip(String msg, GlassTokens tokens) {
    return SizedBox(
      height: 60,
      child: Center(
        child: Text(msg, style: TextStyle(color: tokens.textDim, fontSize: 13)),
      ),
    );
  }
}

/// TV Search View with TV-friendly genre & mood tiles and instant search.
class TvSearchView extends ConsumerStatefulWidget {
  const TvSearchView({required this.onSelectTrack, super.key});

  final void Function(Track track, List<Track> queue, int index) onSelectTrack;

  @override
  ConsumerState<TvSearchView> createState() => _TvSearchViewState();
}

class _TvSearchViewState extends ConsumerState<TvSearchView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _activeQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;
    final moodCategoriesAsync = ref.watch(moodCategoriesProvider);
    final moodCategories = moodCategoriesAsync.value ?? const <MoodCategory>[];
    final searchAsync = _activeQuery.trim().isNotEmpty
        ? ref.watch(searchProvider(_activeQuery.trim()))
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 24, 72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: tokens.glassFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: tokens.glassStroke),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: TextStyle(color: tokens.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        LucideIcons.search,
                        color: tokens.accent,
                        size: 18,
                      ),
                      hintText: 'Search songs, artists, or genres...',
                      hintStyle: TextStyle(color: tokens.textDim, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (val) {
                      setState(() => _activeQuery = val.trim());
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TvFocusButton(
                onPressed: () {
                  setState(() => _activeQuery = _searchCtrl.text.trim());
                },
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: tokens.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: tokens.onAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Results or Mood/Genre browse cards
          Expanded(
            child: searchAsync != null
                ? searchAsync.when(
                    data: (results) {
                      final tracks = results.tracks;
                      if (tracks.isEmpty) {
                        return Center(
                          child: Text(
                            'No results found for "$_activeQuery"',
                            style: TextStyle(
                              color: tokens.textDim,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: tracks.length,
                        itemBuilder: (context, i) {
                          final t = tracks[i];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: TvFocusButton(
                              onPressed: () =>
                                  widget.onSelectTrack(t, tracks, i),
                              borderRadius: 12,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: tokens.glassFill,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SizedBox(
                                        width: 44,
                                        height: 44,
                                        child: ArtworkImage(
                                          art: t.artwork,
                                          size: 88,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: tokens.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            t.artist.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: tokens.textDim,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      LucideIcons.play,
                                      color: tokens.accent,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => Center(
                      child: CircularProgressIndicator(
                        color: tokens.accent,
                        strokeWidth: 2,
                      ),
                    ),
                    error: (_, _) => Center(
                      child: Text(
                        'Search error occurred',
                        style: TextStyle(color: tokens.textDim),
                      ),
                    ),
                  )
                : _buildMoodGrid(moodCategories, tokens),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodGrid(List<MoodCategory> categories, GlassTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Browse Categories & Moods',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.8,
            ),
            itemCount: categories.length > 9 ? 9 : categories.length,
            itemBuilder: (context, i) {
              final cat = categories[i];
              return TvFocusButton(
                onPressed: () {
                  _searchCtrl.text = cat.name;
                  setState(() => _activeQuery = cat.name);
                },
                borderRadius: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: tokens.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: tokens.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(LucideIcons.music, color: tokens.accent, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          cat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: tokens.textPrimary,
                          ),
                        ),
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
}

/// TV Library View displaying Liked songs and Local playlists with direct
/// D-pad selection.
class TvLibraryView extends ConsumerWidget {
  const TvLibraryView({required this.onSelectTrack, super.key});

  final void Function(Track track, List<Track> queue, int index) onSelectTrack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).glass;
    final libraryRepo = ref.watch(libraryRepositoryProvider);
    final likedTracks = libraryRepo.likedTracks;
    final playlists = libraryRepo.playlists;
    final displayCount = likedTracks.length > 10 ? 10 : likedTracks.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 24, 72),
      children: [
        // Liked Songs Section
        Row(
          children: [
            const Icon(LucideIcons.heart, color: Color(0xFFFF1744), size: 20),
            const SizedBox(width: 8),
            Text(
              'Liked Songs (${likedTracks.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: tokens.textPrimary,
              ),
            ),
            const Spacer(),
            if (likedTracks.isNotEmpty)
              TvFocusButton(
                onPressed: () =>
                    onSelectTrack(likedTracks.first, likedTracks, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.play, color: tokens.onAccent, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Play All',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: tokens.onAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (likedTracks.isEmpty)
          Text(
            'No liked songs yet',
            style: TextStyle(color: tokens.textDim, fontSize: 13),
          )
        else
          for (int i = 0; i < displayCount; i++)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 3),
              child: TvFocusButton(
                onPressed: () => onSelectTrack(likedTracks[i], likedTracks, i),
                borderRadius: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.glassFill,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: tokens.textDim,
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: ArtworkImage(
                            art: likedTracks[i].artwork,
                            size: 72,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              likedTracks[i].title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: tokens.textPrimary,
                              ),
                            ),
                            Text(
                              likedTracks[i].artist.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: tokens.textDim,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(LucideIcons.play, color: tokens.accent, size: 16),
                    ],
                  ),
                ),
              ),
            ),
        const SizedBox(height: 24),

        // Playlists Section
        Row(
          children: [
            Icon(LucideIcons.listMusic, color: tokens.accent, size: 20),
            const SizedBox(width: 8),
            Text(
              'Your Playlists (${playlists.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: tokens.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (playlists.isEmpty)
          Text(
            'No playlists created yet',
            style: TextStyle(color: tokens.textDim, fontSize: 13),
          )
        else
          for (final pl in playlists)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: TvFocusButton(
                onPressed: () {
                  if (pl.tracks.isNotEmpty) {
                    onSelectTrack(pl.tracks.first, pl.tracks, 0);
                  }
                },
                borderRadius: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.glassFill,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.disc, color: tokens.accent, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          pl.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: tokens.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${pl.tracks.length} songs',
                        style: TextStyle(fontSize: 12, color: tokens.textDim),
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

/// TV Settings View.
class TvSettingsView extends ConsumerWidget {
  const TvSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).glass;
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 24, 72),
      children: [
        Text(
          'TV Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // TV Mode
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tokens.glassFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: tokens.glassStroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TV Mode Behavior',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildOptionBtn(
                    label: 'Auto',
                    selected: settings.tvMode == 'auto',
                    onTap: () => unawaited(settingsNotifier.setTvMode('auto')),
                    tokens: tokens,
                  ),
                  const SizedBox(width: 10),
                  _buildOptionBtn(
                    label: 'Always On',
                    selected: settings.tvMode == 'on',
                    onTap: () => unawaited(settingsNotifier.setTvMode('on')),
                    tokens: tokens,
                  ),
                  const SizedBox(width: 10),
                  _buildOptionBtn(
                    label: 'Disabled',
                    selected: settings.tvMode == 'off',
                    onTap: () => unawaited(settingsNotifier.setTvMode('off')),
                    tokens: tokens,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Awady Connect Receiver Toggle
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tokens.glassFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: tokens.glassStroke),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Awady Connect Receiver',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Allow casting & remote control from phones on '
                      'local Wi-Fi',
                      style: TextStyle(fontSize: 12, color: tokens.textDim),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: settings.enableConnectReceiver,
                activeTrackColor: tokens.accent,
                onChanged: (val) {
                  unawaited(
                    settingsNotifier.setEnableConnectReceiver(enabled: val),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionBtn({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required GlassTokens tokens,
  }) {
    return TvFocusButton(
      onPressed: onTap,
      borderRadius: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? tokens.accent.withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? tokens.accent : tokens.glassStroke,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: selected ? tokens.accent : tokens.textDim,
          ),
        ),
      ),
    );
  }
}
