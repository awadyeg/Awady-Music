import 'dart:async';
import 'dart:math' as math;

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/core/util/format.dart';
import 'package:awady_music/data/repositories/stats_repository.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/player/rewind.dart';
import 'package:awady_music/widgets/artwork_image.dart';
import 'package:awady_music/widgets/large_title_scaffold.dart';
import 'package:awady_music/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Screen displaying user listening stats, 7-day bar chart, top tracks and
/// top artists.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

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

  String _narrowWeekday(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'M';
      case DateTime.tuesday:
        return 'T';
      case DateTime.wednesday:
        return 'W';
      case DateTime.thursday:
        return 'T';
      case DateTime.friday:
        return 'F';
      case DateTime.saturday:
        return 'S';
      case DateTime.sunday:
        return 'S';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;
    final statsRepo = ref.watch(statsRepositoryProvider);
    final stats = statsRepo.state;

    final rewind = availableRewind(stats: stats);
    final totalPlays = stats.totalPlays;
    final empty = totalPlays == 0;

    // Last 7 days data
    final today = dayKey();
    final now = DateTime.now();
    final week = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      final k = dayKey(d);
      return (day: k, ms: stats.days[k] ?? 0, label: _narrowWeekday(d));
    });

    final weekMs = week.fold<int>(0, (sum, d) => sum + d.ms);

    final topTracks = stats.tracks.values.toList()
      ..sort((a, b) => b.ms.compareTo(a.ms));
    final topArtists = stats.artists.values.toList()
      ..sort((a, b) => b.ms.compareTo(a.ms));

    return LargeTitleScaffold(
      title: l10n.statsTitle,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            Text(
              l10n.statsSubtitle,
              style: TextStyle(fontSize: 14, color: tokens.textDim),
            ),
            const SizedBox(height: 16),

            // Rewind button banner if available
            if (rewind != null) ...[
              ContentSurface(
                radius: 16,
                child: InkWell(
                  onTap: () {
                    ref.read(rewindControllerProvider.notifier).open(rewind);
                    unawaited(context.push('/home/rewind/${rewind.key}'));
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.sparkles,
                          size: 20,
                          color: tokens.accent,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            rewind.partial
                                ? l10n.statsRewindPartial(rewind.label)
                                : l10n.statsRewindFull(rewind.label),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: tokens.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 18,
                          color: tokens.textDim,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (empty)
              Padding(
                padding: const EdgeInsets.only(top: 60, bottom: 60),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.chartBar,
                        size: 54,
                        color: tokens.textDim,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.statsEmptyTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          l10n.statsEmptyHint,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: tokens.textDim),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // 4 Stat Cards (2x2 Grid)
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: LucideIcons.clock,
                      label: l10n.statsThisWeek,
                      value: '${(weekMs / 3600000).toStringAsFixed(1)}h',
                      tokens: tokens,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      icon: LucideIcons.disc,
                      label: l10n.statsTotalPlays,
                      value: FormatUtils.formatCompactNumber(totalPlays),
                      tokens: tokens,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: LucideIcons.music,
                      label: l10n.statsTracksPlayed,
                      value: FormatUtils.formatCompactNumber(
                        stats.tracks.length,
                      ),
                      tokens: tokens,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      icon: LucideIcons.users,
                      label: l10n.statsArtistsHeard,
                      value: FormatUtils.formatCompactNumber(
                        stats.artists.length,
                      ),
                      tokens: tokens,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 7-day Bar Chart card
              ContentSurface(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.statsListeningTime,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: tokens.textDim,
                            ),
                          ),
                          Text(
                            l10n.statsWeekTotal(_formatHm(weekMs)),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: tokens.textDim,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 90,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: _WeekBarChartPainter(
                            weekData: week,
                            todayKey: today,
                            accentColor: tokens.accent,
                            tokens: tokens,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Top Tracks Section
              SectionHeader(title: l10n.statsTopTracks),
              const SizedBox(height: 8),
              if (topTracks.isEmpty)
                Text(
                  'No top tracks yet.',
                  style: TextStyle(color: tokens.textDim),
                )
              else
                ...topTracks.take(5).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return InkWell(
                    onTap: () {
                      ref
                          .read(playerControllerProvider.notifier)
                          .playTrack(item.track);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 22,
                            child: Text(
                              '${index + 1}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: tokens.textDim,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ArtworkImage(
                            art: item.track.artwork,
                            size: 44,
                            radius: 8,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.track.title,
                                  textDirection: _detectDirection(
                                    item.track.title,
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: tokens.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.track.artist.name,
                                  textDirection: _detectDirection(
                                    item.track.artist.name,
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: tokens.textDim,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.play,
                                size: 12,
                                color: tokens.textDim,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${item.plays}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: tokens.textDim,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                FormatUtils.formatDuration(item.ms ~/ 1000),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: tokens.textDim,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 24),

              // Top Artists Section
              SectionHeader(title: l10n.statsTopArtists),
              const SizedBox(height: 8),
              if (topArtists.isEmpty)
                Text(
                  'No top artists yet.',
                  style: TextStyle(color: tokens.textDim),
                )
              else
                ...topArtists.take(5).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final artist = entry.value;
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (artist.name.trim().isNotEmpty) {
                        final encodedId = Uri.encodeComponent(
                          'yt-${artist.name}',
                        );
                        final encodedName = Uri.encodeComponent(artist.name);
                        unawaited(
                          context.push('/artist/$encodedId?n=$encodedName'),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 22,
                            child: Text(
                              '${index + 1}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: tokens.textDim,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ClipOval(
                            child: Container(
                              width: 44,
                              height: 44,
                              color: tokens.bgElevated,
                              child: Center(
                                child: Text(
                                  artist.name.isNotEmpty
                                      ? artist.name[0].toUpperCase()
                                      : 'A',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: tokens.accent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              artist.name,
                              textDirection: _detectDirection(artist.name),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: tokens.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.play,
                                size: 12,
                                color: tokens.textDim,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${artist.plays}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: tokens.textDim,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                FormatUtils.formatDuration(artist.ms ~/ 1000),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: tokens.textDim,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: GlassTokens.shellScrollPadding),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required GlassTokens tokens,
  }) {
    return ContentSurface(
      radius: 16,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: tokens.textDim),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 12, color: tokens.textDim),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: tokens.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekBarChartPainter extends CustomPainter {
  _WeekBarChartPainter({
    required this.weekData,
    required this.todayKey,
    required this.accentColor,
    required this.tokens,
  });

  final List<({String day, int ms, String label})> weekData;
  final String todayKey;
  final Color accentColor;
  final GlassTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    if (weekData.isEmpty) return;

    final peak = weekData.fold<int>(1, (max, d) => d.ms > max ? d.ms : max);

    const bottomLabelHeight = 20.0;
    final chartHeight = size.height - bottomLabelHeight;
    final barCount = weekData.length;
    final availableWidth = size.width;
    final barSlotWidth = availableWidth / barCount;
    final barWidth = math.min<double>(32, barSlotWidth * 0.55);

    final baselineY = chartHeight;
    final baselinePaint = Paint()
      ..color = tokens.glassStroke
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, baselineY),
      Offset(size.width, baselineY),
      baselinePaint,
    );

    for (var i = 0; i < barCount; i++) {
      final item = weekData[i];
      final isToday = item.day == todayKey;
      final slotCenterX = i * barSlotWidth + (barSlotWidth / 2);

      final normalizedHeight = item.ms > 0
          ? math.max<double>(6, (item.ms / peak) * (chartHeight - 8))
          : 3.0;

      final barLeft = slotCenterX - (barWidth / 2);
      final barTop = baselineY - normalizedHeight;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(barLeft, barTop, barWidth, normalizedHeight),
        Radius.circular(barWidth / 2),
      );

      final barPaint = Paint()
        ..color = item.ms > 0
            ? (isToday ? accentColor : accentColor.withValues(alpha: 0.55))
            : tokens.glassFill;

      canvas.drawRRect(rect, barPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: item.label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
            color: isToday ? tokens.textPrimary : tokens.textDim,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final labelX = slotCenterX - (textPainter.width / 2);
      final labelY = baselineY + 5;
      textPainter.paint(canvas, Offset(labelX, labelY));
    }
  }

  @override
  bool shouldRepaint(covariant _WeekBarChartPainter oldDelegate) {
    return oldDelegate.weekData != weekData ||
        oldDelegate.todayKey != todayKey ||
        oldDelegate.accentColor != accentColor;
  }
}
