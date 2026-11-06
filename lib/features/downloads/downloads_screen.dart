import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/data/repositories/downloads_repository.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/widgets/large_title_scaffold.dart';
import 'package:awady_music/widgets/track_menu_sheet.dart';
import 'package:awady_music/widgets/track_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;
    final downloadedAsync = ref.watch(downloadedTracksProvider);
    final progressMapAsync = ref.watch(downloadProgressStreamProvider);
    final currentTrack = ref.watch(
      playerControllerProvider.select((s) => s.current),
    );
    final isPlaying = ref.watch(
      playerControllerProvider.select((s) => s.isPlaying),
    );

    final tracks = downloadedAsync.asData?.value ?? [];
    final activeDownloads = (progressMapAsync.asData?.value ?? {}).values
        .where(
          (p) =>
              p.status == DownloadStatus.downloading ||
              p.status == DownloadStatus.queued,
        )
        .toList();

    return LargeTitleScaffold(
      title: l10n.downloadsTitle,
      actions: [
        if (tracks.isNotEmpty)
          IconButton(
            key: const Key('downloads_play_all'),
            icon: const Icon(LucideIcons.play),
            tooltip: l10n.downloadsPlayAll,
            onPressed: () {
              ref
                  .read(playerControllerProvider.notifier)
                  .playContext(tracks, 0);
            },
          ),
      ],
      slivers: [
        if (tracks.isNotEmpty || activeDownloads.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.downloadsSubtitle(tracks.length.toString()),
                      style: TextStyle(fontSize: 13, color: tokens.textDim),
                    ),
                  ),
                  if (tracks.isNotEmpty)
                    TextButton.icon(
                      key: const Key('downloads_play_all_button'),
                      icon: const Icon(LucideIcons.play, size: 16),
                      label: Text(l10n.downloadsPlayAll),
                      onPressed: () {
                        ref
                            .read(playerControllerProvider.notifier)
                            .playContext(tracks, 0);
                      },
                    ),
                ],
              ),
            ),
          ),

        // Active In-Progress Downloads
        if (activeDownloads.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = activeDownloads[index];
              final isQueued = item.status == DownloadStatus.queued;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tokens.bgElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: tokens.glassStroke),
                ),
                child: Row(
                  children: [
                    if (isQueued)
                      Container(
                        key: const Key('download_queued_badge'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: tokens.textDim.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          l10n.downloadsQueued,
                          style: TextStyle(
                            fontSize: 11,
                            color: tokens.textDim,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          value: item.progress > 0 ? item.progress : null,
                          strokeWidth: 2.5,
                          color: tokens.accent,
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isQueued
                            ? l10n.downloadsQueued
                            : l10n.tableDownloading(
                                (item.progress * 100).toInt().toString(),
                              ),
                        style: TextStyle(
                          fontSize: 13,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      key: Key('download_cancel_${item.trackId}'),
                      icon: const Icon(LucideIcons.x, size: 18),
                      tooltip: l10n.downloadsCancel,
                      onPressed: () {
                        ref
                            .read(downloadsRepositoryProvider)
                            .cancelDownload(item.trackId);
                      },
                    ),
                  ],
                ),
              );
            }, childCount: activeDownloads.length),
          ),

        // Downloaded tracks list or Empty state
        if (tracks.isEmpty && activeDownloads.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: tokens.bgElevated,
                        shape: BoxShape.circle,
                        border: Border.all(color: tokens.glassStroke),
                      ),
                      child: Icon(
                        LucideIcons.download,
                        size: 40,
                        color: tokens.textDim,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.downloadsEmptyTitle,
                      key: const Key('downloads_empty_title'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: tokens.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.downloadsEmptyHint,
                      key: const Key('downloads_empty_hint'),
                      style: TextStyle(fontSize: 13, color: tokens.textDim),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      key: const Key('downloads_empty_cta'),
                      onPressed: () => context.go('/search'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tokens.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.downloadsEmptyCta,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final track = tracks[index];
              final isThisPlaying = isPlaying && currentTrack?.id == track.id;

              return TrackTile(
                title: track.title,
                artist: track.artist.name,
                artwork: track.artwork,
                duration: track.duration,
                isDownloaded: true,
                isPlaying: isThisPlaying,
                onTap: () {
                  ref
                      .read(playerControllerProvider.notifier)
                      .playContext(tracks, index);
                },
                onMoreTap: () =>
                    showTrackMenuSheet(context: context, track: track),
              );
            }, childCount: tracks.length),
          ),
      ],
    );
  }
}
