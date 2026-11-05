import 'dart:math' as math;

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/widgets/glass_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum SleepOption {
  off,
  min5,
  min15,
  min30,
  min45,
  min60,
  endOfTrack;

  int? get minutes => switch (this) {
    SleepOption.off => null,
    SleepOption.min5 => 5,
    SleepOption.min15 => 15,
    SleepOption.min30 => 30,
    SleepOption.min45 => 45,
    SleepOption.min60 => 60,
    SleepOption.endOfTrack => null,
  };
}

/// Glass modal bottom sheet allowing the user to set or clear a sleep timer.
class SleepTimerSheet extends ConsumerWidget {
  const SleepTimerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showGlassBottomSheet(
      context: context,
      builder: (context) => const SleepTimerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;
    final playerState = ref.watch(playerControllerProvider);
    final sleepAt = playerState.sleepAt;

    String? activeReadout;
    if (sleepAt != null) {
      final diff = sleepAt.difference(DateTime.now());
      final mins = math.max(1, (diff.inSeconds / 60).ceil());
      activeReadout = l10n.eqSleepIn(mins.toString());
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tokens.glassFill,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: tokens.glassStroke),
                ),
                child: Icon(
                  LucideIcons.timer,
                  size: 18,
                  color: sleepAt != null ? tokens.accent : tokens.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.sleepTimerTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: tokens.textPrimary,
                      ),
                    ),
                    Text(
                      activeReadout ?? l10n.sleepTimerOff,
                      style: TextStyle(
                        fontSize: 12,
                        color: sleepAt != null ? tokens.accent : tokens.textDim,
                        fontWeight: sleepAt != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Options list
          _buildOptionTile(
            context: context,
            title: l10n.sleepTimerOff,
            isSelected: sleepAt == null,
            tokens: tokens,
            onTap: () {
              ref.read(playerControllerProvider.notifier).setSleepTimer(null);
              Navigator.of(context).pop();
            },
          ),
          _buildOptionTile(
            context: context,
            title: l10n.sleepTimer5,
            isSelected: _isDurationSelected(sleepAt, 5),
            tokens: tokens,
            onTap: () {
              ref.read(playerControllerProvider.notifier).setSleepTimer(5);
              Navigator.of(context).pop();
            },
          ),
          _buildOptionTile(
            context: context,
            title: l10n.sleepTimer15,
            isSelected: _isDurationSelected(sleepAt, 15),
            tokens: tokens,
            onTap: () {
              ref.read(playerControllerProvider.notifier).setSleepTimer(15);
              Navigator.of(context).pop();
            },
          ),
          _buildOptionTile(
            context: context,
            title: l10n.sleepTimer30,
            isSelected: _isDurationSelected(sleepAt, 30),
            tokens: tokens,
            onTap: () {
              ref.read(playerControllerProvider.notifier).setSleepTimer(30);
              Navigator.of(context).pop();
            },
          ),
          _buildOptionTile(
            context: context,
            title: l10n.sleepTimer45,
            isSelected: _isDurationSelected(sleepAt, 45),
            tokens: tokens,
            onTap: () {
              ref.read(playerControllerProvider.notifier).setSleepTimer(45);
              Navigator.of(context).pop();
            },
          ),
          _buildOptionTile(
            context: context,
            title: l10n.sleepTimer60,
            isSelected: _isDurationSelected(sleepAt, 60),
            tokens: tokens,
            onTap: () {
              ref.read(playerControllerProvider.notifier).setSleepTimer(60);
              Navigator.of(context).pop();
            },
          ),
          _buildOptionTile(
            context: context,
            title: l10n.sleepTimerTrackEnd,
            isSelected: false,
            tokens: tokens,
            onTap: () {
              final remaining = playerState.duration - playerState.currentTime;
              final dur = remaining > Duration.zero
                  ? remaining
                  : const Duration(minutes: 3);
              ref
                  .read(playerControllerProvider.notifier)
                  .setSleepTimerDuration(dur);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  bool _isDurationSelected(DateTime? sleepAt, int targetMins) {
    if (sleepAt == null) return false;
    final diff = sleepAt.difference(DateTime.now());
    final remainingMins = (diff.inSeconds / 60).round();
    return (remainingMins - targetMins).abs() <= 1;
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required GlassTokens tokens,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? tokens.accent.withValues(alpha: 0.12)
            : tokens.glassFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? tokens.accent.withValues(alpha: 0.4)
              : tokens.glassStroke,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? tokens.accent : tokens.textPrimary,
                ),
              ),
              if (isSelected)
                Icon(LucideIcons.check, size: 16, color: tokens.accent),
            ],
          ),
        ),
      ),
    );
  }
}
