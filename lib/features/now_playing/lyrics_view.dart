import 'dart:async';
import 'dart:math' as math;

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/data/models/lyrics.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/lyrics_repository.dart';
import 'package:awady_music/widgets/glass_toast.dart';
import 'package:awady_music/widgets/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Full-screen or expanded lyrics view supporting line-timed karaoke
/// highlighting, tap-to-seek, long-press offset pinning, auto-scroll centering,
/// and plain fallback.
class LyricsView extends ConsumerStatefulWidget {
  const LyricsView({
    required this.track,
    required this.currentTime,
    required this.onSeek,
    super.key,
  });

  final Track track;
  final Duration currentTime;
  final ValueChanged<Duration> onSeek;

  @override
  ConsumerState<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends ConsumerState<LyricsView> {
  final ScrollController _scrollController = ScrollController();
  DateTime _userScrollUntil = DateTime.fromMillisecondsSinceEpoch(0);
  int _lastActiveIndex = -1;
  final List<GlobalKey> _lineKeys = [];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActive(int index) {
    if (index < 0 || index >= _lineKeys.length) return;
    if (DateTime.now().isBefore(_userScrollUntil)) return;

    final key = _lineKeys[index];
    final currentContext = key.currentContext;
    if (currentContext != null) {
      Scrollable.ensureVisible(
        currentContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;
    final lyricsAsync = ref.watch(lyricsForTrackProvider(widget.track));

    return lyricsAsync.when(
      loading: _buildLoadingState,
      error: (_, _) => _buildNoLyricsState(tokens, l10n),
      data: (lyrics) {
        return switch (lyrics) {
          SyncedLyrics() => _buildSyncedLyrics(tokens, l10n, lyrics),
          PlainLyrics() => _buildPlainLyrics(tokens, l10n, lyrics),
          NoLyrics() => _buildNoLyricsState(tokens, l10n),
        };
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      key: Key('now_playing_lyrics_loading'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShimmerBox(width: 260, height: 28, radius: 14),
          SizedBox(height: 18),
          ShimmerBox(width: 320, height: 32, radius: 16),
          SizedBox(height: 18),
          ShimmerBox(width: 210, height: 28, radius: 14),
        ],
      ),
    );
  }

  Widget _buildNoLyricsState(GlassTokens tokens, L10n l10n) {
    return Center(
      key: const Key('now_playing_no_lyrics'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.micOff, size: 48, color: tokens.textFaint),
            const SizedBox(height: 16),
            Text(
              l10n.npNoLyrics,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: tokens.textDim,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.npAccuracyNote,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: tokens.textFaint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlainLyrics(GlassTokens tokens, L10n l10n, PlainLyrics lyrics) {
    final isRtl = Bidi.detectRtlDirectionality(lyrics.text);

    return NotificationListener<ScrollNotification>(
      onNotification: (_) => false,
      child: ListView(
        key: const Key('now_playing_plain_lyrics'),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        children: [
          Text(
            lyrics.text,
            textAlign: isRtl ? TextAlign.right : TextAlign.left,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(
              fontSize: 19,
              height: 1.6,
              fontWeight: FontWeight.w600,
              color: tokens.textPrimary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            l10n.npAccuracyNote,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: tokens.textFaint),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncedLyrics(
    GlassTokens tokens,
    L10n l10n,
    SyncedLyrics lyrics,
  ) {
    final lines = lyrics.lines;
    while (_lineKeys.length < lines.length) {
      _lineKeys.add(GlobalKey());
    }

    final currentMs = widget.currentTime.inMilliseconds;
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

    if (activeIndex != _lastActiveIndex) {
      _lastActiveIndex = activeIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToActive(activeIndex);
      });
    }

    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        if (notification.direction != ScrollDirection.idle) {
          _userScrollUntil = DateTime.now().add(const Duration(seconds: 4));
        }
        return false;
      },
      child: ListView.builder(
        key: const Key('now_playing_lyrics_view'),
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
        itemCount: lines.length + 1,
        itemBuilder: (context, i) {
          if (i == lines.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 48, bottom: 24),
              child: Text(
                l10n.npAccuracyNote,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: tokens.textFaint),
              ),
            );
          }

          final line = lines[i];
          final isActive = i == activeIndex;
          final isPast = activeIndex >= 0 && i < activeIndex;
          final isRtl = Bidi.detectRtlDirectionality(line.text);

          final textColor = isActive
              ? tokens.textPrimary
              : isPast
              ? tokens.textPrimary.withValues(alpha: 0.45)
              : tokens.textPrimary.withValues(alpha: 0.25);

          return Padding(
            key: _lineKeys[i],
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: InkWell(
              key: Key('lyric_line_$i'),
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                final targetSeekMs = math.max(
                  0,
                  line.startMs + lyrics.autoOffsetMs,
                );
                widget.onSeek(Duration(milliseconds: targetSeekMs));
              },
              onLongPress: () {
                final newOffsetMs =
                    widget.currentTime.inMilliseconds - line.startMs;
                unawaited(
                  ref
                      .read(lyricsRepositoryProvider)
                      .pinOffset(
                        trackId: widget.track.id,
                        fingerprint: lyrics.fingerprint,
                        offsetMs: newOffsetMs,
                      ),
                );
                ref.read(toastProvider.notifier).show('Synced');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  style: TextStyle(
                    fontSize: isActive ? 26 : 21,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                    color: textColor,
                    height: 1.35,
                  ),
                  child: Text(
                    line.text,
                    textAlign: isRtl ? TextAlign.right : TextAlign.left,
                    textDirection: isRtl
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
