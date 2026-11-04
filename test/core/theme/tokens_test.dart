import 'package:awady_music/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GlassTokens dark and light instances are non-null and configured', () {
    const dark = GlassTokens.dark;
    const light = GlassTokens.light;

    expect(dark.bg, const Color(0xFF000000));
    expect(dark.bgElevated, const Color(0xFF0E0E10));
    expect(dark.textPrimary, const Color(0xFFFFFFFF));
    expect(dark.danger, const Color(0xFFFF453A));
    expect(dark.blurSigmaBar, 24.0);
    expect(dark.blurSigmaSheet, 18.0);

    expect(light.bg, const Color(0xFFF2F2F7));
    expect(light.bgElevated, const Color(0xFFFFFFFF));
    expect(light.textPrimary, const Color(0xFF0B0B0C));
    expect(light.danger, const Color(0xFFFF3B30));
    expect(light.blurSigmaBar, 24.0);
    expect(light.blurSigmaSheet, 18.0);
  });

  test('GlassTokens lerp linearly interpolates between dark and light', () {
    const dark = GlassTokens.dark;
    const light = GlassTokens.light;

    final mid = dark.lerp(light, 0.5);

    expect(mid, isA<GlassTokens>());
    expect(mid.bg, Color.lerp(dark.bg, light.bg, 0.5));
    expect(
      mid.textPrimary,
      Color.lerp(dark.textPrimary, light.textPrimary, 0.5),
    );
    expect(mid.danger, Color.lerp(dark.danger, light.danger, 0.5));
  });

  test('GlassTokens copyWith updates specified fields', () {
    const dark = GlassTokens.dark;
    final updated = dark.copyWith(danger: Colors.amber);

    expect(updated.danger, Colors.amber);
    expect(updated.bg, dark.bg);
  });
}
