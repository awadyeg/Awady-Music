import 'dart:async';
import 'dart:ui';

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/core/util/format.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/widgets/artwork_image.dart';
import 'package:awady_music/widgets/glass_slider.dart';
import 'package:awady_music/widgets/track_menu_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> {
  double? _scrubPositionMs;

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerControllerProvider);
    final track = playerState.current;
    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;

    if (track == null) {
      return Scaffold(
        backgroundColor: tokens.bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(LucideIcons.chevronDown, color: tokens.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.music, size: 56, color: tokens.textFaint),
              const SizedBox(height: 16),
              Text(
                l10n.playerPick,
                style: TextStyle(
                  fontSize: 16,
                  color: tokens.textDim,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.accent,
                  foregroundColor: tokens.onAccent,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () => context.go('/search'),
                child: Text(l10n.navSearch),
              ),
            ],
          ),
        ),
      );
    }

    final isLiked = ref.watch(
      libraryRepositoryProvider.select((repo) => repo.isLiked(track.id)),
    );

    final durationSecs = playerState.duration.inSeconds > 0
        ? playerState.duration.inSeconds
        : track.duration;
    final durationMs = durationSecs * 1000;
    final currentMs =
        _scrubPositionMs ?? playerState.currentTime.inMilliseconds.toDouble();
    final clampedCurrentMs = currentMs.clamp(
      0.0,
      durationMs > 0 ? durationMs.toDouble() : 0.0,
    );

    final elapsedLabel = FormatUtils.formatDuration(
      (clampedCurrentMs / 1000).toInt(),
    );
    final remainingSecs = durationSecs - (clampedCurrentMs / 1000).toInt();
    final remainingLabel =
        '-${FormatUtils.formatDuration(remainingSecs > 0 ? remainingSecs : 0)}';

    final artworkUrl =
        track.artwork?.s1000 ?? track.artwork?.s480 ?? track.artwork?.fallback;

    return Scaffold(
      backgroundColor: tokens.bg,
      body: Stack(
        children: [
          // Blurred artwork wash background
          if (artworkUrl != null) ...[
            Positioned.fill(
              child: Opacity(
                opacity: 0.28,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
                  child: ArtworkImage(
                    art: track.artwork,
                    size: double.infinity,
                  ),
                ),
              ),
            ),
          ],
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    tokens.bg.withValues(alpha: 0.55),
                    tokens.bg.withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          LucideIcons.chevronDown,
                          color: tokens.textPrimary,
                        ),
                        tooltip: 'Close',
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.playerNowPlaying.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: tokens.textFaint,
                              ),
                            ),
                            if (track.album?.name != null &&
                                track.album!.name.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                track.album!.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: tokens.textDim,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          LucideIcons.ellipsis,
                          color: tokens.textPrimary,
                        ),
                        tooltip: 'More options',
                        onPressed: () {
                          unawaited(
                            showTrackMenuSheet(context: context, track: track),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Artwork with animated scale on play/pause
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final size =
                              constraints.maxWidth < constraints.maxHeight
                              ? constraints.maxWidth
                              : constraints.maxHeight;
                          final artSize = size.clamp(200.0, 360.0);
                          return AnimatedScale(
                            scale: playerState.isPlaying ? 1.0 : 0.92,
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                            child: SizedBox(
                              width: artSize,
                              height: artSize,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 28,
                                      offset: const Offset(0, 14),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: ArtworkImage(
                                    art: track.artwork,
                                    size: artSize,
                                    radius: 24,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Track Info & Like button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
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
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: tokens.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (track.artist.id.isNotEmpty) {
                                  unawaited(
                                    context.push('/artist/${track.artist.id}'),
                                  );
                                }
                              },
                              child: Text(
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: tokens.textDim,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isLiked ? LucideIcons.heart : LucideIcons.heart,
                          color: isLiked ? Colors.redAccent : tokens.textDim,
                          size: 26,
                        ),
                        tooltip: isLiked ? l10n.playerUnlike : l10n.playerLike,
                        onPressed: () {
                          ref.read(libraryRepositoryProvider).toggleLike(track);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Scrubber (GlassSlider)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GlassSlider(
                    value: clampedCurrentMs,
                    max: durationMs > 0 ? durationMs.toDouble() : 1.0,
                    elapsedLabel: elapsedLabel,
                    remainingLabel: remainingLabel,
                    onChanged: (val) {
                      setState(() {
                        _scrubPositionMs = val;
                      });
                    },
                    onChangeEnd: (val) {
                      _scrubPositionMs = null;
                      ref
                          .read(playerControllerProvider.notifier)
                          .seek(Duration(milliseconds: val.toInt()));
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Main Playback Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Shuffle button
                      IconButton(
                        icon: Icon(
                          LucideIcons.shuffle,
                          color: playerState.shuffle
                              ? tokens.accent
                              : tokens.textDim,
                          size: 24,
                        ),
                        tooltip: l10n.playerShuffle,
                        onPressed: () => ref
                            .read(playerControllerProvider.notifier)
                            .toggleShuffle(),
                      ),
                      // Previous button
                      IconButton(
                        icon: Icon(
                          LucideIcons.skipBack,
                          color: tokens.textPrimary,
                          size: 32,
                        ),
                        tooltip: l10n.playerPrev,
                        onPressed: () =>
                            ref.read(playerControllerProvider.notifier).prev(),
                      ),
                      // Big Play/Pause accent circle button
                      GestureDetector(
                        onTap: () => ref
                            .read(playerControllerProvider.notifier)
                            .toggle(),
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: tokens.accent,
                            boxShadow: [
                              BoxShadow(
                                color: tokens.accent.withValues(alpha: 0.3),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: playerState.buffering
                                ? SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: tokens.onAccent,
                                    ),
                                  )
                                : Icon(
                                    playerState.isPlaying
                                        ? LucideIcons.pause
                                        : LucideIcons.play,
                                    size: 34,
                                    color: tokens.onAccent,
                                  ),
                          ),
                        ),
                      ),
                      // Next button
                      IconButton(
                        icon: Icon(
                          LucideIcons.skipForward,
                          color: tokens.textPrimary,
                          size: 32,
                        ),
                        tooltip: l10n.playerNext,
                        onPressed: () =>
                            ref.read(playerControllerProvider.notifier).next(),
                      ),
                      // Repeat button (off / all / one)
                      IconButton(
                        icon: Icon(
                          playerState.repeat == RepeatMode.one
                              ? LucideIcons.repeat1
                              : LucideIcons.repeat,
                          color: playerState.repeat != RepeatMode.off
                              ? tokens.accent
                              : tokens.textDim,
                          size: 24,
                        ),
                        tooltip: switch (playerState.repeat) {
                          RepeatMode.all => l10n.playerRepeatAll,
                          RepeatMode.one => l10n.playerRepeatOne,
                          RepeatMode.off => l10n.playerRepeatOff,
                        },
                        onPressed: () => ref
                            .read(playerControllerProvider.notifier)
                            .cycleRepeat(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Bottom utility bar: Lyrics, Sleep timer, EQ (Android), Queue
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Lyrics toggle
                      IconButton(
                        icon: Icon(
                          LucideIcons.mic,
                          color: tokens.textDim,
                          size: 22,
                        ),
                        tooltip: 'Lyrics',
                        onPressed: () {
                          // Phase 5 lyrics
                        },
                      ),
                      // Sleep timer sheet
                      IconButton(
                        icon: Icon(
                          LucideIcons.timer,
                          color: playerState.sleepAt != null
                              ? tokens.accent
                              : tokens.textDim,
                          size: 22,
                        ),
                        tooltip: 'Sleep timer',
                        onPressed: () {
                          // Sleep timer sheet
                        },
                      ),
                      // Equalizer (Android only)
                      if (defaultTargetPlatform == TargetPlatform.android)
                        IconButton(
                          icon: Icon(
                            LucideIcons.sliders,
                            color: tokens.textDim,
                            size: 22,
                          ),
                          tooltip: 'Equalizer',
                          onPressed: () => context.push('/settings/eq'),
                        ),
                      // Queue sheet
                      IconButton(
                        icon: Icon(
                          LucideIcons.listMusic,
                          color: tokens.textDim,
                          size: 22,
                        ),
                        tooltip: l10n.playerQueue,
                        onPressed: () => context.push('/queue'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
