import 'dart:async';

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/data/models/stats_models.dart';
import 'package:awady_music/data/repositories/stats_repository.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/rewind.dart';
import 'package:awady_music/widgets/artwork_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:palette_generator/palette_generator.dart';

/// Full-screen stories for monthly listening recap (Rewind).
class RewindScreen extends ConsumerStatefulWidget {
  const RewindScreen({super.key, this.month});

  final String? month;

  @override
  ConsumerState<RewindScreen> createState() => _RewindScreenState();
}

class _RewindScreenState extends ConsumerState<RewindScreen>
    with SingleTickerProviderStateMixin {
  static const _durations = [
    Duration(milliseconds: 4600), // Intro
    Duration(milliseconds: 5800), // Minutes
    Duration(milliseconds: 6400), // Top Artist
    Duration(milliseconds: 8600), // Top Tracks
    Duration.zero, // Outro stays until closed
  ];

  late final AnimationController _progressController;
  int _currentIndex = 0;
  Color? _dominantColor;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextSlide();
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startSlide();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _startSlide() {
    _progressController.reset();
    final dur = _currentIndex < _durations.length
        ? _durations[_currentIndex]
        : Duration.zero;
    if (dur > Duration.zero) {
      _progressController.duration = dur;
      _progressController.forward();
    }
  }

  void _nextSlide() {
    if (_currentIndex < 4) {
      setState(() {
        _currentIndex++;
      });
      _startSlide();
    }
  }

  void _prevSlide() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _startSlide();
    }
  }

  void _pause() {
    _progressController.stop();
  }

  void _resume() {
    if (_progressController.duration != null &&
        _progressController.duration! > Duration.zero &&
        !_progressController.isCompleted) {
      _progressController.forward();
    }
  }

  void _extractDominantColor(RewindData data) {
    if (_dominantColor != null) return;
    final topTrack = data.tracks.isNotEmpty ? data.tracks.first.track : null;
    final artUrl =
        topTrack?.artwork?.s480 ??
        topTrack?.artwork?.s150 ??
        topTrack?.artwork?.fallback;
    if (artUrl == null || artUrl.isEmpty || artUrl.contains('example.com')) {
      return;
    }
    unawaited(
      PaletteGenerator.fromImageProvider(
            CachedNetworkImageProvider(artUrl),
            size: const Size(64, 64),
            maximumColorCount: 4,
            timeout: const Duration(seconds: 3),
          )
          .then((palette) {
            if (mounted) {
              final c = palette.dominantColor?.color;
              if (c != null) {
                setState(() {
                  _dominantColor = c;
                });
              }
            }
          })
          .catchError((_) {}),
    );
  }

  TextDirection _detectDirection(String text) {
    return intl.Bidi.detectRtlDirectionality(text)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  String _formatHm(int ms) {
    final h = ms ~/ 3600000;
    final m = ((ms % 3600000) / 60000).round();
    if (h > 0) {
      return '${h}h ${m}m';
    }
    return '${m}m';
  }

  RewindData? _resolveData() {
    final active = ref.watch(rewindControllerProvider);
    if (active != null) return active;

    final stats = ref.watch(statsRepositoryProvider).state;
    final key = widget.month ?? monthKey();
    return buildRewind(key, stats: stats) ??
        buildRewind(key, stats: stats, partial: true) ??
        availableRewind(stats: stats);
  }

  void _playTopTracks(RewindData data) {
    if (data.tracks.isEmpty) return;
    final tracks = data.tracks.map((t) => t.track).toList();
    ref.read(playerControllerProvider.notifier).playTrack(tracks.first, tracks);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;
    final data = _resolveData();

    if (data == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.statsEmptyTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(l10n.cancel),
              ),
            ],
          ),
        ),
      );
    }

    _extractDominantColor(data);
    final washColor = _dominantColor ?? tokens.accent;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) > 300) {
            context.pop();
          }
        },
        child: Stack(
          children: [
            // Ambient wash background
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.2),
                    radius: 1.2,
                    colors: [
                      washColor.withValues(alpha: 0.35),
                      washColor.withValues(alpha: 0.10),
                      Colors.black,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),

            // Tap zones: left 30% for prev, right 70% for next
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTapDown: (_) => _pause(),
                      onTapUp: (_) {
                        _resume();
                        _prevSlide();
                      },
                      onTapCancel: _resume,
                      child: const SizedBox.expand(),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTapDown: (_) => _pause(),
                      onTapUp: (_) {
                        _resume();
                        _nextSlide();
                      },
                      onTapCancel: _resume,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),

            // Main slide content
            Positioned.fill(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.04),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey<int>(_currentIndex),
                        child: _buildSlideContent(
                          _currentIndex,
                          data,
                          tokens,
                          l10n,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Top story progress bar and close button
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // 5 Story segments
                      Expanded(
                        child: Row(
                          children: List.generate(5, (index) {
                            return Expanded(
                              child: Container(
                                height: 3,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: _buildSegmentProgress(index),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Close button
                      IconButton(
                        icon: const Icon(
                          LucideIcons.x,
                          color: Colors.white,
                          size: 20,
                        ),
                        tooltip: l10n.rewindClose,
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentProgress(int index) {
    if (index < _currentIndex) {
      return Container(color: Colors.white);
    }
    if (index == _currentIndex) {
      return AnimatedBuilder(
        animation: _progressController,
        builder: (context, _) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _currentIndex == 4 ? 1.0 : _progressController.value,
            child: Container(color: Colors.white),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSlideContent(
    int index,
    RewindData data,
    GlassTokens tokens,
    L10n l10n,
  ) {
    switch (index) {
      case 0:
        return _buildIntroSlide(data, tokens, l10n);
      case 1:
        return _buildMinutesSlide(data, tokens, l10n);
      case 2:
        return _buildArtistSlide(data, tokens, l10n);
      case 3:
        return _buildTracksSlide(data, tokens, l10n);
      case 4:
      default:
        return _buildOutroSlide(data, tokens, l10n);
    }
  }

  // Slide 0: Intro (month, tag)
  Widget _buildIntroSlide(RewindData data, GlassTokens tokens, L10n l10n) {
    final tag = data.partial ? l10n.rewindIntroTagPartial : l10n.rewindIntroTag;
    final line = data.partial
        ? l10n.rewindIntroLinePartial
        : l10n.rewindIntroLine;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.sparkles, size: 48, color: tokens.accent),
        const SizedBox(height: 20),
        Text(
          tag.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: tokens.accent,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          data.label.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            height: 1.05,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'REWIND',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 8,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          line,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: tokens.textDim, height: 1.4),
        ),
      ],
    );
  }

  // Slide 1: "you listened for" big minutes
  Widget _buildMinutesSlide(RewindData data, GlassTokens tokens, L10n l10n) {
    final minutes = (data.ms / 60000).round();
    final playsText = l10n.rewindPlaysAcross(
      _formatHm(data.ms),
      data.plays.toString(),
      data.trackCount.toString(),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.rewindListenedFor.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: tokens.textDim,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$minutes',
              style: const TextStyle(
                fontSize: 84,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -2,
                height: 1,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.rewindMin,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: tokens.textDim,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          playsText,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: tokens.textDim, height: 1.4),
        ),
        const SizedBox(height: 32),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildGlassChip(
              LucideIcons.disc,
              l10n.rewindChipTracks(data.trackCount.toString()),
              tokens,
            ),
            _buildGlassChip(
              LucideIcons.users,
              l10n.rewindChipArtists(data.artistCount.toString()),
              tokens,
            ),
            _buildGlassChip(
              LucideIcons.clock,
              l10n.rewindChipTotal(_formatHm(data.ms)),
              tokens,
            ),
          ],
        ),
      ],
    );
  }

  // Slide 2: top artist
  Widget _buildArtistSlide(RewindData data, GlassTokens tokens, L10n l10n) {
    final topArtist = data.artists.isNotEmpty ? data.artists.first : null;
    final artistName = topArtist?.name ?? '—';
    final artistMs = topArtist?.ms ?? 0;
    final artistPlays = topArtist?.plays ?? 0;
    final statsText = l10n.rewindArtistStats(
      artistPlays.toString(),
      _formatHm(artistMs),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.rewindTopArtist.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: tokens.textDim,
          ),
        ),
        const SizedBox(height: 24),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: topArtist?.art != null && topArtist!.art!.isNotEmpty
                    ? ArtworkImage(url: topArtist.art, size: 180, radius: 90)
                    : Container(
                        color: tokens.glassFillStrong,
                        alignment: Alignment.center,
                        child: Text(
                          artistName.isNotEmpty ? artistName[0] : '?',
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tokens.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  '1',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          artistName,
          textAlign: TextAlign.center,
          textDirection: _detectDirection(artistName),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          statsText,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: tokens.textDim),
        ),
      ],
    );
  }

  // Slide 3: top 5 songs ("The songs you couldn't stop")
  Widget _buildTracksSlide(RewindData data, GlassTokens tokens, L10n l10n) {
    final topTracks = data.tracks.take(5).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.rewindOnRepeat.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: tokens.textDim,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.rewindTracksTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(topTracks.length, (i) {
          final item = topTracks[i];
          final track = item.track;
          final isFirst = i == 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isFirst
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFirst
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isFirst ? Colors.white : tokens.textDim,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ArtworkImage(art: track.artwork, size: 40, radius: 8),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: _detectDirection(track.title),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        track.artist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: _detectDirection(track.artist.name),
                        style: TextStyle(fontSize: 12, color: tokens.textDim),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.play, size: 11, color: tokens.textDim),
                    const SizedBox(width: 3),
                    Text(
                      '${item.plays}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: tokens.textDim,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        Center(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.accent,
              foregroundColor: Colors.black,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(LucideIcons.play, size: 16),
            label: Text(
              l10n.rewindPlayTop,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => _playTopTracks(data),
          ),
        ),
      ],
    );
  }

  // Slide 4: Outro summary chips + CTA
  Widget _buildOutroSlide(RewindData data, GlassTokens tokens, L10n l10n) {
    final topTrack = data.tracks.isNotEmpty ? data.tracks.first.track : null;
    final topArtist = data.artists.isNotEmpty ? data.artists.first : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.rewindThatWas.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: tokens.textDim,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${data.label}.',
          style: const TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),

        // Summary Glass Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.glassFill,
            borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
            border: Border.all(color: tokens.glassStroke),
          ),
          child: Column(
            children: [
              if (topTrack != null)
                Row(
                  children: [
                    ArtworkImage(art: topTrack.artwork, size: 52, radius: 10),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topTrack.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: _detectDirection(topTrack.title),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            topTrack.artist.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: _detectDirection(
                              topTrack.artist.name,
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              color: tokens.textDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (topArtist != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          topArtist.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: tokens.textDim),
                        ),
                      ),
                    ],
                  ],
                ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildGlassChip(
                    LucideIcons.clock,
                    _formatHm(data.ms),
                    tokens,
                  ),
                  _buildGlassChip(
                    LucideIcons.disc,
                    l10n.rewindChipPlays(data.plays.toString()),
                    tokens,
                  ),
                  _buildGlassChip(
                    LucideIcons.users,
                    l10n.rewindChipArtists(data.artistCount.toString()),
                    tokens,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.accent,
                foregroundColor: Colors.black,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
              ),
              icon: const Icon(LucideIcons.play, size: 16),
              label: Text(
                l10n.rewindPlayAgain,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => _playTopTracks(data),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(l10n.rewindKeepListening),
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassChip(IconData icon, String text, GlassTokens tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: tokens.textDim),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
