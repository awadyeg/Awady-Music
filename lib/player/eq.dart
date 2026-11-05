import 'dart:async';

import 'package:awady_music/core/util/log.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// The 7 target equalizer frequencies in Hz ported from upstream
/// `EqPopover.tsx`.
const List<double> desktopEqFrequencies = [
  60,
  250,
  500,
  1000,
  4000,
  8000,
  14000,
];

/// The display labels for the 7 equalizer bands.
const List<String> desktopBandLabels = [
  '60',
  '250',
  '500',
  '1K',
  '4K',
  '8K',
  '14K',
];

/// Equalizer presets ported from upstream `EqPopover.tsx`.
/// Gains are in dB within the range [-12, +12].
const Map<String, List<double>> eqPresets = {
  'flat': [0, 0, 0, 0, 0, 0, 0],
  'bass': [6, 4, 1, 0, 0, 1, 2],
  'vocal': [-2, 0, 3, 5, 4, 2, 0],
  'bright': [-1, 0, 1, 2, 4, 6, 7],
  'vshape': [6, 3, 0, -1, 0, 3, 6],
};

const double eqMinGain = -12;
const double eqMaxGain = 12;

/// Maps a hardware/device equalizer band with [centerFrequency] in Hz to the
/// nearest desktop 7-band index by absolute frequency difference.
int mapDeviceBandToDesktopIndex(
  double centerFrequency, [
  List<double> desktopFrequencies = desktopEqFrequencies,
]) {
  if (desktopFrequencies.isEmpty) return 0;
  var closestIdx = 0;
  var minDiff = (centerFrequency - desktopFrequencies[0]).abs();
  for (var i = 1; i < desktopFrequencies.length; i++) {
    final diff = (centerFrequency - desktopFrequencies[i]).abs();
    if (diff < minDiff) {
      minDiff = diff;
      closestIdx = i;
    }
  }
  return closestIdx;
}

/// Identifies if the current gains list matches any preset in [eqPresets].
String? detectEqPreset(List<double> eqGains) {
  if (eqGains.length < 7) return null;
  for (final entry in eqPresets.entries) {
    var match = true;
    for (var i = 0; i < 7; i++) {
      if ((eqGains[i] - entry.value[i]).abs() > 0.001) {
        match = false;
        break;
      }
    }
    if (match) return entry.key;
  }
  return null;
}

/// Controls the device equalizer with platform guards (Android hardware EQ
/// only).
class EqualizerController {
  EqualizerController({
    this.equalizer,
    @visibleForTesting this.platformOverride,
  });

  final AndroidEqualizer? equalizer;
  final TargetPlatform? platformOverride;

  bool get isSupported {
    final platform = platformOverride ?? defaultTargetPlatform;
    return platform == TargetPlatform.android && equalizer != null;
  }

  /// Applies the 7-band desktop gains to the underlying Android hardware
  /// equalizer. On non-Android platforms or when hardware equalizer is
  /// unavailable, this is a safe no-op.
  Future<void> applyGains(List<double> gains) async {
    if (!isSupported || equalizer == null) return;

    try {
      final hasNonZero = gains.any((g) => g != 0);
      await equalizer!.setEnabled(hasNonZero);
      if (!hasNonZero) return;

      final parameters = await equalizer!.parameters;
      for (final band in parameters.bands) {
        final desktopIdx = mapDeviceBandToDesktopIndex(band.centerFrequency);
        final desktopGain = desktopIdx < gains.length ? gains[desktopIdx] : 0.0;
        final clampedGain = desktopGain.clamp(
          parameters.minDecibels,
          parameters.maxDecibels,
        );
        await band.setGain(clampedGain);
      }
    } on Object catch (e, st) {
      Log.w('Failed to apply AndroidEqualizer gains: $e', e, st);
    }
  }
}
