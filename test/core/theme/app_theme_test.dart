import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppTheme.dark configures Material 3, NoSplash, and dark tokens', () {
    final theme = AppTheme.dark();

    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.dark);
    expect(theme.splashFactory, NoSplash.splashFactory);
    expect(theme.scaffoldBackgroundColor, const Color(0xFF000000));
    expect(theme.glass, GlassTokens.dark);
    expect(theme.textTheme.headlineLarge?.fontSize, 34);
    expect(theme.textTheme.displayLarge?.fontSize, 48);
  });

  test('AppTheme.light configures Material 3, NoSplash, and light tokens', () {
    final theme = AppTheme.light();

    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.light);
    expect(theme.splashFactory, NoSplash.splashFactory);
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF2F2F7));
    expect(theme.glass, GlassTokens.light);
    expect(theme.textTheme.headlineLarge?.fontSize, 34);
    expect(theme.textTheme.titleLarge?.fontSize, 22);
  });
}
