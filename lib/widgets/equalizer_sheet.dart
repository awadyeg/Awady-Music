import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/player/eq.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/widgets/glass_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Modal bottom sheet for equalizer, volume normalization, and crossfade.
class EqualizerSheet extends ConsumerWidget {
  const EqualizerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showGlassBottomSheet(
      context: context,
      maxHeightFraction: 0.90,
      builder: (context) => const EqualizerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;
    final playerState = ref.watch(playerControllerProvider);
    final gains = playerState.eq.length >= 7
        ? playerState.eq
        : List<double>.filled(7, 0);
    final currentPreset = detectEqPreset(gains);
    final isCustom = currentPreset == null && gains.any((g) => g != 0);
    final isEqEnabled = gains.any((g) => g != 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Icon, Title, Enable switch & Reset
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
                  LucideIcons.sliders,
                  size: 18,
                  color: isEqEnabled ? tokens.accent : tokens.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.eqTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: tokens.textPrimary,
                      ),
                    ),
                    Text(
                      isEqEnabled
                          ? (currentPreset ?? l10n.eqCustom)
                          : l10n.eqOff,
                      style: TextStyle(
                        fontSize: 12,
                        color: isEqEnabled ? tokens.accent : tokens.textDim,
                        fontWeight: isEqEnabled
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.rotateCcw, size: 18),
                tooltip: l10n.eqResetTitle,
                color: tokens.textDim,
                onPressed: () {
                  ref
                      .read(playerControllerProvider.notifier)
                      .setEqPreset('flat');
                },
              ),
              Switch.adaptive(
                value: isEqEnabled,
                activeTrackColor: tokens.accent,
                onChanged: (enabled) {
                  if (enabled) {
                    ref
                        .read(playerControllerProvider.notifier)
                        .setEqPreset('bass');
                  } else {
                    ref
                        .read(playerControllerProvider.notifier)
                        .setEqPreset('flat');
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Preset Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPresetChip(
                  label: l10n.eqPresetFlat,
                  isSelected: currentPreset == 'flat',
                  tokens: tokens,
                  onTap: () {
                    ref
                        .read(playerControllerProvider.notifier)
                        .setEqPreset('flat');
                  },
                ),
                _buildPresetChip(
                  label: l10n.eqPresetBass,
                  isSelected: currentPreset == 'bass',
                  tokens: tokens,
                  onTap: () {
                    ref
                        .read(playerControllerProvider.notifier)
                        .setEqPreset('bass');
                  },
                ),
                _buildPresetChip(
                  label: l10n.eqPresetBright,
                  isSelected: currentPreset == 'bright',
                  tokens: tokens,
                  onTap: () {
                    ref
                        .read(playerControllerProvider.notifier)
                        .setEqPreset('bright');
                  },
                ),
                _buildPresetChip(
                  label: l10n.eqPresetVocal,
                  isSelected: currentPreset == 'vocal',
                  tokens: tokens,
                  onTap: () {
                    ref
                        .read(playerControllerProvider.notifier)
                        .setEqPreset('vocal');
                  },
                ),
                _buildPresetChip(
                  label: l10n.eqPresetVshape,
                  isSelected: currentPreset == 'vshape',
                  tokens: tokens,
                  onTap: () {
                    ref
                        .read(playerControllerProvider.notifier)
                        .setEqPreset('vshape');
                  },
                ),
                if (isCustom)
                  _buildPresetChip(
                    label: l10n.eqPresetCustom,
                    isSelected: true,
                    tokens: tokens,
                    onTap: () {},
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 7-Band Equalizer Sliders
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: BoxDecoration(
              color: tokens.glassFill,
              borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
              border: Border.all(color: tokens.glassStroke),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '+12 dB',
                      style: TextStyle(fontSize: 10, color: tokens.textFaint),
                    ),
                    Text(
                      '0 dB',
                      style: TextStyle(fontSize: 10, color: tokens.textFaint),
                    ),
                    Text(
                      '-12 dB',
                      style: TextStyle(fontSize: 10, color: tokens.textFaint),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (i) {
                    final gain = gains[i];
                    final label = desktopBandLabels[i];
                    return _buildBandColumn(
                      index: i,
                      label: label,
                      gain: gain,
                      tokens: tokens,
                      onChanged: (newGain) {
                        ref
                            .read(playerControllerProvider.notifier)
                            .setEqBand(i, newGain);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Normalize Volume Switch Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: tokens.glassFill,
              borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
              border: Border.all(color: tokens.glassStroke),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.eqNormalize,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: tokens.textPrimary,
                      ),
                    ),
                    Text(
                      playerState.normOn
                          ? 'Automatic gain control'
                          : l10n.eqOff,
                      style: TextStyle(fontSize: 12, color: tokens.textDim),
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: playerState.normOn,
                  activeTrackColor: tokens.accent,
                  onChanged: (val) {
                    ref
                        .read(playerControllerProvider.notifier)
                        .setNormOn(value: val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Crossfade Slider Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: tokens.glassFill,
              borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
              border: Border.all(color: tokens.glassStroke),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.eqCrossfade,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: tokens.textPrimary,
                      ),
                    ),
                    Text(
                      playerState.fadeSecs == 0
                          ? l10n.eqOff
                          : '${playerState.fadeSecs}s',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: playerState.fadeSecs > 0
                            ? tokens.accent
                            : tokens.textDim,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: tokens.accent,
                    inactiveTrackColor: tokens.glassStroke,
                    thumbColor: tokens.accent,
                    overlayColor: tokens.accent.withValues(alpha: 0.15),
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                  ),
                  child: Slider(
                    value: playerState.fadeSecs.toDouble(),
                    max: 12,
                    divisions: 12,
                    onChanged: (val) {
                      ref
                          .read(playerControllerProvider.notifier)
                          .setFadeSecs(val.round());
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    required bool isSelected,
    required GlassTokens tokens,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? tokens.accent : tokens.glassFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? tokens.accent : tokens.glassStroke,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : tokens.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBandColumn({
    required int index,
    required String label,
    required double gain,
    required GlassTokens tokens,
    required ValueChanged<double> onChanged,
  }) {
    final gainText = gain > 0
        ? '+${gain.round()}'
        : (gain < 0 ? '${gain.round()}' : '0');

    return Column(
      children: [
        Text(
          gainText,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: gain != 0 ? tokens.accent : tokens.textDim,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 120,
          width: 32,
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: tokens.accent,
                inactiveTrackColor: tokens.glassStroke,
                thumbColor: gain != 0 ? tokens.accent : Colors.white,
                overlayColor: tokens.accent.withValues(alpha: 0.15),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: gain.clamp(eqMinGain, eqMaxGain),
                min: eqMinGain,
                max: eqMaxGain,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: tokens.textDim,
          ),
        ),
      ],
    );
  }
}
