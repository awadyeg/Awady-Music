import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/widgets/glass_toast.dart';
import 'package:awady_music/widgets/section_header.dart';
import 'package:awady_music/widgets/track_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerControllerProvider);
    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;

    final currentTrack = playerState.current;
    final queue = playerState.queue;
    final currentIndex = playerState.index;

    final upcomingTracks =
        (currentIndex >= 0 && currentIndex < queue.length - 1)
        ? queue.sublist(currentIndex + 1)
        : <Track>[];

    return Scaffold(
      backgroundColor: tokens.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          l10n.queueTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: tokens.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(LucideIcons.x, color: tokens.textPrimary),
          tooltip: l10n.queueClose,
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Now playing section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(title: l10n.queueNowPlaying),
                        if (currentTrack != null) ...[
                          TrackTile(
                            title: currentTrack.title,
                            artist: currentTrack.artist.name,
                            artwork: currentTrack.artwork,
                            duration: currentTrack.duration,
                            isPlaying: playerState.isPlaying,
                          ),
                        ] else ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              l10n.queueEmpty,
                              style: TextStyle(
                                fontSize: 14,
                                color: tokens.textDim,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        // Autoplay toggle row
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: tokens.glassFill,
                            borderRadius: BorderRadius.circular(
                              GlassTokens.radiusSmall,
                            ),
                            border: Border.all(color: tokens.glassStroke),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.sparkles,
                                size: 20,
                                color: tokens.textPrimary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.queueAutoplay,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: tokens.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      l10n.settingsAutoplaySub,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: tokens.textDim,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: playerState.autoplay,
                                activeThumbColor: tokens.accent,
                                onChanged: (v) {
                                  ref
                                      .read(playerControllerProvider.notifier)
                                      .setAutoplay(value: v);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SectionHeader(
                          title:
                              '${l10n.queueNextUp} (${upcomingTracks.length})',
                        ),
                      ],
                    ),
                  ),
                ),
                // Next up list or empty hint
                if (upcomingTracks.isEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.listEnd,
                            size: 40,
                            color: tokens.textFaint,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.queueEmpty,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: tokens.textDim,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.queueEndHint,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: tokens.textFaint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  SliverReorderableList(
                    itemCount: upcomingTracks.length,
                    // Flutter 3.41 deprecates onReorder
                    // in favor of onReorderItem.
                    // ignore: deprecated_member_use
                    onReorder: (oldRel, newRel) {
                      final oldIndex = currentIndex + 1 + oldRel;
                      final targetRel = newRel > oldRel ? newRel - 1 : newRel;
                      final targetIndex = currentIndex + 1 + targetRel;
                      ref
                          .read(playerControllerProvider.notifier)
                          .moveInQueue(oldIndex, targetIndex);
                    },
                    itemBuilder: (context, relIndex) {
                      final track = upcomingTracks[relIndex];
                      final actualIndex = currentIndex + 1 + relIndex;

                      return ReorderableDelayedDragStartListener(
                        key: ValueKey('${track.id}_$actualIndex'),
                        index: relIndex,
                        child: Dismissible(
                          key: ValueKey('dismiss_${track.id}_$actualIndex'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: tokens.danger,
                            child: const Icon(
                              LucideIcons.trash2,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            ref
                                .read(playerControllerProvider.notifier)
                                .removeAt(actualIndex);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TrackTile(
                              title: track.title,
                              artist: track.artist.name,
                              artwork: track.artwork,
                              duration: track.duration,
                              onTap: () {
                                ref
                                    .read(playerControllerProvider.notifier)
                                    .jumpTo(actualIndex);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 140)),
              ],
            ),
          ),
          // Footer actions
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.viewPaddingOf(context).bottom + 12,
            ),
            decoration: BoxDecoration(
              color: tokens.bgElevated,
              border: Border(top: BorderSide(color: tokens.glassStroke)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: tokens.textPrimary,
                      side: BorderSide(color: tokens.glassStroke),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(LucideIcons.listPlus, size: 18),
                    label: Text(
                      l10n.queueSaveAs,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: queue.isEmpty
                        ? null
                        : () {
                            final now = DateTime.now();
                            final name =
                                'Queue ${now.month}/${now.day} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
                            final libraryRepo = ref.read(
                              libraryRepositoryProvider,
                            );
                            final playlistId = libraryRepo.createPlaylist(name);
                            libraryRepo.addTracksToPlaylist(playlistId, queue);
                            ref
                                .read(toastProvider.notifier)
                                .show(l10n.queueSavedAsPlaylist);
                          },
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tokens.danger,
                    side: BorderSide(
                      color: tokens.danger.withValues(alpha: 0.5),
                    ),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(LucideIcons.trash2, size: 18),
                  label: Text(l10n.queueClear),
                  onPressed: queue.isEmpty
                      ? null
                      : () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: tokens.bgElevated,
                              title: Text(
                                l10n.queueClear,
                                style: TextStyle(color: tokens.textPrimary),
                              ),
                              content: Text(
                                l10n.queueClearQuestion,
                                style: TextStyle(color: tokens.textDim),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(
                                    l10n.cancel,
                                    style: TextStyle(color: tokens.textDim),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(
                                    l10n.queueClear,
                                    style: TextStyle(color: tokens.danger),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            ref
                                .read(playerControllerProvider.notifier)
                                .clearQueue();
                          }
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
