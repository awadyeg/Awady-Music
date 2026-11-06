import 'dart:async';

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/catalog_providers.dart';
import 'package:awady_music/data/sources/audius/audius_client.dart';
import 'package:awady_music/data/sources/ytstream/stream_resolver_provider.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/widgets/artist_card.dart';
import 'package:awady_music/widgets/artwork_image.dart';
import 'package:awady_music/widgets/large_title_scaffold.dart';
import 'package:awady_music/widgets/media_card.dart';
import 'package:awady_music/widgets/mood_visual_style.dart';
import 'package:awady_music/widgets/section_header.dart';
import 'package:awady_music/widgets/skeletons.dart';
import 'package:awady_music/widgets/track_menu_sheet.dart';
import 'package:awady_music/widgets/track_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Active filter category for search results.
enum SearchFilter { all, songs, artists, playlists }

/// Notifier that triggers focusing the search field from the bottom bar.
class SearchFocusNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void trigger() {
    state++;
  }
}

final searchFocusTriggerProvider = NotifierProvider<SearchFocusNotifier, int>(
  SearchFocusNotifier.new,
);

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _submittedQuery = '';
  List<String> _suggestions = const [];
  bool _showSuggestions = false;
  Timer? _suggestTimer;
  SearchFilter _filter = SearchFilter.all;
  bool _expandedTracks = false;

  @override
  void dispose() {
    _suggestTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  TextDirection _detectDirection(String text) {
    return intl.Bidi.detectRtlDirectionality(text)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  void _onQueryChanged(String query) {
    _suggestTimer?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty || trimmed == _submittedQuery) {
      if (_suggestions.isNotEmpty || _showSuggestions) {
        setState(() {
          _suggestions = const [];
          _showSuggestions = false;
        });
      }
      return;
    }

    // Debounce suggestions by 250 ms per tasks.md T-43
    _suggestTimer = Timer(const Duration(milliseconds: 250), () async {
      if (!mounted) return;
      try {
        final suggs = await ref
            .read(catalogRepositoryProvider)
            .suggest(trimmed);
        if (!mounted) return;
        setState(() {
          _suggestions = suggs
              .where((s) => s.toLowerCase() != trimmed.toLowerCase())
              .toList();
          _showSuggestions = _suggestions.isNotEmpty;
        });
      } on Exception {
        // Ignore suggestion failures silently
      }
    });
  }

  void _submitSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    _suggestTimer?.cancel();
    _controller.text = trimmed;
    setState(() {
      _submittedQuery = trimmed;
      _suggestions = const [];
      _showSuggestions = false;
      _filter = SearchFilter.all;
      _expandedTracks = false;
    });
    _focusNode.unfocus();
  }

  void _clearSearch() {
    _suggestTimer?.cancel();
    _controller.clear();
    setState(() {
      _submittedQuery = '';
      _suggestions = const [];
      _showSuggestions = false;
      _filter = SearchFilter.all;
      _expandedTracks = false;
    });
  }

  void _focusSearchField() {
    _focusNode.requestFocus();
    unawaited(SystemChannels.textInput.invokeMethod<void>('TextInput.show'));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(searchFocusTriggerProvider, (previous, next) {
      if (next > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _focusSearchField();
          }
        });
      }
    });

    final l10n = context.l10n;
    final tokens = Theme.of(context).glass;

    return LargeTitleScaffold(
      title: l10n.searchAria,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: GestureDetector(
            onDoubleTap: _focusSearchField,
            behavior: HitTestBehavior.translucent,
            child: GlassSurface(
              radius: 24,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              child: Row(
                children: [
                  Icon(LucideIcons.search, size: 20, color: tokens.textDim),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textDirection: _detectDirection(_controller.text),
                      textInputAction: TextInputAction.search,
                      onSubmitted: _submitSearch,
                      onChanged: _onQueryChanged,
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.searchPlaceholder,
                        hintStyle: TextStyle(
                          color: tokens.textDim.withValues(alpha: 0.7),
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        LucideIcons.x,
                        size: 18,
                        color: tokens.textDim,
                      ),
                      tooltip: l10n.searchClear,
                      splashRadius: 18,
                      onPressed: _clearSearch,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      slivers: [
        // 1. Suggestions dropdown when typing
        if (_showSuggestions && _suggestions.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: GlassSurface(
                radius: 16,
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final item in _suggestions.take(6))
                      InkWell(
                        onTap: () => _submitSearch(item),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.search,
                                size: 16,
                                color: tokens.textDim,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item,
                                  textDirection: _detectDirection(item),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: tokens.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

        // 2. Main content: Empty state vs Search results
        if (_submittedQuery.isEmpty)
          ..._buildEmptyBrowseSlivers(context, tokens, l10n)
        else
          ..._buildSearchResultsSlivers(context, tokens, l10n),

        // Bottom inset for player and tab bar
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Empty State: Moods & Moments + Browse Genres
  // ---------------------------------------------------------------------------
  List<Widget> _buildEmptyBrowseSlivers(
    BuildContext context,
    GlassTokens tokens,
    L10n l10n,
  ) {
    final moodsAsync = ref.watch(moodCategoriesProvider);

    return [
      // Moods & moments header
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SectionHeader(title: l10n.searchMoods),
        ),
      ),

      // Moods grid
      moodsAsync.when(
        data: (moods) {
          final items = moods.take(12).toList();
          if (items.isEmpty) {
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 72,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final mood = items[index];
                return _BrowseTile(
                  title: mood.name,
                  onTap: () {
                    final enc = Uri.encodeComponent(mood.params);
                    unawaited(
                      context.push('/search/mood/$enc', extra: mood.name),
                    );
                  },
                );
              }, childCount: items.length),
            ),
          );
        },
        loading: () => const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CardsRowSkeleton(count: 4, cardWidth: 140),
          ),
        ),
        error: (err, stack) =>
            const SliverToBoxAdapter(child: SizedBox.shrink()),
      ),

      // Browse genres header
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: SectionHeader(title: l10n.searchBrowseGenres),
        ),
      ),

      // Browse genres grid
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 72,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final genre = audiusGenres[index];
            return _BrowseTile(
              title: genre,
              onTap: () {
                final enc = Uri.encodeComponent(genre);
                unawaited(context.push('/search/genre/$enc'));
              },
            );
          }, childCount: audiusGenres.length),
        ),
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Search Results State
  // ---------------------------------------------------------------------------
  List<Widget> _buildSearchResultsSlivers(
    BuildContext context,
    GlassTokens tokens,
    L10n l10n,
  ) {
    final searchAsync = ref.watch(searchProvider(_submittedQuery));

    return [
      searchAsync.when(
        data: (results) {
          final isCompletelyEmpty =
              results.songs.isEmpty &&
              results.artists.isEmpty &&
              results.playlists.isEmpty &&
              results.top == null;

          if (isCompletelyEmpty) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 60,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.searchX,
                        size: 52,
                        color: tokens.textDim.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.searchNoResults(_submittedQuery),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.searchNoResultsHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: tokens.textDim),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Trigger stream prefetch for top track in background
          if (results.songs.isNotEmpty) {
            final topTrack = results.songs.first;
            unawaited(
              ref
                  .read(streamResolverProvider)
                  .resolve(topTrack.streamId ?? topTrack.id)
                  .then((_) => null)
                  .catchError((_) => null),
            );
          }

          return SliverMainAxisGroup(
            slivers: [
              // Segmented filter chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'All',
                          filter: SearchFilter.all,
                          tokens: tokens,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label:
                              '${l10n.searchSongs} (${results.songs.length})',
                          filter: SearchFilter.songs,
                          tokens: tokens,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label:
                              '${l10n.searchArtists} '
                              '(${results.artists.length})',
                          filter: SearchFilter.artists,
                          tokens: tokens,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label:
                              '${l10n.searchPlaylistsAlbums} '
                              '(${results.playlists.length})',
                          filter: SearchFilter.playlists,
                          tokens: tokens,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Filtered Views
              if (_filter == SearchFilter.all) ...[
                // Top Result Card
                if (results.top != null) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: SectionHeader(title: l10n.searchTopResult),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _TopResultCard(
                        top: results.top!,
                        contextTracks: results.songs,
                      ),
                    ),
                  ),
                ],

                // Songs section (top 4 or expanded)
                if (results.songs.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: SectionHeader(title: l10n.searchSongs),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final track = results.songs[index];
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
                                .playTrack(track, results.songs);
                          },
                          onMoreTap: () => showTrackMenuSheet(
                            context: context,
                            track: track,
                          ),
                        );
                      },
                      childCount: _expandedTracks
                          ? results.songs.length
                          : (results.songs.length > 4
                                ? 4
                                : results.songs.length),
                    ),
                  ),
                  if (results.songs.length > 4)
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
                                _expandedTracks = !_expandedTracks;
                              });
                            },
                            child: Text(
                              _expandedTracks
                                  ? 'Show less'
                                  : l10n.searchMoreTracks,
                              style: TextStyle(
                                color: tokens.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],

                // Artists carousel
                if (results.artists.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: SectionHeader(title: l10n.searchArtists),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 190,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: results.artists.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, idx) {
                          final artist = results.artists[idx];
                          final rawId =
                              (artist.id.isNotEmpty && artist.id != 'yt-')
                              ? artist.id
                              : 'yt-${artist.name}';
                          return ArtistCard(
                            name: artist.name,
                            artwork: artist.profilePicture,
                            onTap: () => unawaited(
                              context.push(
                                '/artist/${Uri.encodeComponent(rawId)}?n=${Uri.encodeComponent(artist.name)}',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // Playlists & albums carousel
                if (results.playlists.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: SectionHeader(title: l10n.searchPlaylistsAlbums),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 230,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: results.playlists.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, idx) {
                          final pl = results.playlists[idx];
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
              ] else if (_filter == SearchFilter.songs) ...[
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final track = results.songs[index];
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
                            .playTrack(track, results.songs);
                      },
                      onMoreTap: () =>
                          showTrackMenuSheet(context: context, track: track),
                    );
                  }, childCount: results.songs.length),
                ),
              ] else if (_filter == SearchFilter.artists) ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 200,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final artist = results.artists[index];
                      final rawId = (artist.id.isNotEmpty && artist.id != 'yt-')
                          ? artist.id
                          : 'yt-${artist.name}';
                      return ArtistCard(
                        name: artist.name,
                        artwork: artist.profilePicture,
                        onTap: () => unawaited(
                          context.push(
                            '/artist/${Uri.encodeComponent(rawId)}?n=${Uri.encodeComponent(artist.name)}',
                          ),
                        ),
                      );
                    }, childCount: results.artists.length),
                  ),
                ),
              ] else if (_filter == SearchFilter.playlists) ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 230,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final pl = results.playlists[index];
                      return MediaCard(
                        title: pl.name,
                        subtitle: pl.owner.name,
                        artwork: pl.artwork,
                        onTap: () =>
                            unawaited(context.push('/playlist/${pl.id}')),
                      );
                    }, childCount: results.playlists.length),
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: RowsSkeleton(),
          ),
        ),
        error: (err, stack) => SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: GlassSurface(
              radius: 16,
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
                          l10n.searchFailed,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: tokens.textPrimary,
                          ),
                        ),
                        Text(
                          l10n.searchFailedHint,
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
                    onPressed: () =>
                        ref.refresh(searchProvider(_submittedQuery)),
                    child: Text(l10n.searchRetry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildFilterChip({
    required String label,
    required SearchFilter filter,
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
        child: GlassSurface(
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

// ---------------------------------------------------------------------------
// Browse Tile for Genres / Moods
// ---------------------------------------------------------------------------
class _BrowseTile extends StatelessWidget {
  const _BrowseTile({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = MoodVisualStyle.forTitle(title);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
                right: -12,
                top: -12,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: style.accentCircleColor,
                  ),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -8,
                child: Opacity(
                  opacity: 0.22,
                  child: Transform.rotate(
                    angle: 0.25,
                    child: Icon(style.icon, size: 52, color: Colors.white),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(blurRadius: 4, color: Color(0x66000000)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top Result Big Glass Card
// ---------------------------------------------------------------------------
class _TopResultCard extends ConsumerWidget {
  const _TopResultCard({required this.top, required this.contextTracks});

  final Object top;
  final List<Track> contextTracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;

    if (top is Track) {
      final track = top as Track;
      return InkWell(
        onTap: () {
          ref
              .read(playerControllerProvider.notifier)
              .playTrack(track, contextTracks);
        },
        borderRadius: BorderRadius.circular(20),
        child: GlassSurface(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ArtworkImage(art: track.artwork, size: 80),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      track.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection:
                          intl.Bidi.detectRtlDirectionality(track.title)
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.searchSong} · ${track.artist.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: tokens.textDim),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 24,
                backgroundColor: tokens.accent,
                child: const Icon(
                  LucideIcons.play,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (top is Artist) {
      final artist = top as Artist;
      final rawId = (artist.id.isNotEmpty && artist.id != 'yt-')
          ? artist.id
          : 'yt-${artist.name}';
      return InkWell(
        onTap: () => unawaited(
          context.push(
            '/artist/${Uri.encodeComponent(rawId)}?n=${Uri.encodeComponent(artist.name)}',
          ),
        ),
        borderRadius: BorderRadius.circular(20),
        child: GlassSurface(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ArtworkImage(art: artist.profilePicture, size: 80, radius: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      artist.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Artist',
                      style: TextStyle(fontSize: 13, color: tokens.textDim),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (top is RemotePlaylist) {
      final pl = top as RemotePlaylist;
      return InkWell(
        onTap: () => unawaited(context.push('/playlist/${pl.id}')),
        borderRadius: BorderRadius.circular(20),
        child: GlassSurface(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ArtworkImage(art: pl.artwork, size: 80),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pl.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Playlist · ${pl.owner.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: tokens.textDim),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
