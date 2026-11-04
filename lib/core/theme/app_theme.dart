import 'package:awady_music/core/theme/tokens.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const String fontFamily = 'Inter';
  static const List<String> fontFallback = ['IBMPlexSansArabic'];

  static TextTheme _buildTextTheme(GlassTokens tokens) {
    return TextTheme(
      // Big number 48/800 (stats)
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: tokens.textPrimary,
        letterSpacing: -0.5,
      ),
      // Large title 34/700
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: tokens.textPrimary,
        letterSpacing: -0.4,
      ),
      // Title 22/700
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: tokens.textPrimary,
        letterSpacing: -0.3,
      ),
      // Headline 17/600
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: tokens.textPrimary,
      ),
      // Body 15/400
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: tokens.textPrimary,
      ),
      // Caption 12/500
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: tokens.textDim,
      ),
    );
  }

  static ThemeData dark() {
    const tokens = GlassTokens.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFallback,
      scaffoldBackgroundColor: tokens.bg,
      splashFactory: NoSplash.splashFactory,
      colorScheme: ColorScheme.dark(
        surface: tokens.bg,
        surfaceContainer: tokens.bgElevated,
        primary: tokens.accent,
        onPrimary: tokens.onAccent,
        error: tokens.danger,
        onError: tokens.onAccent,
        onSurface: tokens.textPrimary,
      ),
      textTheme: _buildTextTheme(tokens),
      extensions: const [tokens],
    );
  }

  static ThemeData light() {
    const tokens = GlassTokens.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFallback,
      scaffoldBackgroundColor: tokens.bg,
      splashFactory: NoSplash.splashFactory,
      colorScheme: ColorScheme.light(
        surface: tokens.bg,
        surfaceContainer: tokens.bgElevated,
        primary: tokens.accent,
        onPrimary: tokens.onAccent,
        error: tokens.danger,
        onError: tokens.onAccent,
        onSurface: tokens.textPrimary,
      ),
      textTheme: _buildTextTheme(tokens),
      extensions: const [tokens],
    );
  }
}
