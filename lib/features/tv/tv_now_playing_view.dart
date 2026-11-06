import 'dart:async';

import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/features/now_playing/lyrics_view.dart';
import 'package:awady_music/features/tv/tv_focus_button.dart';
import 'package:awady_music/player/connect_receiver.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:awady_music/widgets/animated_favorite_button.dart';
import 'package:awady_music/widgets/artwork_image.dart';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TvNowPlayingView extends ConsumerStatefulWidget {
  const TvNowPlayingView({
    required this.track,
    required this.onBackToBrowse,
    super.key,
  });

  final Track track;
  final VoidCallback onBackToBrowse;

  @override
  ConsumerState<TvNowPlayingView> createState() => _TvNowPlayingViewState();
}

class _TvNowPlayingViewState extends ConsumerState<TvNowPlayingView> {
  int _selectedTab = 0; // 0 = Lyrics, 1 = Up Next
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;
    final ps = ref.watch(playerControllerProvider);
    final player = ref.read(playerControllerProvider.notifier);
    final receiverState = ref.watch(connectReceiverProvider);
    final track = widget.track;

    return Column(
      children: [
        _buildHeader(tokens, receiverState),
        const SizedBox(height: 10),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left: Album Art & Controls (fixed so it never overflows 540dp)
              Expanded(
                flex: 42,
                child: _buildLeftPlaybackPanel(tokens, track, ps, player),
              ),
              const SizedBox(width: 24),
              // Right: Lyrics / Up Next Queue
              Expanded(
                flex: 58,
                child: _buildRightTabPanel(tokens, track, ps, player),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(GlassTokens tokens, ConnectReceiverState receiverState) {
    return Row(
      children: [
        TvFocusButton(
          onPressed: widget.onBackToBrowse,
          tooltip: 'Back to Browse',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: tokens.glassFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: tokens.glassStroke),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.arrowLeft,
                  color: tokens.textPrimary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Browse',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: tokens.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Connect status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: receiverState.activeControllerName != null
                ? const Color(0xFF10B981).withValues(alpha: 0.18)
                : tokens.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: receiverState.activeControllerName != null
                  ? const Color(0xFF10B981).withValues(alpha: 0.35)
                  : tokens.accent.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                receiverState.activeControllerName != null
                    ? LucideIcons.smartphone
                    : LucideIcons.tv,
                size: 13,
                color: receiverState.activeControllerName != null
                    ? const Color(0xFF10B981)
                    : tokens.accent,
              ),
              const SizedBox(width: 6),
              Text(
                receiverState.activeControllerName != null
                    ? 'Controlled by ${receiverState.activeControllerName}'
                    : 'Awady Connect Ready • Port ${receiverState.port}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: receiverState.activeControllerName != null
                      ? const Color(0xFF10B981)
                      : tokens.accent,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Digital Clock
        Text(
          DateFormat.jm().format(_now),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: tokens.textDim,
          ),
        ),
      ],
    );
  }

  Widget _buildLeftPlaybackPanel(
    GlassTokens tokens,
    Track track,
    PlayerState ps,
    PlayerController player,
  ) {
    final curPos = ps.currentTime;
    final dur = ps.duration;
    final progress = dur.inMilliseconds > 0
        ? (curPos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Adapt artwork height strictly to viewport: max 180dp on 540dp screens
        final artSize = (constraints.maxHeight * 0.42).clamp(130.0, 190.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Album Artwork with subtle glow
            Container(
              width: artSize,
              height: artSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: tokens.accent.withValues(alpha: 0.25),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: ArtworkImage(art: track.artwork, size: 480),
            ),
            const SizedBox(height: 10),

            // Track Title
            Text(
              track.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 2),

            // Artist Name
            Text(
              track.artist.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: tokens.textDim,
              ),
            ),
            const SizedBox(height: 10),

            // Scrubber Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      color: tokens.accent,
                      backgroundColor: tokens.glassFill,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(curPos),
                        style: TextStyle(fontSize: 11, color: tokens.textDim),
                      ),
                      Text(
                        _formatDuration(dur),
                        style: TextStyle(fontSize: 11, color: tokens.textDim),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Controls Row (50dp play/pause, nicely spaced)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Shuffle
                TvFocusButton(
                  onPressed: player.toggleShuffle,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      LucideIcons.shuffle,
                      color: ps.shuffle ? tokens.accent : tokens.textDim,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Prev
                TvFocusButton(
                  onPressed: player.prev,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      LucideIcons.skipBack,
                      color: tokens.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Play / Pause (50dp primary button)
                TvFocusButton(
                  onPressed: player.toggle,
                  autofocus: true,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: tokens.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: tokens.accent.withValues(alpha: 0.35),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      ps.isPlaying ? LucideIcons.pause : LucideIcons.play,
                      color: tokens.onAccent,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Next
                TvFocusButton(
                  onPressed: player.next,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      LucideIcons.skipForward,
                      color: tokens.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Repeat
                TvFocusButton(
                  onPressed: player.cycleRepeat,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      ps.repeat == RepeatMode.one
                          ? LucideIcons.repeat1
                          : LucideIcons.repeat,
                      color: ps.repeat != RepeatMode.off
                          ? tokens.accent
                          : tokens.textDim,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Favorite
                AnimatedFavoriteButton(
                  isLiked: ref
                      .watch(libraryRepositoryProvider)
                      .isLiked(track.id),
                  onTap: () {
                    ref.read(libraryRepositoryProvider).toggleLike(track);
                  },
                  size: 22,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildRightTabPanel(
    GlassTokens tokens,
    Track track,
    PlayerState ps,
    PlayerController player,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.glassStroke),
      ),
      child: Column(
        children: [
          // Tab bar selector
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Row(
              children: [
                _buildTabButton(
                  title: 'Lyrics',
                  icon: LucideIcons.mic2,
                  index: 0,
                  tokens: tokens,
                ),
                const SizedBox(width: 10),
                _buildTabButton(
                  title: 'Up Next (${ps.queue.length})',
                  icon: LucideIcons.listMusic,
                  index: 1,
                  tokens: tokens,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: _selectedTab == 0
                ? LyricsView(
                    track: track,
                    currentTime: ps.currentTime,
                    onSeek: player.seek,
                  )
                : _buildQueueList(tokens, ps, player),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required int index,
    required GlassTokens tokens,
  }) {
    final isSelected = _selectedTab == index;
    return TvFocusButton(
      onPressed: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? tokens.accent.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? tokens.accent : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? tokens.accent : tokens.textDim,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? tokens.accent : tokens.textDim,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueList(
    GlassTokens tokens,
    PlayerState ps,
    PlayerController player,
  ) {
    if (ps.queue.isEmpty) {
      return Center(
        child: Text(
          'Queue is empty',
          style: TextStyle(color: tokens.textDim, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: ps.queue.length,
      itemBuilder: (context, i) {
        final item = ps.queue[i];
        final isCurrent = i == ps.index;

        return TvFocusButton(
          onPressed: () => player.playContext(ps.queue, i),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isCurrent
                  ? tokens.accent.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? tokens.accent : tokens.textDim,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 38,
                    height: 38,
                    child: ArtworkImage(art: item.artwork, size: 76),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isCurrent ? tokens.accent : tokens.textPrimary,
                        ),
                      ),
                      Text(
                        item.artist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: tokens.textDim),
                      ),
                    ],
                  ),
                ),
                if (isCurrent)
                  Icon(LucideIcons.volume2, color: tokens.accent, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}
