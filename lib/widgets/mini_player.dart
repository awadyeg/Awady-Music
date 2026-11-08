import 'dart:async';

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/widgets/artwork_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:lucide_icons_flutter/lucide_icons.dart';

Widget _mirrorRtl(Widget child, {required bool mirror}) {
  if (!mirror) return child;
  return Transform.flip(flipX: true, child: child);
}

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerControllerProvider);
    final track = playerState.current;

    if (track == null) {
      return const SizedBox.shrink();
    }

    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final durationMs = playerState.duration.inMilliseconds > 0
        ? playerState.duration.inMilliseconds
        : (track.duration > 0 ? track.duration * 1000 : 0);
    final progress = durationMs > 0
        ? (playerState.currentTime.inMilliseconds / durationMs).clamp(0.0, 1.0)
        : 0.0;

    return Semantics(
      label: '${track.title}, ${track.artist.name}',
      button: true,
      hint: l10n.playerOpenNowPlaying,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.push('/now-playing'),
        onVerticalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity < -200) {
            unawaited(context.push('/now-playing'));
          }
        },
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity < -200) {
            if (isRtl) {
              ref.read(playerControllerProvider.notifier).prev();
            } else {
              ref.read(playerControllerProvider.notifier).next();
            }
          } else if (velocity > 200) {
            if (isRtl) {
              ref.read(playerControllerProvider.notifier).next();
            } else {
              ref.read(playerControllerProvider.notifier).prev();
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 60,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GlassSurface(
                    radius: GlassTokens.radiusCapsule,
                    strong: true,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        ArtworkImage(art: track.artwork, size: 44, radius: 10),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textDirection:
                                    Bidi.detectRtlDirectionality(track.title)
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: tokens.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                track.artist.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textDirection:
                                    Bidi.detectRtlDirectionality(
                                      track.artist.name,
                                    )
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: tokens.textDim,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: playerState.buffering
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: tokens.textPrimary,
                                  ),
                                )
                              : _mirrorRtl(
                                  Icon(
                                    playerState.isPlaying
                                        ? LucideIcons.pause
                                        : LucideIcons.play,
                                    size: 22,
                                    color: tokens.textPrimary,
                                  ),
                                  mirror: isRtl && !playerState.isPlaying,
                                ),
                          tooltip: playerState.isPlaying
                              ? l10n.playerPause
                              : l10n.playerPlay,
                          onPressed: () => ref
                              .read(playerControllerProvider.notifier)
                              .toggle(),
                        ),
                        IconButton(
                          icon: _mirrorRtl(
                            Icon(
                              LucideIcons.skipForward,
                              size: 22,
                              color: tokens.textPrimary,
                            ),
                            mirror: isRtl,
                          ),
                          tooltip: l10n.playerNext,
                          onPressed: () => ref
                              .read(playerControllerProvider.notifier)
                              .next(),
                        ),
                      ],
                    ),
                  ),
                ),
                // Thin progress line at the bottom edge clipped to capsule
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(GlassTokens.radiusCapsule),
                    ),
                    child: Container(
                      height: 2.5,
                      alignment: isRtl
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(color: tokens.accent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
