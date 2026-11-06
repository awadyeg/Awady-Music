import 'dart:async';
import 'dart:ui';

import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/features/now_playing/lyrics_view.dart';
import 'package:awady_music/player/connect_receiver.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:awady_music/widgets/animated_favorite_button.dart';
import 'package:awady_music/widgets/artwork_image.dart';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class _TvPlayPauseIntent extends Intent {
  const _TvPlayPauseIntent();
}

class _TvNextIntent extends Intent {
  const _TvNextIntent();
}

class _TvPrevIntent extends Intent {
  const _TvPrevIntent();
}

class _TvSeekForwardIntent extends Intent {
  const _TvSeekForwardIntent();
}

class _TvSeekBackwardIntent extends Intent {
  const _TvSeekBackwardIntent();
}

/// Fullscreen TV mode optimized for big screens (1080p/4K), D-pad navigation,
/// ambient blurred background, synced lyrics, and Awady Connect sync.
class TvHomeScreen extends ConsumerStatefulWidget {
  const TvHomeScreen({this.onExitTvMode, super.key});

  final VoidCallback? onExitTvMode;

  @override
  ConsumerState<TvHomeScreen> createState() => _TvHomeScreenState();
}

class _TvHomeScreenState extends ConsumerState<TvHomeScreen> {
  Timer? _clockTimer;
  DateTime _now = DateTime.now();
  int _selectedRightTab = 0; // 0 = Lyrics, 1 = Up Next

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(connectReceiverProvider.notifier).start());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    return DateFormat.jm().format(dt);
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
    final curTrack = ps.current;

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.space): _TvPlayPauseIntent(),
        SingleActivator(LogicalKeyboardKey.select): _TvPlayPauseIntent(),
        SingleActivator(LogicalKeyboardKey.mediaPlayPause):
            _TvPlayPauseIntent(),
        SingleActivator(LogicalKeyboardKey.mediaTrackNext): _TvNextIntent(),
        SingleActivator(LogicalKeyboardKey.mediaTrackPrevious): _TvPrevIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight, alt: true):
            _TvSeekForwardIntent(),
        SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true):
            _TvSeekBackwardIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _TvPlayPauseIntent: CallbackAction<_TvPlayPauseIntent>(
            onInvoke: (_) => player.toggle(),
          ),
          _TvNextIntent: CallbackAction<_TvNextIntent>(
            onInvoke: (_) => player.next(),
          ),
          _TvPrevIntent: CallbackAction<_TvPrevIntent>(
            onInvoke: (_) => player.prev(),
          ),
          _TvSeekForwardIntent: CallbackAction<_TvSeekForwardIntent>(
            onInvoke: (_) {
              final target = ps.currentTime + const Duration(seconds: 10);
              player.seek(target > ps.duration ? ps.duration : target);
              return null;
            },
          ),
          _TvSeekBackwardIntent: CallbackAction<_TvSeekBackwardIntent>(
            onInvoke: (_) {
              final target = ps.currentTime - const Duration(seconds: 10);
              player.seek(target < Duration.zero ? Duration.zero : target);
              return null;
            },
          ),
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF0D0E15),
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Ambient blurred artwork background
              if (curTrack?.artwork != null)
                Positioned.fill(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                    child: Opacity(
                      opacity: 0.35,
                      child: ArtworkImage(art: curTrack!.artwork, size: 600),
                    ),
                  ),
                ),

              // Subtle dark overlay
              Container(color: Colors.black.withValues(alpha: 0.45)),

              // Main Content Area
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      _buildTopHeader(tokens, receiverState),
                      const SizedBox(height: 16),
                      Expanded(
                        child: curTrack == null
                            ? _buildEmptyState(tokens)
                            : Row(
                                children: [
                                  // Left Panel: Album Art & Controls
                                  Expanded(
                                    flex: 42,
                                    child: _buildLeftPanel(
                                      tokens,
                                      curTrack,
                                      ps,
                                      player,
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  // Right Panel: Lyrics / Up Next
                                  Expanded(
                                    flex: 58,
                                    child: _buildRightPanel(
                                      tokens,
                                      curTrack,
                                      ps,
                                      player,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(
    GlassTokens tokens,
    ConnectReceiverState receiverState,
  ) {
    return Row(
      children: [
        Icon(LucideIcons.music, color: tokens.accent, size: 28),
        const SizedBox(width: 12),
        Text(
          'Awady Music TV',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: tokens.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 24),

        // Connect Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: receiverState.activeControllerName != null
                ? const Color(0xFF10B981).withValues(alpha: 0.2)
                : tokens.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: receiverState.activeControllerName != null
                  ? const Color(0xFF10B981).withValues(alpha: 0.4)
                  : tokens.accent.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                receiverState.activeControllerName != null
                    ? LucideIcons.smartphone
                    : LucideIcons.tv,
                size: 14,
                color: receiverState.activeControllerName != null
                    ? const Color(0xFF10B981)
                    : tokens.accent,
              ),
              const SizedBox(width: 8),
              Text(
                receiverState.activeControllerName != null
                    ? 'Controlled by ${receiverState.activeControllerName}'
                    : 'Awady Connect Ready • Port ${receiverState.port}',
                style: TextStyle(
                  fontSize: 12,
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
          _formatTime(_now),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: tokens.textDim,
          ),
        ),

        const SizedBox(width: 16),

        // Exit TV Mode Button
        _TvFocusButton(
          onPressed: () {
            unawaited(ref.read(settingsProvider.notifier).setTvMode('off'));
            widget.onExitTvMode?.call();
          },
          tooltip: 'Exit TV Mode',
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: tokens.glassFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.minimize2, color: tokens.textDim, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildLeftPanel(
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Album Artwork
        Center(
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: tokens.accent.withValues(alpha: 0.25),
                  blurRadius: 32,
                  spreadRadius: 2,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: ArtworkImage(art: track.artwork, size: 544),
          ),
        ),
        const SizedBox(height: 20),

        // Title & Artist
        Text(
          track.title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          track.artist.name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: tokens.textDim,
          ),
        ),
        const SizedBox(height: 16),

        // Progress Scrubber Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  color: tokens.accent,
                  backgroundColor: tokens.glassFill,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(curPos),
                    style: TextStyle(fontSize: 12, color: tokens.textDim),
                  ),
                  Text(
                    _formatDuration(dur),
                    style: TextStyle(fontSize: 12, color: tokens.textDim),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Playback Controls Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Shuffle
            _TvFocusButton(
              onPressed: player.toggleShuffle,
              child: Icon(
                LucideIcons.shuffle,
                color: ps.shuffle ? tokens.accent : tokens.textDim,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Prev
            _TvFocusButton(
              onPressed: player.prev,
              child: Icon(
                LucideIcons.skipBack,
                color: tokens.textPrimary,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),

            // Play / Pause (Big Primary Button)
            _TvFocusButton(
              onPressed: player.toggle,
              autofocus: true,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: tokens.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: tokens.accent.withValues(alpha: 0.35),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  ps.isPlaying ? LucideIcons.pause : LucideIcons.play,
                  color: tokens.onAccent,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Next
            _TvFocusButton(
              onPressed: player.next,
              child: Icon(
                LucideIcons.skipForward,
                color: tokens.textPrimary,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),

            // Repeat
            _TvFocusButton(
              onPressed: player.cycleRepeat,
              child: Icon(
                ps.repeat == RepeatMode.one
                    ? LucideIcons.repeat1
                    : LucideIcons.repeat,
                color: ps.repeat != RepeatMode.off
                    ? tokens.accent
                    : tokens.textDim,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Like / Heart
            AnimatedFavoriteButton(
              isLiked: ref.watch(libraryRepositoryProvider).isLiked(track.id),
              onTap: () {
                ref.read(libraryRepositoryProvider).toggleLike(track);
              },
              size: 24,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRightPanel(
    GlassTokens tokens,
    Track track,
    PlayerState ps,
    PlayerController player,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.glassFill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tokens.glassStroke),
      ),
      child: Column(
        children: [
          // Segmented Tab Selector: [ Lyrics ] [ Up Next (N) ]
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                _buildTabButton(
                  title: 'Lyrics',
                  icon: LucideIcons.mic2,
                  index: 0,
                  tokens: tokens,
                ),
                const SizedBox(width: 12),
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

          // Tab Content
          Expanded(
            child: _selectedRightTab == 0
                ? LyricsView(
                    track: track,
                    currentTime: ps.currentTime,
                    onSeek: player.seek,
                  )
                : _buildUpNextQueue(tokens, ps, player),
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
    final isSelected = _selectedRightTab == index;
    return _TvFocusButton(
      onPressed: () => setState(() => _selectedRightTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? tokens.accent.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? tokens.accent : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? tokens.accent : tokens.textDim,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? tokens.accent : tokens.textDim,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpNextQueue(
    GlassTokens tokens,
    PlayerState ps,
    PlayerController player,
  ) {
    if (ps.queue.isEmpty) {
      return Center(
        child: Text(
          'Queue is empty',
          style: TextStyle(color: tokens.textDim, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: ps.queue.length,
      itemBuilder: (context, i) {
        final item = ps.queue[i];
        final isCurrent = i == ps.index;

        return _TvFocusButton(
          onPressed: () => player.playContext(ps.queue, i),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isCurrent
                  ? tokens.accent.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? tokens.accent : tokens.textDim,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: ArtworkImage(art: item.artwork, size: 80),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isCurrent ? tokens.accent : tokens.textPrimary,
                        ),
                      ),
                      Text(
                        item.artist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: tokens.textDim),
                      ),
                    ],
                  ),
                ),
                if (isCurrent)
                  Icon(LucideIcons.volume2, color: tokens.accent, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(GlassTokens tokens) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.tv, size: 64, color: tokens.textDim),
          const SizedBox(height: 16),
          Text(
            'Awady Music TV Mode',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cast music from your phone using Awady Connect,\n'
            'or play a song to begin listening.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: tokens.textDim, height: 1.5),
          ),
        ],
      ),
    );
  }
}

/// D-pad navigable focusable button with high-contrast glowing scale focus
/// effect.
class _TvFocusButton extends StatefulWidget {
  const _TvFocusButton({
    required this.child,
    required this.onPressed,
    this.autofocus = false,
    this.tooltip,
  });

  final Widget child;
  final VoidCallback onPressed;
  final bool autofocus;
  final String? tooltip;

  @override
  State<_TvFocusButton> createState() => _TvFocusButtonState();
}

class _TvFocusButtonState extends State<_TvFocusButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;

    return FocusableActionDetector(
      autofocus: widget.autofocus,
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => widget.onPressed(),
        ),
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _isFocused ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: _isFocused
                  ? Border.all(color: tokens.accent, width: 2.5)
                  : null,
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: tokens.accent.withValues(alpha: 0.4),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: widget.tooltip != null
                ? Tooltip(message: widget.tooltip ?? '', child: widget.child)
                : widget.child,
          ),
        ),
      ),
    );
  }
}
