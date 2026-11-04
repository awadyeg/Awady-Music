import 'dart:ui';

import 'package:flutter/material.dart';

@immutable
class GlassTokens extends ThemeExtension<GlassTokens> {
  const GlassTokens({
    required this.bg,
    required this.bgElevated,
    required this.glassFill,
    required this.glassFillStrong,
    required this.glassStroke,
    required this.glassHighlightStart,
    required this.glassHighlightEnd,
    required this.textPrimary,
    required this.textDim,
    required this.textFaint,
    required this.accent,
    required this.onAccent,
    required this.danger,
    this.blurSigmaBar = 24.0,
    this.blurSigmaSheet = 18.0,
  });

  final Color bg;
  final Color bgElevated;
  final Color glassFill;
  final Color glassFillStrong;
  final Color glassStroke;
  final Color glassHighlightStart;
  final Color glassHighlightEnd;
  final Color textPrimary;
  final Color textDim;
  final Color textFaint;
  final Color accent;
  final Color onAccent;
  final Color danger;
  final double blurSigmaBar;
  final double blurSigmaSheet;

  // Radii
  static const double radiusSmall = 12;
  static const double radiusCard = 20;
  static const double radiusSheet = 28;
  static const double radiusCapsule = 999;

  // Spacing
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;

  // Motion
  static const Duration defaultDuration = Duration(milliseconds: 220);
  static const Curve defaultCurve = Curves.easeOutCubic;

  static const GlassTokens dark = GlassTokens(
    bg: Color(0xFF000000),
    bgElevated: Color(0xFF0E0E10),
    glassFill: Color(0x14FFFFFF), // white @ 8% = 0.08 * 255 = ~20 = 0x14
    glassFillStrong: Color(0x1FFFFFFF), // white @ 12% = 0.12 * 255 = ~31 = 0x1F
    glassStroke: Color(0x24FFFFFF), // white @ 14% = 0.14 * 255 = ~36 = 0x24
    glassHighlightStart: Color(
      0x2EFFFFFF,
    ), // white @ 18% = 0.18 * 255 = ~46 = 0x2E
    glassHighlightEnd: Color(0x00FFFFFF), // white @ 0%
    textPrimary: Color(0xFFFFFFFF),
    textDim: Color(0xA3FFFFFF), // white @ 64% = 0.64 * 255 = ~163 = 0xA3
    textFaint: Color(0x66FFFFFF), // white @ 40% = 0.40 * 255 = ~102 = 0x66
    accent: Color(0xFFFFFFFF),
    onAccent: Color(0xFF000000),
    danger: Color(0xFFFF453A),
  );

  static const GlassTokens light = GlassTokens(
    bg: Color(0xFFF2F2F7),
    bgElevated: Color(0xFFFFFFFF),
    glassFill: Color(0x9EFFFFFF), // white @ 62% = 0.62 * 255 = ~158 = 0x9E
    glassFillStrong: Color(
      0xBFFFFFFF,
    ), // white @ 75% = 0.75 * 255 = ~191 = 0xBF
    glassStroke: Color(0x14000000), // black @ 8% = 0.08 * 255 = ~20 = 0x14
    glassHighlightStart: Color(
      0xE6FFFFFF,
    ), // white @ 90% = 0.90 * 255 = ~230 = 0xE6
    glassHighlightEnd: Color(0x00FFFFFF), // white @ 0%
    textPrimary: Color(0xFF0B0B0C),
    textDim: Color(0x99000000), // black @ 60% = 0.60 * 255 = ~153 = 0x99
    textFaint: Color(0x61000000), // black @ 38% = 0.38 * 255 = ~97 = 0x61
    accent: Color(0xFF0B0B0C),
    onAccent: Color(0xFFFFFFFF),
    danger: Color(0xFFFF3B30),
  );

  @override
  GlassTokens copyWith({
    Color? bg,
    Color? bgElevated,
    Color? glassFill,
    Color? glassFillStrong,
    Color? glassStroke,
    Color? glassHighlightStart,
    Color? glassHighlightEnd,
    Color? textPrimary,
    Color? textDim,
    Color? textFaint,
    Color? accent,
    Color? onAccent,
    Color? danger,
    double? blurSigmaBar,
    double? blurSigmaSheet,
  }) {
    return GlassTokens(
      bg: bg ?? this.bg,
      bgElevated: bgElevated ?? this.bgElevated,
      glassFill: glassFill ?? this.glassFill,
      glassFillStrong: glassFillStrong ?? this.glassFillStrong,
      glassStroke: glassStroke ?? this.glassStroke,
      glassHighlightStart: glassHighlightStart ?? this.glassHighlightStart,
      glassHighlightEnd: glassHighlightEnd ?? this.glassHighlightEnd,
      textPrimary: textPrimary ?? this.textPrimary,
      textDim: textDim ?? this.textDim,
      textFaint: textFaint ?? this.textFaint,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      danger: danger ?? this.danger,
      blurSigmaBar: blurSigmaBar ?? this.blurSigmaBar,
      blurSigmaSheet: blurSigmaSheet ?? this.blurSigmaSheet,
    );
  }

  @override
  GlassTokens lerp(ThemeExtension<GlassTokens>? other, double t) {
    if (other is! GlassTokens) return this;
    return GlassTokens(
      bg: Color.lerp(bg, other.bg, t) ?? bg,
      bgElevated: Color.lerp(bgElevated, other.bgElevated, t) ?? bgElevated,
      glassFill: Color.lerp(glassFill, other.glassFill, t) ?? glassFill,
      glassFillStrong:
          Color.lerp(glassFillStrong, other.glassFillStrong, t) ??
          glassFillStrong,
      glassStroke: Color.lerp(glassStroke, other.glassStroke, t) ?? glassStroke,
      glassHighlightStart:
          Color.lerp(glassHighlightStart, other.glassHighlightStart, t) ??
          glassHighlightStart,
      glassHighlightEnd:
          Color.lerp(glassHighlightEnd, other.glassHighlightEnd, t) ??
          glassHighlightEnd,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textDim: Color.lerp(textDim, other.textDim, t) ?? textDim,
      textFaint: Color.lerp(textFaint, other.textFaint, t) ?? textFaint,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      onAccent: Color.lerp(onAccent, other.onAccent, t) ?? onAccent,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
      blurSigmaBar:
          lerpDouble(blurSigmaBar, other.blurSigmaBar, t) ?? blurSigmaBar,
      blurSigmaSheet:
          lerpDouble(blurSigmaSheet, other.blurSigmaSheet, t) ?? blurSigmaSheet,
    );
  }
}

extension GlassTokensTheme on ThemeData {
  GlassTokens get glass => extension<GlassTokens>() ?? GlassTokens.dark;
}
