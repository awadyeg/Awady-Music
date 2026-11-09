import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/core/util/format.dart';
import 'package:awady_music/data/models/artwork.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/lyrics.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/downloads_repository.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/data/repositories/lyrics_repository.dart';
import 'package:awady_music/features/now_playing/lyrics_view.dart';
import 'package:awady_music/player/cast_service.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/widgets/animated_favorite_button.dart';
import 'package:awady_music/widgets/artwork_image.dart';
import 'package:awady_music/widgets/cast_sheet.dart';
import 'package:awady_music/widgets/equalizer_sheet.dart';
import 'package:awady_music/widgets/glass_slider.dart';
import 'package:awady_music/widgets/glass_toast.dart';
import 'package:awady_music/widgets/sleep_timer_sheet.dart';
import 'package:awady_music/widgets/track_menu_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<double> _dragOffsetNotifier = ValueNotifier<double>(
    0,
  );
  AnimationController? _dismissController;
  bool _showLyrics = false;
  bool _isClosing = false;

  void _closeNowPlaying() {
    if (_isClosing || !mounted) return;
    _isClosing = true;
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      if (router.canPop()) {
        router.pop();
      } else {
        router.go('/home');
      }
      return;
    }
    final navigator = Navigator.maybeOf(context);
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
    }
  }

  @override
  void dispose() {
    _dismissController?.dispose();
    _dragOffsetNotifier.dispose();
    super.dispose();
  }

  void _onDragEnd(DragEndDetails details, double screenHeight) {
    if (_showLyrics || _isClosing) return;
    final velocity = details.primaryVelocity ?? 0.0;
    final currentOffset = _dragOffsetNotifier.value;

    if (currentOffset > 90 || velocity > 380) {
      _dismissController?.dispose();
      _dismissController = null;
      _closeNowPlaying();
    } else {
      _dismissController?.dispose();
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 180),
      );
      _dismissController = controller;
      final animation = Tween<double>(begin: currentOffset, end: 0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
      animation.addListener(() {
        _dragOffsetNotifier.value = animation.value;
      });

      controller.forward();
    }
  }

  Widget _buildDownloadButton(
    Track track,
    GlassTokens tokens,
    L10n l10n, {
    double size = 24,
  }) {
    final downloadedAsync = ref.watch(downloadedTracksProvider);
    final progressAsync = ref.watch(downloadProgressStreamProvider);

    final isDownloaded =
        downloadedAsync.asData?.value.any((t) => t.id == track.id) ?? false;
    final progressMap = progressAsync.asData?.value ?? const {};
    final prog = progressMap[track.id];
    final isDownloading =
        prog != null &&
        (prog.status == DownloadStatus.queued ||
            prog.status == DownloadStatus.downloading);

    if (isDownloading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          width: size - 4,
          height: size - 4,
          child: CircularProgressIndicator(
            value: prog.progress > 0 ? prog.progress : null,
            strokeWidth: 2.2,
            color: tokens.accent,
          ),
        ),
      );
    }

    if (isDownloaded) {
      return IconButton(
        icon: Icon(LucideIcons.circleCheck, color: tokens.accent, size: size),
        tooltip: l10n.downloaded,
        onPressed: null,
      );
    }

    return IconButton(
      icon: Icon(LucideIcons.download, color: tokens.textDim, size: size),
      tooltip: l10n.downloadTrack,
      onPressed: () {
        unawaited(ref.read(downloadsRepositoryProvider).enqueueDownload(track));
        ref.read(toastProvider.notifier).show(l10n.tableDownloading('0'));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final track = ref.watch(playerControllerProvider.select((s) => s.current));
    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;

    if (track == null) {
      return Scaffold(
        backgroundColor: tokens.bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(LucideIcons.chevronDown, color: tokens.textPrimary),
            onPressed: _closeNowPlaying,
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

    final isPlaying = ref.watch(
      playerControllerProvider.select((s) => s.isPlaying),
    );
    final buffering = ref.watch(
      playerControllerProvider.select((s) => s.buffering),
    );
    final shuffle = ref.watch(
      playerControllerProvider.select((s) => s.shuffle),
    );
    final repeat = ref.watch(playerControllerProvider.select((s) => s.repeat));
    final hasSleepTimer = ref.watch(
      playerControllerProvider.select((s) => s.sleepAt != null),
    );
    final hasEq = ref.watch(
      playerControllerProvider.select((s) => s.eq.any((g) => g != 0)),
    );

    final isLiked = ref.watch(
      libraryRepositoryProvider.select((repo) => repo.isLiked(track.id)),
    );

    final isCasting = ref.watch(castProvider.select((s) => s.isCasting));
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: (_showLyrics || _isClosing)
            ? null
            : (details) {
                _dismissController?.stop();
                if (details.delta.dy > 0 || _dragOffsetNotifier.value > 0) {
                  _dragOffsetNotifier.value = math.max(
                    0,
                    _dragOffsetNotifier.value + details.delta.dy,
                  );
                }
              },
        onVerticalDragEnd: (_showLyrics || _isClosing)
            ? null
            : (details) => _onDragEnd(details, screenHeight),
        child: ValueListenableBuilder<double>(
          valueListenable: _dragOffsetNotifier,
          builder: (context, dragOffset, child) {
            return Transform.translate(
              offset: Offset(0, dragOffset),
              child: child,
            );
          },
          child: RepaintBoundary(
            child: Stack(
              children: [
                // Base solid background so transparent outer scaffold doesn't
                // leak through.
                Positioned.fill(child: ColoredBox(color: tokens.bg)),
                // Bilinear low-res ambient artwork wash background
                Positioned.fill(
                  child: _AmbientArtworkWash(
                    artwork: track.artwork,
                    tokens: tokens,
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
                              onPressed: _closeNowPlaying,
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
                                LucideIcons.cast,
                                color: isCasting
                                    ? tokens.accent
                                    : tokens.textPrimary,
                              ),
                              tooltip: 'Cast',
                              onPressed: () {
                                unawaited(showCastSheet(context));
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                LucideIcons.ellipsis,
                                color: tokens.textPrimary,
                              ),
                              tooltip: 'More options',
                              onPressed: () {
                                unawaited(
                                  showTrackMenuSheet(
                                    context: context,
                                    track: track,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      if (_showLyrics) ...[
                        // Shrunken artwork header row
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: ArtworkImage(
                                  art: track.artwork,
                                  size: 52,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      track.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textDirection:
                                          Bidi.detectRtlDirectionality(
                                            track.title,
                                          )
                                          ? TextDirection.rtl
                                          : TextDirection.ltr,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
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
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: tokens.textDim,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildDownloadButton(
                                track,
                                tokens,
                                l10n,
                                size: 22,
                              ),
                              AnimatedFavoriteButton(
                                isLiked: isLiked,
                                size: 22,
                                tooltip: isLiked
                                    ? l10n.playerUnlike
                                    : l10n.playerLike,
                                unlikedColor: tokens.textDim,
                                onTap: () {
                                  ref
                                      .read(libraryRepositoryProvider)
                                      .toggleLike(track);
                                  setState(() {});
                                },
                                onLongPress: () => unawaited(
                                  showAddToPlaylistSheet(context, ref, track),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Lyrics View
                        Expanded(
                          child: Consumer(
                            builder: (context, ref, _) {
                              final currentTime = ref.watch(
                                playerControllerProvider.select(
                                  (s) => s.currentTime,
                                ),
                              );
                              return LyricsView(
                                track: track,
                                currentTime: currentTime,
                                onSeek: (pos) => ref
                                    .read(playerControllerProvider.notifier)
                                    .seek(pos),
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        // Artwork with animated scale on play/pause & matching-width lyrics preview
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final artMaxWidth = (constraints.maxWidth - 64)
                                  .clamp(200.0, 360.0);
                              final artMaxHeight = (constraints.maxHeight - 88)
                                  .clamp(200.0, 360.0);
                              final artSize =
                                  (artMaxWidth < artMaxHeight
                                          ? artMaxWidth
                                          : artMaxHeight)
                                      .clamp(200.0, 360.0);

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: AnimatedScale(
                                        scale: isPlaying ? 1.0 : 0.92,
                                        duration: const Duration(
                                          milliseconds: 280,
                                        ),
                                        curve: Curves.easeOutCubic,
                                        child: SizedBox(
                                          width: artSize,
                                          height: artSize,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.35),
                                                  blurRadius: 28,
                                                  offset: const Offset(0, 14),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              child: ArtworkImage(
                                                art: track.artwork,
                                                size: artSize,
                                                radius: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _InlineLyricsPreview(
                                    track: track,
                                    width: artSize,
                                    onTap: () =>
                                        setState(() => _showLyrics = true),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Track Info & Action buttons (Download + Favorite)
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
                                          Bidi.detectRtlDirectionality(
                                            track.title,
                                          )
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
                                        final rawId =
                                            (track.artist.id.isNotEmpty &&
                                                track.artist.id != 'yt-')
                                            ? track.artist.id
                                            : 'yt-${track.artist.name}';
                                        if (rawId.isNotEmpty &&
                                            rawId != 'yt-') {
                                          final encodedId = Uri.encodeComponent(
                                            rawId,
                                          );
                                          final encodedName =
                                              Uri.encodeComponent(
                                                track.artist.name,
                                              );
                                          unawaited(
                                            context.push(
                                              '/artist/$encodedId?n=$encodedName',
                                            ),
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
                              _buildDownloadButton(
                                track,
                                tokens,
                                l10n,
                                size: 26,
                              ),
                              AnimatedFavoriteButton(
                                isLiked: isLiked,
                                tooltip: isLiked
                                    ? l10n.playerUnlike
                                    : l10n.playerLike,
                                unlikedColor: tokens.textDim,
                                onTap: () {
                                  ref
                                      .read(libraryRepositoryProvider)
                                      .toggleLike(track);
                                  setState(() {});
                                },
                                onLongPress: () => unawaited(
                                  showAddToPlaylistSheet(context, ref, track),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      // Scrubber (GlassSlider)
                      _NowPlayingScrubber(trackDurationSecs: track.duration),
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
                                color: shuffle ? tokens.accent : tokens.textDim,
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
                              onPressed: () => ref
                                  .read(playerControllerProvider.notifier)
                                  .prev(),
                            ),
                            // Play/Pause button
                            Semantics(
                              label: isPlaying
                                  ? l10n.playerPause
                                  : l10n.playerPlay,
                              button: true,
                              child: GestureDetector(
                                onTap: () => ref
                                    .read(playerControllerProvider.notifier)
                                    .toggle(),
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: tokens.accent,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: tokens.accent.withValues(
                                          alpha: 0.35,
                                        ),
                                        blurRadius: 18,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: buffering
                                        ? SizedBox(
                                            width: 28,
                                            height: 28,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              color: tokens.onAccent,
                                            ),
                                          )
                                        : Icon(
                                            isPlaying
                                                ? LucideIcons.pause
                                                : LucideIcons.play,
                                            size: 34,
                                            color: tokens.onAccent,
                                          ),
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
                              onPressed: () => ref
                                  .read(playerControllerProvider.notifier)
                                  .next(),
                            ),
                            // Repeat button (off / all / one)
                            IconButton(
                              icon: Icon(
                                repeat == RepeatMode.one
                                    ? LucideIcons.repeat1
                                    : LucideIcons.repeat,
                                color: repeat != RepeatMode.off
                                    ? tokens.accent
                                    : tokens.textDim,
                                size: 24,
                              ),
                              tooltip: switch (repeat) {
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
                      // Bottom bar: Lyrics, Sleep timer, EQ (Android), Queue
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Lyrics toggle
                            IconButton(
                              key: const Key('now_playing_lyrics_toggle'),
                              icon: Icon(
                                LucideIcons.mic,
                                color: _showLyrics
                                    ? tokens.accent
                                    : tokens.textDim,
                                size: 22,
                              ),
                              tooltip: l10n.npLyrics,
                              onPressed: () {
                                setState(() {
                                  _showLyrics = !_showLyrics;
                                });
                              },
                            ),
                            // Sleep timer sheet
                            IconButton(
                              icon: Icon(
                                LucideIcons.timer,
                                color: hasSleepTimer
                                    ? tokens.accent
                                    : tokens.textDim,
                                size: 22,
                              ),
                              tooltip: 'Sleep timer',
                              onPressed: () {
                                unawaited(SleepTimerSheet.show(context));
                              },
                            ),
                            // Equalizer (Android only)
                            if (defaultTargetPlatform == TargetPlatform.android)
                              IconButton(
                                icon: Icon(
                                  LucideIcons.sliders,
                                  color: hasEq ? tokens.accent : tokens.textDim,
                                  size: 22,
                                ),
                                tooltip: 'Equalizer',
                                onPressed: () {
                                  unawaited(EqualizerSheet.show(context));
                                },
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
          ),
        ),
      ),
    );
  }
}

class _NowPlayingScrubber extends ConsumerStatefulWidget {
  const _NowPlayingScrubber({required this.trackDurationSecs});

  final int trackDurationSecs;

  @override
  ConsumerState<_NowPlayingScrubber> createState() =>
      _NowPlayingScrubberState();
}

class _NowPlayingScrubberState extends ConsumerState<_NowPlayingScrubber> {
  double? _scrubPositionMs;

  @override
  Widget build(BuildContext context) {
    final playerDuration = ref.watch(
      playerControllerProvider.select((s) => s.duration),
    );
    final currentTime = ref.watch(
      playerControllerProvider.select((s) => s.currentTime),
    );

    final durationSecs = playerDuration.inSeconds > 0
        ? playerDuration.inSeconds
        : widget.trackDurationSecs;
    final durationMs = durationSecs * 1000;
    final currentMs = _scrubPositionMs ?? currentTime.inMilliseconds.toDouble();
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

    return Padding(
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
          setState(() {
            _scrubPositionMs = null;
          });
          ref
              .read(playerControllerProvider.notifier)
              .seek(Duration(milliseconds: val.toInt()));
        },
      ),
    );
  }
}

class _InlineLyricsPreview extends ConsumerWidget {
  const _InlineLyricsPreview({
    required this.track,
    required this.onTap,
    this.width,
  });

  final Track track;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).glass;
    final currentTime = ref.watch(
      playerControllerProvider.select((s) => s.currentTime),
    );
    final lyricsAsync = ref.watch(lyricsForTrackProvider(track));

    Widget content = GestureDetector(
      key: const Key('now_playing_inline_lyrics_preview'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: GlassSurface(
        enableBlur: false,
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        child: lyricsAsync.when(
          data: (lyrics) => _buildContent(context, tokens, lyrics, currentTime),
          loading: () => _buildPlaceholder(tokens),
          error: (_, _) => _buildPlaceholder(tokens),
        ),
      ),
    );

    if (width != null) {
      content = SizedBox(width: width, child: content);
    } else {
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        child: content,
      );
    }

    return RepaintBoundary(child: content);
  }

  Widget _buildContent(
    BuildContext context,
    GlassTokens tokens,
    Lyrics lyrics,
    Duration effectiveTime,
  ) {
    if (lyrics is SyncedLyrics) {
      final lines = lyrics.lines;
      if (lines.isEmpty) return _buildPlaceholder(tokens);

      final currentMs = effectiveTime.inMilliseconds;
      final adjMs = currentMs - lyrics.autoOffsetMs;
      const lookaheadMs = 150;

      var activeIndex = -1;
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].startMs <= adjMs + lookaheadMs) {
          activeIndex = i;
        } else {
          break;
        }
      }

      final prevText = activeIndex > 0 ? lines[activeIndex - 1].text : '';
      final currText = activeIndex >= 0
          ? lines[activeIndex].text
          : lines[0].text;
      final nextText = (activeIndex + 1 >= 0 && activeIndex + 1 < lines.length)
          ? lines[activeIndex + 1].text
          : (lines.length > 1 ? lines[1].text : '');

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            prevText.isNotEmpty ? prevText : ' ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: tokens.textDim.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            currText.isNotEmpty ? currText : ' ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: tokens.accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            nextText.isNotEmpty ? nextText : ' ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: tokens.textDim.withValues(alpha: 0.5),
            ),
          ),
        ],
      );
    } else if (lyrics is PlainLyrics) {
      final rawLines = lyrics.text
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .take(3)
          .toList();

      if (rawLines.isEmpty) return _buildPlaceholder(tokens);

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rawLines.length; i++) ...[
            Text(
              rawLines[i],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: i == 1 ? 14 : 12,
                fontWeight: i == 1 ? FontWeight.bold : FontWeight.normal,
                color: i == 1 ? tokens.accent : tokens.textDim,
              ),
            ),
            if (i < rawLines.length - 1) const SizedBox(height: 2),
          ],
        ],
      );
    }
    return _buildPlaceholder(tokens);
  }

  Widget _buildPlaceholder(GlassTokens tokens) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '♪ ♪ ♪',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: tokens.textDim.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Lyrics',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: tokens.textDim,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '• • •',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: tokens.textDim.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}

class _AmbientArtworkWash extends StatelessWidget {
  const _AmbientArtworkWash({required this.artwork, required this.tokens});

  final Artwork? artwork;
  final GlassTokens tokens;

  @override
  Widget build(BuildContext context) {
    final primary =
        artwork?.s150 ?? artwork?.s480 ?? artwork?.s1000 ?? artwork?.fallback;

    Widget? imageWidget;
    if (primary != null && primary.isNotEmpty) {
      if (ArtworkImage.isLocalPath(primary)) {
        final filePath = primary.replaceFirst('file://', '');
        imageWidget = Image.file(
          File(filePath),
          fit: BoxFit.cover,
          cacheWidth: 24,
          cacheHeight: 24,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        );
      } else {
        imageWidget = CachedNetworkImage(
          imageUrl: primary,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
          memCacheWidth: 24,
          memCacheHeight: 24,
          errorWidget: (_, _, _) => const SizedBox.shrink(),
        );
      }
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ?imageWidget,
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                tokens.bg.withValues(alpha: 0.72),
                tokens.bg.withValues(alpha: 0.92),
                tokens.bg,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}
