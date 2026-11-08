import 'dart:async';

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/data/models/artwork.dart';
import 'package:awady_music/data/models/local_playlist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/catalog_providers.dart';
import 'package:awady_music/data/repositories/downloads_repository.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/widgets/artwork_image.dart';
import 'package:awady_music/widgets/collage_cover.dart';
import 'package:awady_music/widgets/glass_sheet.dart';
import 'package:awady_music/widgets/glass_toast.dart';
import 'package:awady_music/widgets/import_sheet.dart';
import 'package:awady_music/widgets/skeletons.dart';
import 'package:awady_music/widgets/track_menu_sheet.dart';
import 'package:awady_music/widgets/track_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The kind of playlist being displayed.
enum PlaylistKind { remote, album, local, liked, recent }

/// Screen displaying a playlist, album, liked songs, or recently played tracks.
class PlaylistScreen extends ConsumerStatefulWidget {
  const PlaylistScreen({required this.id, super.key, this.kind});

  final String id;
  final PlaylistKind? kind;

  @override
  ConsumerState<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends ConsumerState<PlaylistScreen> {
  bool _isEditMode = false;

  PlaylistKind _resolveKind(LibraryRepository libraryRepo) {
    if (widget.kind != null) {
      return widget.kind!;
    }
    if (widget.id == 'liked') {
      return PlaylistKind.liked;
    }
    if (widget.id == 'recent') {
      return PlaylistKind.recent;
    }
    if (widget.id.startsWith('local-') ||
        libraryRepo.getPlaylist(widget.id) != null) {
      return PlaylistKind.local;
    }
    if (widget.id.startsWith('ytalb-') || widget.id.startsWith('MPREb_')) {
      return PlaylistKind.album;
    }
    return PlaylistKind.remote;
  }

  TextDirection _detectDirection(String text) {
    return intl.Bidi.detectRtlDirectionality(text)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  String _formatTotalDuration(int totalSeconds) {
    if (totalSeconds <= 0) return '0 min';
    if (totalSeconds >= 3600) {
      final hours = totalSeconds ~/ 3600;
      final minutes = (totalSeconds % 3600) ~/ 60;
      return '$hours hr $minutes min';
    }
    final minutes = (totalSeconds / 60).ceil();
    return '$minutes min';
  }

  void _playAll(List<Track> tracks) {
    if (tracks.isEmpty) return;
    ref.read(playerControllerProvider.notifier).playContext(tracks, 0);
  }

  void _shuffleAll(List<Track> tracks) {
    if (tracks.isEmpty) return;
    final shuffled = List<Track>.from(tracks)..shuffle();
    ref.read(playerControllerProvider.notifier).playContext(shuffled, 0);
  }

  void _downloadAll(List<Track> tracks, L10n l10n) {
    if (tracks.isEmpty) return;
    final repo = ref.read(downloadsRepositoryProvider);
    for (final track in tracks) {
      unawaited(repo.enqueueDownload(track));
    }
    ref
        .read(toastProvider.notifier)
        .show(l10n.playlistDownloading(tracks.length.toString()));
  }

  void _saveToLibrary({
    required String name,
    required List<Track> tracks,
    required L10n l10n,
  }) {
    final libraryRepo = ref.read(libraryRepositoryProvider);
    final newId = libraryRepo.createPlaylist(name);
    libraryRepo.addTracksToPlaylist(newId, tracks);
    ref.read(toastProvider.notifier).show(l10n.playlistSaveToLibrary);
  }

  void _showSortSheet({
    required BuildContext context,
    required L10n l10n,
    required GlassTokens tokens,
  }) {
    unawaited(
      showGlassBottomSheet<void>(
        context: context,
        builder: (ctx) {
          return Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      l10n.playlistSort,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: tokens.textPrimary,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      LucideIcons.type,
                      size: 20,
                      color: tokens.textDim,
                    ),
                    title: Text(
                      l10n.playlistSortTitle,
                      style: TextStyle(color: tokens.textPrimary),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      ref
                          .read(libraryRepositoryProvider)
                          .sortPlaylist(widget.id, PlaylistSortMode.title);
                      setState(() {});
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      LucideIcons.user,
                      size: 20,
                      color: tokens.textDim,
                    ),
                    title: Text(
                      l10n.playlistSortArtist,
                      style: TextStyle(color: tokens.textPrimary),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      ref
                          .read(libraryRepositoryProvider)
                          .sortPlaylist(widget.id, PlaylistSortMode.artist);
                      setState(() {});
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      LucideIcons.clock,
                      size: 20,
                      color: tokens.textDim,
                    ),
                    title: Text(
                      l10n.playlistSortDuration,
                      style: TextStyle(color: tokens.textPrimary),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      ref
                          .read(libraryRepositoryProvider)
                          .sortPlaylist(widget.id, PlaylistSortMode.duration);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRenameDialog({
    required BuildContext context,
    required String currentName,
    required L10n l10n,
    required GlassTokens tokens,
  }) {
    final controller = TextEditingController(text: currentName);
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
              l10n.playlistRename,
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
                child: Text('Cancel', style: TextStyle(color: tokens.textDim)),
              ),
              TextButton(
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    ref
                        .read(libraryRepositoryProvider)
                        .renamePlaylist(widget.id, text);
                    setState(() {});
                  }
                  Navigator.pop(ctx);
                },
                child: Text('Save', style: TextStyle(color: tokens.accent)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmDialog({
    required BuildContext context,
    required L10n l10n,
    required GlassTokens tokens,
  }) {
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
              l10n.playlistDelete,
              style: TextStyle(color: tokens.textPrimary),
            ),
            content: Text(
              l10n.deletePlaylistConfirm,
              style: TextStyle(color: tokens.textDim),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: TextStyle(color: tokens.textDim)),
              ),
              TextButton(
                onPressed: () {
                  ref.read(libraryRepositoryProvider).deletePlaylist(widget.id);
                  Navigator.pop(ctx);
                  if (context.canPop()) {
                    context.pop();
                  }
                },
                child: Text(
                  l10n.playlistDelete,
                  style: TextStyle(color: tokens.danger),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showActionMenu({
    required BuildContext context,
    required String name,
    required List<Track> tracks,
    required bool isLocal,
    required L10n l10n,
    required GlassTokens tokens,
    LocalPlaylist? localPlaylist,
  }) {
    unawaited(
      showGlassBottomSheet<void>(
        context: context,
        builder: (ctx) {
          return Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isLocal) ...[
                    ListTile(
                      leading: Icon(
                        LucideIcons.bookmark,
                        size: 22,
                        color: tokens.textPrimary,
                      ),
                      title: Text(
                        l10n.playlistSaveToLibrary,
                        style: TextStyle(color: tokens.textPrimary),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _saveToLibrary(name: name, tracks: tracks, l10n: l10n);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        LucideIcons.share2,
                        size: 22,
                        color: tokens.textPrimary,
                      ),
                      title: Text(
                        l10n.sharePlaylist,
                        style: TextStyle(color: tokens.textPrimary),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        ref
                            .read(toastProvider.notifier)
                            .show(l10n.playlistCopyLink);
                      },
                    ),
                  ] else ...[
                    ListTile(
                      leading: Icon(
                        LucideIcons.pencil,
                        size: 22,
                        color: tokens.textPrimary,
                      ),
                      title: Text(
                        l10n.playlistRename,
                        style: TextStyle(color: tokens.textPrimary),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showRenameDialog(
                          context: context,
                          currentName: name,
                          l10n: l10n,
                          tokens: tokens,
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        LucideIcons.arrowUpDown,
                        size: 22,
                        color: tokens.textPrimary,
                      ),
                      title: Text(
                        l10n.playlistSort,
                        style: TextStyle(color: tokens.textPrimary),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showSortSheet(
                          context: context,
                          l10n: l10n,
                          tokens: tokens,
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        LucideIcons.share2,
                        size: 22,
                        color: tokens.textPrimary,
                      ),
                      title: Text(
                        l10n.playlistExport,
                        style: TextStyle(color: tokens.textPrimary),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        if (localPlaylist != null) {
                          playlistExportJson(localPlaylist);
                          ref
                              .read(toastProvider.notifier)
                              .show(l10n.playlistExported);
                        }
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        LucideIcons.trash2,
                        size: 22,
                        color: tokens.danger,
                      ),
                      title: Text(
                        l10n.playlistDelete,
                        style: TextStyle(color: tokens.danger),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showDeleteConfirmDialog(
                          context: context,
                          l10n: l10n,
                          tokens: tokens,
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
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
    final resolvedKind = _resolveKind(libraryRepo);

    switch (resolvedKind) {
      case PlaylistKind.liked:
        final likedAsync = ref.watch(likedTracksStreamProvider);
        var tracks = likedAsync.asData?.value ?? const <Track>[];
        if (tracks.isEmpty) {
          try {
            tracks = libraryRepo.likedTracks;
          } on Object catch (_) {}
        }
        return _buildView(
          context: context,
          tokens: tokens,
          l10n: l10n,
          title: l10n.libraryLikedSongs,
          owner: null,
          tracks: tracks,
          artworkWidget: CollageCover(
            artworks: tracks
                .map((t) => t.artwork)
                .whereType<Artwork>()
                .toList(),
            size: 220,
          ),
          isLocal: false,
          canEdit: false,
        );

      case PlaylistKind.recent:
        final tracks = libraryRepo.recents;
        return _buildView(
          context: context,
          tokens: tokens,
          l10n: l10n,
          title: l10n.libraryRecents,
          owner: null,
          tracks: tracks,
          artworkWidget: CollageCover(
            artworks: tracks
                .map((t) => t.artwork)
                .whereType<Artwork>()
                .toList(),
            size: 220,
          ),
          isLocal: false,
          canEdit: false,
        );

      case PlaylistKind.local:
        ref.watch(playlistsStreamProvider);
        final playlist = libraryRepo.getPlaylist(widget.id);
        if (playlist == null) {
          return _buildNotFound(context, tokens, l10n);
        }
        return _buildView(
          context: context,
          tokens: tokens,
          l10n: l10n,
          title: playlist.name,
          owner: null,
          tracks: playlist.tracks,
          artworkWidget: CollageCover(
            artworks: playlist.tracks
                .map((t) => t.artwork)
                .whereType<Artwork>()
                .toList(),
            size: 220,
          ),
          isLocal: true,
          canEdit: true,
          localPlaylist: playlist,
        );

      case PlaylistKind.album:
        final albumAsync = ref.watch(albumPageProvider(widget.id));
        return albumAsync.when(
          data: (page) => _buildView(
            context: context,
            tokens: tokens,
            l10n: l10n,
            title: page.playlist.name,
            owner: page.playlist.owner.name,
            tracks: page.tracks,
            artworkWidget: ArtworkImage(
              art: page.playlist.artwork,
              size: 220,
              radius: GlassTokens.radiusCard,
            ),
            isLocal: false,
            canEdit: false,
          ),
          loading: () => _buildLoading(context, tokens),
          error: (err, stack) => _buildError(
            context: context,
            tokens: tokens,
            l10n: l10n,
            onRetry: () => ref.invalidate(albumPageProvider(widget.id)),
          ),
        );

      case PlaylistKind.remote:
        final playlistAsync = ref.watch(playlistPageProvider(widget.id));
        return playlistAsync.when(
          data: (page) => _buildView(
            context: context,
            tokens: tokens,
            l10n: l10n,
            title: page.playlist.name,
            owner: page.playlist.owner.name,
            tracks: page.tracks,
            artworkWidget: ArtworkImage(
              art: page.playlist.artwork,
              size: 220,
              radius: GlassTokens.radiusCard,
            ),
            isLocal: false,
            canEdit: false,
          ),
          loading: () => _buildLoading(context, tokens),
          error: (err, stack) => _buildError(
            context: context,
            tokens: tokens,
            l10n: l10n,
            onRetry: () => ref.invalidate(playlistPageProvider(widget.id)),
          ),
        );
    }
  }

  Widget _buildLoading(BuildContext context, GlassTokens tokens) {
    return Scaffold(
      backgroundColor: tokens.bg,
      body: const CustomScrollView(
        physics: NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(pinned: true, backgroundColor: Colors.transparent),
          SliverToBoxAdapter(child: HeroSkeleton()),
          SliverToBoxAdapter(child: RowsSkeleton(count: 6)),
        ],
      ),
    );
  }

  Widget _buildError({
    required BuildContext context,
    required GlassTokens tokens,
    required L10n l10n,
    required VoidCallback onRetry,
  }) {
    return Scaffold(
      backgroundColor: tokens.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.circleAlert, size: 48, color: tokens.danger),
              const SizedBox(height: 16),
              Text(
                l10n.playlistTracksError,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: tokens.textDim),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.accent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: onRetry,
                icon: const Icon(LucideIcons.refreshCw, size: 18),
                label: Text(l10n.playlistRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context, GlassTokens tokens, L10n l10n) {
    return Scaffold(
      backgroundColor: tokens.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.music, size: 54, color: tokens.textDim),
              const SizedBox(height: 16),
              Text(
                l10n.playlistNotFound,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.playlistNotFoundLocalSub,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: tokens.textDim),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildView({
    required BuildContext context,
    required GlassTokens tokens,
    required L10n l10n,
    required String title,
    required String? owner,
    required List<Track> tracks,
    required Widget artworkWidget,
    required bool isLocal,
    required bool canEdit,
    LocalPlaylist? localPlaylist,
  }) {
    final totalSeconds = tracks.fold<int>(0, (sum, t) => sum + t.duration);
    final countStr = l10n.playlistTrackCount(tracks.length.toString());
    final durationStr = _formatTotalDuration(totalSeconds);
    final subtitle = owner != null && owner.isNotEmpty
        ? '$owner · $countStr · $durationStr'
        : '$countStr · $durationStr';

    final pendingCount = tracks.where((t) => t.pending).length;
    final matchedCount = tracks.length - pendingCount;
    final hasPending = pendingCount > 0;

    final currentTrackId = ref.watch(
      playerControllerProvider.select((s) => s.current?.id),
    );

    return Scaffold(
      backgroundColor: tokens.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: tokens.bg.withValues(alpha: 0.8),
            elevation: 0,
            leading: Navigator.canPop(context) ? const BackButton() : null,
            title: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // 220 Cover
                  Center(child: artworkWidget),
                  const SizedBox(height: 20),
                  // Title
                  Text(
                    title,
                    textDirection: _detectDirection(title),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: tokens.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Owner · tracks · duration
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: tokens.textDim),
                  ),
                  // Pending matching pill
                  if (hasPending) ...[
                    const SizedBox(height: 12),
                    ContentSurface(
                      radius: 16,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.matchingProgress(
                                matchedCount.toString(),
                                tracks.length.toString(),
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                color: tokens.textDim,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Play button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tokens.accent,
                          foregroundColor: tokens.onAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        onPressed: tracks.isNotEmpty
                            ? () => _playAll(tracks)
                            : null,
                        icon: const Icon(LucideIcons.play, size: 20),
                        label: Text(
                          l10n.playlistPlay,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Shuffle button
                      IconButton.filledTonal(
                        style: IconButton.styleFrom(
                          backgroundColor: tokens.glassFill,
                          foregroundColor: tokens.textPrimary,
                        ),
                        onPressed: tracks.isNotEmpty
                            ? () => _shuffleAll(tracks)
                            : null,
                        icon: const Icon(LucideIcons.shuffle, size: 20),
                        tooltip: 'Shuffle',
                      ),
                      const SizedBox(width: 10),
                      // Download all button
                      IconButton.filledTonal(
                        style: IconButton.styleFrom(
                          backgroundColor: tokens.glassFill,
                          foregroundColor: tokens.textPrimary,
                        ),
                        onPressed: tracks.isNotEmpty
                            ? () => _downloadAll(tracks, l10n)
                            : null,
                        icon: const Icon(LucideIcons.arrowDownToLine, size: 20),
                        tooltip: l10n.playlistDownloadAll,
                      ),
                      if (canEdit) ...[
                        const SizedBox(width: 10),
                        // Edit mode toggle button
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: _isEditMode
                                ? tokens.accent.withValues(alpha: 0.25)
                                : tokens.glassFill,
                            foregroundColor: _isEditMode
                                ? tokens.accent
                                : tokens.textPrimary,
                          ),
                          onPressed: () {
                            setState(() {
                              _isEditMode = !_isEditMode;
                            });
                          },
                          icon: Icon(
                            _isEditMode
                                ? LucideIcons.check
                                : LucideIcons.pencil,
                            size: 20,
                          ),
                          tooltip: 'Edit playlist',
                        ),
                      ],
                      const SizedBox(width: 10),
                      // More menu button
                      IconButton.filledTonal(
                        style: IconButton.styleFrom(
                          backgroundColor: tokens.glassFill,
                          foregroundColor: tokens.textPrimary,
                        ),
                        onPressed: () => _showActionMenu(
                          context: context,
                          name: title,
                          tracks: tracks,
                          isLocal: isLocal,
                          l10n: l10n,
                          tokens: tokens,
                          localPlaylist: localPlaylist,
                        ),
                        icon: const Icon(LucideIcons.ellipsis, size: 20),
                        tooltip: 'More',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (tracks.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.music, size: 56, color: tokens.textDim),
                      const SizedBox(height: 16),
                      Text(
                        l10n.playlistEmptyLocalTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.playlistEmptyLocalSub,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: tokens.textDim),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tokens.accent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () => context.go('/search'),
                        icon: const Icon(LucideIcons.search, size: 18),
                        label: Text(l10n.playlistFindSongs),
                      ),
                      if (widget.id == 'liked') ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: tokens.textPrimary,
                            side: BorderSide(color: tokens.glassStroke),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () => unawaited(
                            showImportSheet(
                              context,
                              initialDestination: ImportDestination.liked,
                            ),
                          ),
                          icon: const Icon(LucideIcons.link2, size: 18),
                          label: Text(l10n.importPlaylistTitle),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
          else if (_isEditMode && canEdit)
            SliverReorderableList(
              itemCount: tracks.length,
              // Deprecated in Flutter 3.41 in favor of onReorderItem.
              // ignore: deprecated_member_use
              onReorder: (oldIndex, newIndex) {
                var target = newIndex;
                if (target > oldIndex) {
                  target -= 1;
                }
                if (target >= tracks.length) {
                  target = tracks.length - 1;
                }
                ref
                    .read(libraryRepositoryProvider)
                    .moveInPlaylist(widget.id, oldIndex, target);
                setState(() {});
              },
              itemBuilder: (context, index) {
                final track = tracks[index];
                return Material(
                  key: ValueKey(track.id),
                  color: Colors.transparent,
                  child: TrackTile(
                    title: track.title,
                    artist: track.artist.name,
                    artwork: track.artwork,
                    duration: track.duration,
                    isPlaying: currentTrackId == track.id,
                    isPending: track.pending,
                    leading: ReorderableDragStartListener(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          LucideIcons.gripVertical,
                          size: 20,
                          color: tokens.textDim,
                        ),
                      ),
                    ),
                    showTrailing: false,
                  ),
                );
              },
            )
          else
            SliverList.builder(
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index];
                return TrackTile(
                  key: ValueKey('${track.id}_$index'),
                  title: track.title,
                  artist: track.artist.name,
                  artwork: track.artwork,
                  duration: track.duration,
                  isPlaying: currentTrackId == track.id,
                  isPending: track.pending,
                  leading: SizedBox(
                    width: 24,
                    child: Text(
                      '${index + 1}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: tokens.textDim,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  onTap: () {
                    ref
                        .read(playerControllerProvider.notifier)
                        .playContext(tracks, index);
                  },
                  onMoreTap: () {
                    unawaited(
                      showTrackMenuSheet(
                        context: context,
                        track: track,
                        localPlaylistId: isLocal ? widget.id : null,
                      ),
                    );
                  },
                );
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
