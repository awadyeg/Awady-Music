import 'dart:async';
import 'dart:ui';

import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/features/tv/tv_browser_views.dart';
import 'package:awady_music/features/tv/tv_focus_button.dart';
import 'package:awady_music/features/tv/tv_now_playing_view.dart';
import 'package:awady_music/player/connect_receiver.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/player_state.dart';
import 'package:awady_music/widgets/artwork_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum TvTab { home, search, library, nowPlaying, settings }

class _TvPlayPauseIntent extends Intent {
  const _TvPlayPauseIntent();
}

class _TvNextIntent extends Intent {
  const _TvNextIntent();
}

class _TvPrevIntent extends Intent {
  const _TvPrevIntent();
}

class _TvBackIntent extends Intent {
  const _TvBackIntent();
}

/// Standalone Android TV Navigation Shell with D-pad navigation,
/// TV sidebar (Home, Search, Library, Now Playing, Settings), and responsive
/// layout optimized for 540dp/1080p TV viewports.
class TvHomeScreen extends ConsumerStatefulWidget {
  const TvHomeScreen({this.onExitTvMode, super.key});

  final VoidCallback? onExitTvMode;

  @override
  ConsumerState<TvHomeScreen> createState() => _TvHomeScreenState();
}

class _TvHomeScreenState extends ConsumerState<TvHomeScreen> {
  TvTab _currentTab = TvTab.home;
  TvTab _previousTab = TvTab.home;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(connectReceiverProvider.notifier).start());
    });
  }

  void _handleSelectTrack(Track track, List<Track> queue, int index) {
    ref.read(playerControllerProvider.notifier).playContext(queue, index);
    setState(() {
      _previousTab = _currentTab;
      _currentTab = TvTab.nowPlaying;
    });
  }

  void _handleBack() {
    if (_currentTab != TvTab.home) {
      setState(() => _currentTab = TvTab.home);
    } else {
      unawaited(ref.read(settingsProvider.notifier).setTvMode('off'));
      widget.onExitTvMode?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;
    final ps = ref.watch(playerControllerProvider);
    final player = ref.read(playerControllerProvider.notifier);
    final curTrack = ps.current;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.mediaPlayPause):
              _TvPlayPauseIntent(),
          SingleActivator(LogicalKeyboardKey.mediaPlay): _TvPlayPauseIntent(),
          SingleActivator(LogicalKeyboardKey.mediaPause): _TvPlayPauseIntent(),
          SingleActivator(LogicalKeyboardKey.mediaTrackNext): _TvNextIntent(),
          SingleActivator(LogicalKeyboardKey.mediaTrackPrevious):
              _TvPrevIntent(),
          SingleActivator(LogicalKeyboardKey.escape): _TvBackIntent(),
          SingleActivator(LogicalKeyboardKey.backspace): _TvBackIntent(),
          SingleActivator(LogicalKeyboardKey.goBack): _TvBackIntent(),
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
            _TvBackIntent: CallbackAction<_TvBackIntent>(
              onInvoke: (_) {
                _handleBack();
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

                // Subtle dark glass tint
                Container(color: Colors.black.withValues(alpha: 0.5)),

                // Main TV Navigation Shell
                SafeArea(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left TV Navigation Rail
                      _buildTvSidebar(tokens, curTrack),

                      const VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: Color(0x1FFFFFFF),
                      ),

                      // Right Content Area
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: _buildActiveContentView(curTrack),
                            ),

                            // Persistent TV Mini Player (when browsing)
                            if (_currentTab != TvTab.nowPlaying &&
                                curTrack != null)
                              Positioned(
                                left: 16,
                                right: 24,
                                bottom: 12,
                                child: _buildTvMiniPlayer(tokens, curTrack, ps),
                              ),
                          ],
                        ),
                      ),
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

  Widget _buildTvSidebar(GlassTokens tokens, Track? curTrack) {
    return Container(
      width: 68,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          // App Logo
          Icon(LucideIcons.music, color: tokens.accent, size: 26),
          const SizedBox(height: 18),

          // Home
          _buildSidebarItem(
            icon: LucideIcons.house,
            label: 'Home',
            tab: TvTab.home,
            tokens: tokens,
            autofocus: true,
          ),
          const SizedBox(height: 10),

          // Search
          _buildSidebarItem(
            icon: LucideIcons.search,
            label: 'Search',
            tab: TvTab.search,
            tokens: tokens,
          ),
          const SizedBox(height: 10),

          // Library
          _buildSidebarItem(
            icon: LucideIcons.library,
            label: 'Library',
            tab: TvTab.library,
            tokens: tokens,
          ),
          const SizedBox(height: 10),

          // Now Playing
          _buildSidebarItem(
            icon: LucideIcons.disc,
            label: 'Now Playing',
            tab: TvTab.nowPlaying,
            tokens: tokens,
          ),
          const SizedBox(height: 10),

          // Settings
          _buildSidebarItem(
            icon: LucideIcons.settings,
            label: 'Settings',
            tab: TvTab.settings,
            tokens: tokens,
          ),

          const Spacer(),

          // Exit TV Mode
          TvFocusButton(
            onPressed: () {
              unawaited(ref.read(settingsProvider.notifier).setTvMode('off'));
              widget.onExitTvMode?.call();
            },
            tooltip: 'Exit TV Mode',
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tokens.glassFill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                LucideIcons.minimize2,
                color: tokens.textDim,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required TvTab tab,
    required GlassTokens tokens,
    bool autofocus = false,
  }) {
    final isSelected = _currentTab == tab;

    return TvFocusButton(
      autofocus: autofocus,
      onPressed: () {
        setState(() {
          _previousTab = _currentTab;
          _currentTab = tab;
        });
      },
      tooltip: label,
      borderRadius: 12,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? tokens.accent.withValues(alpha: 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? tokens.accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? tokens.accent : tokens.textDim,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildActiveContentView(Track? curTrack) {
    switch (_currentTab) {
      case TvTab.home:
        return TvHomeView(onSelectTrack: _handleSelectTrack);
      case TvTab.search:
        return TvSearchView(onSelectTrack: _handleSelectTrack);
      case TvTab.library:
        return TvLibraryView(onSelectTrack: _handleSelectTrack);
      case TvTab.nowPlaying:
        if (curTrack == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.disc, size: 54, color: Colors.white24),
                const SizedBox(height: 12),
                const Text(
                  'No track is currently playing',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                TvFocusButton(
                  onPressed: () => setState(() => _currentTab = TvTab.home),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).glass.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Browse Music',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: TvNowPlayingView(
            track: curTrack,
            onBackToBrowse: () {
              setState(() => _currentTab = _previousTab);
            },
          ),
        );
      case TvTab.settings:
        return const TvSettingsView();
    }
  }

  Widget _buildTvMiniPlayer(GlassTokens tokens, Track track, PlayerState ps) {
    final player = ref.read(playerControllerProvider.notifier);

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xEE161822),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tokens.accent.withValues(alpha: 0.3)),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 16, spreadRadius: 2),
        ],
      ),
      child: Row(
        children: [
          TvFocusButton(
            onPressed: () {
              setState(() {
                _previousTab = _currentTab;
                _currentTab = TvTab.nowPlaying;
              });
            },
            borderRadius: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 36,
                height: 36,
                child: ArtworkImage(art: track.artwork, size: 72),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _previousTab = _currentTab;
                  _currentTab = TvTab.nowPlaying;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: tokens.textPrimary,
                    ),
                  ),
                  Text(
                    track.artist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: tokens.textDim),
                  ),
                ],
              ),
            ),
          ),
          TvFocusButton(
            onPressed: player.prev,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                LucideIcons.skipBack,
                color: tokens.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 6),
          TvFocusButton(
            onPressed: player.toggle,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: tokens.accent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                ps.isPlaying ? LucideIcons.pause : LucideIcons.play,
                color: tokens.onAccent,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 6),
          TvFocusButton(
            onPressed: player.next,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                LucideIcons.skipForward,
                color: tokens.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          TvFocusButton(
            onPressed: () {
              setState(() {
                _previousTab = _currentTab;
                _currentTab = TvTab.nowPlaying;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tokens.accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: tokens.accent),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.disc, color: tokens.accent, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Full Player',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: tokens.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
