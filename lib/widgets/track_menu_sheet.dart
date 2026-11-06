import 'dart:async';

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/core/util/format.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/downloads_repository.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/widgets/artwork_image.dart';
import 'package:awady_music/widgets/glass_sheet.dart';
import 'package:awady_music/widgets/glass_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

class TrackMenuSheet extends ConsumerWidget {
  const TrackMenuSheet({required this.track, super.key, this.localPlaylistId});

  final Track track;
  final String? localPlaylistId;

  TextDirection _detectDirection(String text) {
    return intl.Bidi.detectRtlDirectionality(text)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  void _showAddToPlaylistSubSheet(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;
    final libraryRepo = ref.read(libraryRepositoryProvider);
    final toastNotifier = ref.read(toastProvider.notifier);
    final playlists = libraryRepo.playlists;

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
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Text(
                      l10n.tableAddPlaylist,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: tokens.glassFill,
                      child: Icon(
                        LucideIcons.plus,
                        color: tokens.textPrimary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      l10n.tableNewPlaylist,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: tokens.textPrimary,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final nameController = TextEditingController();
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dCtx) => AlertDialog(
                          backgroundColor: tokens.bgElevated,
                          title: Text(
                            l10n.createPlaylist,
                            style: TextStyle(color: tokens.textPrimary),
                          ),
                          content: TextField(
                            controller: nameController,
                            autofocus: true,
                            style: TextStyle(color: tokens.textPrimary),
                            decoration: InputDecoration(
                              hintText: l10n.playlistNamePlaceholder,
                              hintStyle: TextStyle(color: tokens.textFaint),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dCtx, false),
                              child: Text(
                                l10n.cancel,
                                style: TextStyle(color: tokens.textDim),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(dCtx, true),
                              child: Text(
                                l10n.createPlaylist,
                                style: TextStyle(color: tokens.accent),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && context.mounted) {
                        final name = nameController.text.trim();
                        final id = libraryRepo.createPlaylist(
                          name.isNotEmpty ? name : null,
                        );
                        libraryRepo.addToPlaylist(id, track);
                        toastNotifier.show(l10n.tableAddedNewPlaylist);
                      }
                    },
                  ),
                  const Divider(height: 1),
                  if (playlists.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          l10n.playlistEmpty,
                          style: TextStyle(color: tokens.textDim),
                        ),
                      ),
                    ),
                  ] else ...[
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: playlists.length,
                        itemBuilder: (c, idx) {
                          final pl = playlists[idx];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: tokens.glassFill,
                              child: Icon(
                                LucideIcons.listMusic,
                                color: tokens.textDim,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              pl.name,
                              style: TextStyle(
                                color: tokens.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              '${pl.tracks.length} tracks',
                              style: TextStyle(
                                color: tokens.textFaint,
                                fontSize: 12,
                              ),
                            ),
                            onTap: () {
                              libraryRepo.addToPlaylist(pl.id, track);
                              Navigator.pop(ctx);
                              toastNotifier.show(
                                l10n.tableAddedToPlaylist(pl.name),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;
    final libraryRepo = ref.watch(libraryRepositoryProvider);
    final isLiked = libraryRepo.isLiked(track.id);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Track Header Info
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Row(
            children: [
              ArtworkImage(art: track.artwork, size: 52, radius: 10),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: _detectDirection(track.title),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      track.duration > 0
                          ? '${track.artist.name} · '
                                '${FormatUtils.formatDuration(track.duration)}'
                          : track.artist.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: _detectDirection(track.artist.name),
                      style: TextStyle(fontSize: 13, color: tokens.textDim),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: tokens.glassStroke),
        // Actions List
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Like / Unlike
                ListTile(
                  leading: Icon(
                    isLiked ? LucideIcons.heart : LucideIcons.heart,
                    color: isLiked ? Colors.redAccent : tokens.textPrimary,
                    size: 22,
                  ),
                  title: Text(
                    isLiked ? l10n.playerUnlike : l10n.playerLike,
                    style: TextStyle(color: tokens.textPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    libraryRepo.toggleLike(track);
                  },
                ),
                // Add to playlist
                ListTile(
                  leading: Icon(
                    LucideIcons.listPlus,
                    color: tokens.textPrimary,
                    size: 22,
                  ),
                  title: Text(
                    l10n.tableAddPlaylist,
                    style: TextStyle(color: tokens.textPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddToPlaylistSubSheet(context, ref);
                  },
                ),
                // Add to queue
                ListTile(
                  leading: Icon(
                    LucideIcons.listEnd,
                    color: tokens.textPrimary,
                    size: 22,
                  ),
                  title: Text(
                    l10n.tableAddQueue,
                    style: TextStyle(color: tokens.textPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(playerControllerProvider.notifier).enqueue(track);
                    ref.read(toastProvider.notifier).show(l10n.coreAddedQueue);
                  },
                ),
                // Play next
                ListTile(
                  leading: Icon(
                    LucideIcons.listStart,
                    color: tokens.textPrimary,
                    size: 22,
                  ),
                  title: Text(
                    l10n.tablePlayNext,
                    style: TextStyle(color: tokens.textPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ref
                        .read(playerControllerProvider.notifier)
                        .playNextUp(track);
                    ref.read(toastProvider.notifier).show(l10n.tablePlayNext);
                  },
                ),
                // Start radio
                ListTile(
                  leading: Icon(
                    LucideIcons.radio,
                    color: tokens.textPrimary,
                    size: 22,
                  ),
                  title: Text(
                    l10n.queueRadio,
                    style: TextStyle(color: tokens.textPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    unawaited(
                      ref
                          .read(playerControllerProvider.notifier)
                          .startRadio(track),
                    );
                  },
                ),
                // Go to artist
                if (track.artist.id.isNotEmpty ||
                    track.artist.name.isNotEmpty) ...[
                  ListTile(
                    leading: Icon(
                      LucideIcons.user,
                      color: tokens.textPrimary,
                      size: 22,
                    ),
                    title: Text(
                      l10n.goToArtist,
                      style: TextStyle(color: tokens.textPrimary),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      final rawId =
                          (track.artist.id.isNotEmpty &&
                              track.artist.id != 'yt-')
                          ? track.artist.id
                          : 'yt-${track.artist.name}';
                      final encodedId = Uri.encodeComponent(rawId);
                      final encodedName = Uri.encodeComponent(
                        track.artist.name,
                      );
                      unawaited(
                        context.push('/artist/$encodedId?n=$encodedName'),
                      );
                    },
                  ),
                ],
                // Go to album
                if (track.album?.id != null && track.album!.id.isNotEmpty) ...[
                  ListTile(
                    leading: Icon(
                      LucideIcons.disc,
                      color: tokens.textPrimary,
                      size: 22,
                    ),
                    title: Text(
                      l10n.goToAlbum,
                      style: TextStyle(color: tokens.textPrimary),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      unawaited(context.push('/playlist/${track.album!.id}'));
                    },
                  ),
                ],
                // Share link
                ListTile(
                  leading: Icon(
                    LucideIcons.share2,
                    color: tokens.textPrimary,
                    size: 22,
                  ),
                  title: Text(
                    l10n.shareTrack,
                    style: TextStyle(color: tokens.textPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    final cleanVid =
                        track.streamId ??
                        (track.id.startsWith('yt-')
                            ? track.id.substring(3)
                            : track.id);
                    final url = 'https://music.youtube.com/watch?v=$cleanVid';
                    unawaited(Clipboard.setData(ClipboardData(text: url)));
                    unawaited(
                      SharePlus.instance.share(
                        ShareParams(text: url, subject: track.title),
                      ),
                    );
                  },
                ),
                // Download / Remove download
                Builder(
                  builder: (ctx) {
                    final downloadsRepo = ref.read(downloadsRepositoryProvider);
                    final isDownloaded =
                        ref
                            .watch(downloadedTracksProvider)
                            .asData
                            ?.value
                            .any((t) => t.id == track.id) ??
                        false;
                    final progress = ref
                        .watch(downloadProgressStreamProvider)
                        .asData
                        ?.value[track.id];

                    if (progress?.status == DownloadStatus.downloading) {
                      final pct = (progress!.progress * 100).toInt().toString();
                      return ListTile(
                        leading: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            value: progress.progress > 0
                                ? progress.progress
                                : null,
                            strokeWidth: 2,
                            color: tokens.accent,
                          ),
                        ),
                        title: Text(
                          l10n.tableDownloading(pct),
                          style: TextStyle(color: tokens.textPrimary),
                        ),
                        trailing: IconButton(
                          icon: const Icon(LucideIcons.x, size: 18),
                          tooltip: l10n.downloadsCancel,
                          onPressed: () {
                            Navigator.pop(ctx);
                            downloadsRepo.cancelDownload(track.id);
                          },
                        ),
                      );
                    }

                    if (progress?.status == DownloadStatus.queued) {
                      return ListTile(
                        leading: Icon(
                          LucideIcons.clock,
                          color: tokens.textDim,
                          size: 22,
                        ),
                        title: Text(
                          l10n.downloadsQueued,
                          style: TextStyle(color: tokens.textPrimary),
                        ),
                        trailing: IconButton(
                          icon: const Icon(LucideIcons.x, size: 18),
                          tooltip: l10n.downloadsCancel,
                          onPressed: () {
                            Navigator.pop(ctx);
                            downloadsRepo.cancelDownload(track.id);
                          },
                        ),
                      );
                    }

                    if (isDownloaded) {
                      return ListTile(
                        leading: Icon(
                          LucideIcons.trash2,
                          color: tokens.danger,
                          size: 22,
                        ),
                        title: Text(
                          l10n.tableRemoveDownload,
                          style: TextStyle(color: tokens.danger),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          unawaited(downloadsRepo.deleteDownload(track.id));
                          ref
                              .read(toastProvider.notifier)
                              .show(l10n.tableRemoveDownload);
                        },
                      );
                    }

                    return ListTile(
                      leading: Icon(
                        LucideIcons.download,
                        color: tokens.textPrimary,
                        size: 22,
                      ),
                      title: Text(
                        l10n.tableDownload,
                        style: TextStyle(color: tokens.textPrimary),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        unawaited(downloadsRepo.enqueueDownload(track));
                        ref
                            .read(toastProvider.notifier)
                            .show(l10n.tableDownloading('0'));
                      },
                    );
                  },
                ),
                // Remove from playlist (local playlist context only)
                if (localPlaylistId != null) ...[
                  ListTile(
                    leading: Icon(
                      LucideIcons.trash2,
                      color: tokens.danger,
                      size: 22,
                    ),
                    title: Text(
                      l10n.tableRemoveFrom,
                      style: TextStyle(color: tokens.danger),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      libraryRepo.removeFromPlaylist(
                        localPlaylistId!,
                        track.id,
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> showTrackMenuSheet({
  required BuildContext context,
  required Track track,
  String? localPlaylistId,
}) {
  return showGlassBottomSheet<void>(
    context: context,
    builder: (context) =>
        TrackMenuSheet(track: track, localPlaylistId: localPlaylistId),
  );
}
