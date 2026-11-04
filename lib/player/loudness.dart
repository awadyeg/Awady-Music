import 'dart:math';

/// Calculates loudness gain in dB from YouTube/Innertube [loudnessDb].
/// Clamps between -6.0 dB and +6.0 dB per spec (plan.md §5).
double computeLoudnessGainDb(double? loudnessDb, {bool normOn = true}) {
  if (!normOn || loudnessDb == null) return 0;
  return (-loudnessDb).clamp(-6, 6).toDouble();
}

/// Converts loudness gain in dB to a linear volume multiplier.
double computeLoudnessMultiplier(double? loudnessDb, {bool normOn = true}) {
  final db = computeLoudnessGainDb(loudnessDb, normOn: normOn);
  return pow(10, db / 20).toDouble();
}
