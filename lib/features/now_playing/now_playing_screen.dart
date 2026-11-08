import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/core/util/format.dart';
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
  bool _showLyrics = false;
  double _dragOffsetY = 0;

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
    final isCasting = ref.watch(castProvider.select((s) => s.isCasting));

    return Scaffold(
      backgroundColor: tokens.bg,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: _showLyrics
            ? null
            : (details) {
                if (details.delta.dy > 0 || _dragOffsetY > 0) {
                  setState(() {
                    _dragOffsetY = math.max(0, _dragOffsetY + details.delta.dy);
                  });
                }
              },
        onVerticalDragEnd: _showLyrics
            ? null
            : (details) {
                final velocity = details.primaryVelocity ?? 0.0;
                if (_dragOffsetY > 100 || velocity > 450) {
                  context.pop();
                } else {
                  setState(() {
                    _dragOffsetY = 0.0;
                  });
                }
              },
        child: AnimatedContainer(
          duration: _dragOffsetY == 0.0
              ? const Duration(milliseconds: 220)
              : Duration.zero,
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _dragOffsetY, 0),
          child: Stack(
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
                              child: ArtworkImage(art: track.artwork, size: 52),
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
                            _buildDownloadButton(track, tokens, l10n, size: 22),
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
                            ),
                          ],
                        ),
                      ),
                      // Lyrics View
                      Expanded(
                        child: LyricsView(
                          track: track,
                          currentTime: playerState.currentTime,
                          onSeek: (pos) => ref
                              .read(playerControllerProvider.notifier)
                              .seek(pos),
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
                                      scale: playerState.isPlaying ? 1.0 : 0.92,
                                      duration: const Duration(
                                        milliseconds: 280,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      child: SizedBox(
                                        width: artSize,
                                        height: artSize,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
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
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
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
                                  currentTime: playerState.currentTime,
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
                                      if (rawId.isNotEmpty && rawId != 'yt-') {
                                        final encodedId = Uri.encodeComponent(
                                          rawId,
                                        );
                                        final encodedName = Uri.encodeComponent(
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
                            _buildDownloadButton(track, tokens, l10n, size: 26),
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
                            ),
                          ],
                        ),
                      ),
                    ],
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
                            onPressed: () => ref
                                .read(playerControllerProvider.notifier)
                                .prev(),
                          ),
                          // Play/Pause button
                          Semantics(
                            label: playerState.isPlaying
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
                              color: playerState.sleepAt != null
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
                                color: playerState.eq.any((g) => g != 0)
                                    ? tokens.accent
                                    : tokens.textDim,
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
    );
  }
}

class _InlineLyricsPreview extends ConsumerWidget {
  const _InlineLyricsPreview({
    required this.track,
    required this.currentTime,
    required this.onTap,
    this.width,
  });

  final Track track;
  final Duration currentTime;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).glass;
    final lyricsAsync = ref.watch(lyricsForTrackProvider(track));

    Widget content = GestureDetector(
      key: const Key('now_playing_inline_lyrics_preview'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: GlassSurface(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        child: lyricsAsync.when(
          data: (lyrics) => _buildContent(context, tokens, lyrics),
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

    return content;
  }

  Widget _buildContent(
    BuildContext context,
    GlassTokens tokens,
    Lyrics lyrics,
  ) {
    if (lyrics is SyncedLyrics) {
      final lines = lyrics.lines;
      if (lines.isEmpty) return _buildPlaceholder(tokens);

      final currentMs = currentTime.inMilliseconds;
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
