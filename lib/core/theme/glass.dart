import 'dart:ui';

import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReduceTransparencyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  bool get isReduced => state;
  set isReduced(bool value) => state = value;
}

final reduceTransparencyProvider =
    NotifierProvider<ReduceTransparencyNotifier, bool>(
      ReduceTransparencyNotifier.new,
    );

/// Apple-style Liquid Glass specular rim painter.
/// Draws a delicate 0.85px gradient stroke with specular catchlight on
/// top-left and bottom-right edges, evoking visionOS / iOS 26 optical glass.
class _AppleLiquidGlassRimPainter extends CustomPainter {
  const _AppleLiquidGlassRimPainter({
    required this.borderRadius,
    required this.strokeColor,
    required this.highlightColor,
  });

  final BorderRadius borderRadius;
  final Color strokeColor;
  final Color highlightColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    const strokeWidth = 0.85;
    final rrect = borderRadius.toRRect(rect).deflate(strokeWidth / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          highlightColor,
          strokeColor,
          highlightColor.withValues(alpha: highlightColor.a * 0.5),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_AppleLiquidGlassRimPainter oldDelegate) {
    return borderRadius != oldDelegate.borderRadius ||
        strokeColor != oldDelegate.strokeColor ||
        highlightColor != oldDelegate.highlightColor;
  }
}

/// Authentic Apple Liquid Glass surface (iOS 26 / visionOS / Apple Music)
/// featuring multi-layer optical blur, diagonal refraction gradient,
/// ambient floating depth shadow, and specular hairline rim.
class GlassSurface extends ConsumerWidget {
  const GlassSurface({
    required this.child,
    super.key,
    this.radius = GlassTokens.radiusCard,
    this.borderRadius,
    this.strong = false,
    this.padding,
    this.margin,
    this.tintColor,
  });

  final Widget child;
  final double radius;
  final BorderRadius? borderRadius;
  final bool strong;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? tintColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).glass;
    final reduceTransparency =
        ref.watch(reduceTransparencyProvider) ||
        ref.watch(settingsProvider.select((s) => s.reduceTransparency));
    final highContrast = MediaQuery.maybeHighContrastOf(context) ?? false;
    final shouldReduce = reduceTransparency || highContrast;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(radius);

    var content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (shouldReduce) {
      Widget box = DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.bgElevated,
          borderRadius: effectiveBorderRadius,
          border: Border.all(color: tokens.glassStroke),
        ),
        child: content,
      );

      if (margin != null) {
        box = Padding(padding: margin!, child: box);
      }
      return box;
    }

    final sigma = strong ? tokens.blurSigmaBar : tokens.blurSigmaSheet;
    final fill = strong ? tokens.glassFillStrong : tokens.glassFill;
    final baseColor = tintColor != null
        ? Color.alphaBlend(tintColor!, fill)
        : fill;

    Widget glass = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: strong ? 0.28 : 0.16),
            blurRadius: strong ? 28 : 20,
            spreadRadius: -2,
            offset: Offset(0, strong ? 10 : 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: CustomPaint(
            foregroundPainter: _AppleLiquidGlassRimPainter(
              borderRadius: effectiveBorderRadius,
              strokeColor: tokens.glassStroke,
              highlightColor: tokens.glassHighlightStart,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: effectiveBorderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.alphaBlend(tokens.glassHighlightStart, baseColor),
                    baseColor,
                    Color.alphaBlend(tokens.glassHighlightEnd, baseColor),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: content,
            ),
          ),
        ),
      ),
    );

    if (margin != null) {
      glass = Padding(padding: margin!, child: glass);
    }

    return glass;
  }
}
