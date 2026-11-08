import 'dart:async';

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/data/db/app_database.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/artwork.dart';
import 'package:awady_music/data/models/local_playlist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/widgets/artwork_image.dart';
import 'package:awady_music/widgets/collage_cover.dart';
import 'package:awady_music/widgets/import_sheet.dart';
import 'package:awady_music/widgets/large_title_scaffold.dart';
import 'package:awady_music/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Available filter categories on the Library screen.
enum LibraryFilter { all, playlists, artists, downloads }

/// Sort order for playlists on the Library screen.
enum LibrarySort { recent, name, count }

/// Provider for the number of downloaded tracks.
final downloadsCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.downloadsDao.watchAllDownloads().map((list) => list.length);
});

/// Library screen displaying user playlists, followed artists, liked tracks,
/// recent tracks, and downloads.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  LibraryFilter _selectedFilter = LibraryFilter.all;
  LibrarySort _sort = LibrarySort.recent;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  TextDirection _detectDirection(String text) {
    return intl.Bidi.detectRtlDirectionality(text)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  void _showCreatePlaylistDialog(
    BuildContext context,
    L10n l10n,
    GlassTokens tokens,
  ) {
    final libraryRepo = ref.read(libraryRepositoryProvider);
    final defaultName = nextPlaylistName(libraryRepo.playlists);
    final controller = TextEditingController(text: defaultName);

    unawaited(
      showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: tokens.bgElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
            ),
            title: Text(
              l10n.libraryNewPlaylist,
              style: TextStyle(color: tokens.textPrimary),
            ),
            content: TextField(
              controller: controller,
              autofocus: true,
              style: TextStyle(color: tokens.textPrimary),
              decoration: InputDecoration(
                hintText: l10n.playlistNamePlaceholder,
                hintStyle: TextStyle(color: tokens.textDim),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: tokens.accent),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(color: tokens.textDim),
                ),
              ),
              TextButton(
                onPressed: () {
                  final text = controller.text.trim();
                  Navigator.pop(ctx);
                  final name = text.isNotEmpty ? text : defaultName;
                  final newId = libraryRepo.createPlaylist(name);
                  try {
                    unawaited(context.push('/playlist/$newId'));
                  } on Object catch (_) {}
                },
                child: Text(
                  l10n.createPlaylist,
                  style: TextStyle(color: tokens.accent),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;
    final libraryRepo = ref.watch(libraryRepositoryProvider);
    ref
      ..watch(likedTracksStreamProvider)
      ..watch(playlistsStreamProvider)
      ..watch(followedArtistsStreamProvider);
    final downloadsCountAsync = ref.watch(downloadsCountProvider);
    final downloadsCount = downloadsCountAsync.value ?? 0;

    final likedCount = libraryRepo.likedTracks.length;
    final recentsCount = libraryRepo.recents.length;
    final query = _query.trim().toLowerCase();
    final playlists = _visiblePlaylists(libraryRepo.playlists, query);
    final followedArtists = _visibleArtists(libraryRepo.followedArtists, query);
    final matchedTracks = query.isEmpty
        ? const <Track>[]
        : libraryRepo.likedTracks
              .where(
                (track) =>
                    track.title.toLowerCase().contains(query) ||
                    track.artist.name.toLowerCase().contains(query) ||
                    (track.album?.name.toLowerCase().contains(query) ?? false),
              )
              .take(30)
              .toList();

    final showPlaylists =
        _selectedFilter == LibraryFilter.all ||
        _selectedFilter == LibraryFilter.playlists;
    final showArtists =
        _selectedFilter == LibraryFilter.all ||
        _selectedFilter == LibraryFilter.artists;
    final showDownloads =
        _selectedFilter == LibraryFilter.all ||
        _selectedFilter == LibraryFilter.downloads;
    final showMatches =
        query.isNotEmpty &&
        _selectedFilter != LibraryFilter.artists &&
        _selectedFilter != LibraryFilter.downloads;

    return LargeTitleScaffold(
      title: l10n.sideYourLibrary,
      actions: [
        IconButton(
          key: const Key('library_import_button'),
          icon: const Icon(LucideIcons.link2, size: 22),
          tooltip: l10n.importTitle,
          onPressed: () => showImportSheet(context),
        ),
        IconButton(
          icon: const Icon(LucideIcons.settings, size: 22),
          tooltip: l10n.settingsTitle,
          onPressed: () => context.push('/settings'),
        ),
      ],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: GlassSurface(
          radius: 24,
          child: InkWell(
            onTap: () => _showCreatePlaylistDialog(context, l10n, tokens),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.plus, size: 18, color: tokens.accent),
                  const SizedBox(width: 8),
                  Text(
                    l10n.libraryNewPlaylist,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: tokens.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
            child: Row(
              children: [
                Expanded(child: _buildSearchField(tokens, l10n)),
                PopupMenuButton<LibrarySort>(
                  key: const Key('library_sort_button'),
                  tooltip: l10n.playlistSort,
                  initialValue: _sort,
                  onSelected: (value) => setState(() => _sort = value),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: LibrarySort.recent,
                      child: Text(l10n.librarySortRecent),
                    ),
                    PopupMenuItem(
                      value: LibrarySort.name,
                      child: Text(l10n.librarySortName),
                    ),
                    PopupMenuItem(
                      value: LibrarySort.count,
                      child: Text(l10n.librarySortTracks),
                    ),
                  ],
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      LucideIcons.arrowUpDown,
                      color: tokens.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Filter Chips row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: l10n.allFilter,
                    selected: _selectedFilter == LibraryFilter.all,
                    onTap: () {
                      setState(() {
                        _selectedFilter = LibraryFilter.all;
                      });
                    },
                    tokens: tokens,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: l10n.libraryPlaylistLabel,
                    selected: _selectedFilter == LibraryFilter.playlists,
                    onTap: () {
                      setState(() {
                        _selectedFilter =
                            _selectedFilter == LibraryFilter.playlists
                            ? LibraryFilter.all
                            : LibraryFilter.playlists;
                      });
                    },
                    tokens: tokens,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: l10n.artistsFilter,
                    selected: _selectedFilter == LibraryFilter.artists,
                    onTap: () {
                      setState(() {
                        _selectedFilter =
                            _selectedFilter == LibraryFilter.artists
                            ? LibraryFilter.all
                            : LibraryFilter.artists;
                      });
                    },
                    tokens: tokens,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: l10n.sideDownloads,
                    selected: _selectedFilter == LibraryFilter.downloads,
                    onTap: () {
                      setState(() {
                        _selectedFilter =
                            _selectedFilter == LibraryFilter.downloads
                            ? LibraryFilter.all
                            : LibraryFilter.downloads;
                      });
                    },
                    tokens: tokens,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Pinned Rows Section (Liked Songs, Downloads, Recently played)
        if (query.isEmpty &&
            (_selectedFilter == LibraryFilter.all ||
                _selectedFilter == LibraryFilter.playlists ||
                _selectedFilter == LibraryFilter.downloads))
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  if (_selectedFilter == LibraryFilter.all ||
                      _selectedFilter == LibraryFilter.playlists) ...[
                    _buildPinnedRow(
                      icon: LucideIcons.heart,
                      iconColor: const Color(0xFFE91E63),
                      title: l10n.libraryLikedSongs,
                      subtitle: l10n.libraryTrackCount(likedCount.toString()),
                      onTap: () => context.push('/library/liked'),
                      tokens: tokens,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (showDownloads) ...[
                    _buildPinnedRow(
                      icon: LucideIcons.arrowDownToLine,
                      iconColor: tokens.accent,
                      title: l10n.sideDownloads,
                      subtitle: l10n.libraryTrackCount(
                        downloadsCount.toString(),
                      ),
                      onTap: () => context.push('/library/downloads'),
                      tokens: tokens,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (_selectedFilter == LibraryFilter.all ||
                      _selectedFilter == LibraryFilter.playlists) ...[
                    _buildPinnedRow(
                      icon: LucideIcons.history,
                      iconColor: const Color(0xFF2196F3),
                      title: l10n.libraryRecents,
                      subtitle: l10n.libraryTrackCount(recentsCount.toString()),
                      onTap: () => context.push('/library/recent'),
                      tokens: tokens,
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),

        // Your Playlists Section
        if (showPlaylists) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: SectionHeader(title: l10n.libraryYourPlaylists),
            ),
          ),
          if (playlists.isEmpty && query.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Text(
                  l10n.libraryEmptyPlaylists,
                  style: TextStyle(fontSize: 14, color: tokens.textDim),
                ),
              ),
            )
          else
            SliverList.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final p = playlists[index];
                final artList = p.tracks
                    .map((t) => t.artwork)
                    .whereType<Artwork>()
                    .toList();
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: CollageCover(
                    artworks: artList,
                    size: 52,
                    radius: 10,
                  ),
                  title: Text(
                    p.name,
                    textDirection: _detectDirection(p.name),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${l10n.libraryPlaylistLabel} · '
                    '${l10n.libraryTrackCount(p.tracks.length.toString())}',
                    style: TextStyle(fontSize: 13, color: tokens.textDim),
                  ),
                  trailing: _forwardChevron(tokens),
                  onTap: () => context.push('/playlist/${p.id}'),
                );
              },
            ),
        ],

        // Followed Artists Section
        if (showArtists) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: SectionHeader(title: l10n.libraryFollowed),
            ),
          ),
          if (followedArtists.isEmpty && query.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Text(
                  l10n.libraryEmptyArtists,
                  style: TextStyle(fontSize: 14, color: tokens.textDim),
                ),
              ),
            )
          else
            SliverList.builder(
              itemCount: followedArtists.length,
              itemBuilder: (context, index) {
                final artist = followedArtists[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: ClipOval(
                    child: ArtworkImage(
                      art: artist.profilePicture,
                      size: 52,
                      radius: 26,
                    ),
                  ),
                  title: Text(
                    artist.name,
                    textDirection: _detectDirection(artist.name),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    l10n.libraryArtistLabel,
                    style: TextStyle(fontSize: 13, color: tokens.textDim),
                  ),
                  trailing: _forwardChevron(tokens),
                  onTap: () {
                    final rawId = (artist.id.isNotEmpty && artist.id != 'yt-')
                        ? artist.id
                        : 'yt-${artist.name}';
                    unawaited(
                      context.push(
                        '/artist/${Uri.encodeComponent(rawId)}?n=${Uri.encodeComponent(artist.name)}',
                      ),
                    );
                  },
                );
              },
            ),
        ],

        if (showMatches && matchedTracks.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: SectionHeader(title: l10n.libraryMatchingSongs),
            ),
          ),
          SliverList.builder(
            itemCount: matchedTracks.length,
            itemBuilder: (context, index) {
              final track = matchedTracks[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                minVerticalPadding: 10,
                leading: ArtworkImage(art: track.artwork),
                title: Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: _detectDirection(track.title),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: tokens.textPrimary,
                  ),
                ),
                subtitle: Text(
                  track.artist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: _detectDirection(track.artist.name),
                  style: TextStyle(fontSize: 13, color: tokens.textDim),
                ),
                onTap: () => ref
                    .read(playerControllerProvider.notifier)
                    .playTrack(track, matchedTracks),
              );
            },
          ),
        ],
        if (query.isNotEmpty &&
            !(showPlaylists && playlists.isNotEmpty) &&
            !(showArtists && followedArtists.isNotEmpty) &&
            !(showMatches && matchedTracks.isNotEmpty))
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: Text(
                l10n.libraryNoResults,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: tokens.textDim),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  List<LocalPlaylist> _visiblePlaylists(
    List<LocalPlaylist> playlists,
    String query,
  ) {
    final filtered = query.isEmpty
        ? [...playlists]
        : playlists.where((playlist) {
            if (playlist.name.toLowerCase().contains(query)) return true;
            return playlist.tracks.any(
              (track) =>
                  track.title.toLowerCase().contains(query) ||
                  track.artist.name.toLowerCase().contains(query),
            );
          }).toList();
    switch (_sort) {
      case LibrarySort.name:
        filtered.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
      case LibrarySort.count:
        filtered.sort((a, b) {
          final byCount = b.tracks.length.compareTo(a.tracks.length);
          if (byCount != 0) return byCount;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      case LibrarySort.recent:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return filtered;
  }

  List<Artist> _visibleArtists(List<Artist> artists, String query) {
    final filtered = query.isEmpty
        ? [...artists]
        : artists
              .where((artist) => artist.name.toLowerCase().contains(query))
              .toList();
    if (_sort == LibrarySort.name) {
      filtered.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    }
    return filtered;
  }

  Widget _buildSearchField(GlassTokens tokens, L10n l10n) {
    return TextField(
      key: const Key('library_search_field'),
      controller: _searchController,
      textInputAction: TextInputAction.search,
      style: TextStyle(color: tokens.textPrimary, fontSize: 15),
      cursorColor: tokens.accent,
      onChanged: (value) => setState(() => _query = value),
      decoration: InputDecoration(
        isDense: true,
        hintText: l10n.librarySearchHint,
        hintStyle: TextStyle(color: tokens.textDim),
        prefixIcon: Icon(LucideIcons.search, size: 18, color: tokens.textDim),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                tooltip: l10n.cancel,
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
                icon: Icon(LucideIcons.x, size: 18, color: tokens.textDim),
              ),
        filled: true,
        fillColor: tokens.glassFill,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: tokens.glassStroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: tokens.glassStroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: tokens.accent),
        ),
      ),
    );
  }

  Widget _forwardChevron(GlassTokens tokens) {
    final icon = Icon(
      LucideIcons.chevronRight,
      size: 18,
      color: tokens.textFaint,
    );
    if (Directionality.of(context) == TextDirection.rtl) {
      return Transform.flip(flipX: true, child: icon);
    }
    return icon;
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required GlassTokens tokens,
  }) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? tokens.accent : tokens.glassFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? tokens.accent : tokens.glassStroke,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color: selected ? tokens.onAccent : tokens.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinnedRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required GlassTokens tokens,
  }) {
    return GlassSurface(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Icon(icon, size: 24, color: iconColor)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: tokens.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: tokens.textDim),
                    ),
                  ],
                ),
              ),
              _forwardChevron(tokens),
            ],
          ),
        ),
      ),
    );
  }
}
