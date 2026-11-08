import 'dart:math' as math;
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

/// Solid content material.
///
/// Library rows, settings groups, and artwork wells use this. Liquid glass
/// stays on floating controls, bars, and sheets.
class ContentSurface extends StatelessWidget {
  const ContentSurface({
    required this.child,
    super.key,
    this.radius = GlassTokens.radiusCard,
    this.padding,
    this.margin,
    this.color,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;
    final radiusValue = BorderRadius.circular(radius);
    var content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    Widget box = DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? tokens.surfaceFill,
        borderRadius: radiusValue,
      ),
      child: content,
    );
    if (margin != null) {
      box = Padding(padding: margin!, child: box);
    }
    return box;
  }
}

/// Translucent control material.
///
/// Blurs whatever is actually behind the control, then adds a uniform
/// luminosity veil and a hairline specular rim. It does not paint a
/// top-to-bottom metallic gradient. [clear] keeps more of a photo or
/// artwork visible. Reduced transparency and high contrast fall back to
/// an opaque surface.
class GlassSurface extends ConsumerWidget {
  const GlassSurface({
    required this.child,
    super.key,
    this.radius = GlassTokens.radiusCard,
    this.strong = false,
    this.clear = false,
    this.padding,
    this.margin,
  });

  final Widget child;
  final double radius;
  final bool strong;
  final bool clear;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).glass;
    final reduceTransparency =
        ref.watch(reduceTransparencyProvider) ||
        ref.watch(settingsProvider.select((s) => s.reduceTransparency));
    final highContrast = MediaQuery.maybeHighContrastOf(context) ?? false;
    final shouldReduce = reduceTransparency || highContrast;
    final borderRadius = BorderRadius.circular(radius);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    var content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (shouldReduce) {
      Widget box = DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surfaceFill,
          borderRadius: borderRadius,
          border: highContrast
              ? Border.all(color: tokens.textPrimary.withValues(alpha: 0.45))
              : null,
        ),
        child: content,
      );
      if (margin != null) {
        box = Padding(padding: margin!, child: box);
      }
      return box;
    }

    final sigma = clear
        ? 14.0
        : (strong ? tokens.blurSigmaBar : tokens.blurSigmaSheet);
    final veil = _veilColor(isDark: isDark, strong: strong, clear: clear);
    final shadow = radius == 0
        ? const <BoxShadow>[]
        : <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.10),
              blurRadius: strong ? 24 : 16,
              offset: const Offset(0, 8),
            ),
          ];

    Widget glass = DecoratedBox(
      decoration: BoxDecoration(borderRadius: borderRadius, boxShadow: shadow),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: sigma,
            sigmaY: sigma,
            tileMode: TileMode.clamp,
          ),
          child: CustomPaint(
            painter: _VeilPainter(color: veil, radius: radius),
            foregroundPainter: _SpecularRimPainter(
              radius: radius,
              isDark: isDark,
            ),
            child: content,
          ),
        ),
      ),
    );

    if (margin != null) {
      glass = Padding(padding: margin!, child: glass);
    }
    return glass;
  }

  static Color _veilColor({
    required bool isDark,
    required bool strong,
    required bool clear,
  }) {
    if (isDark) {
      if (clear) return const Color(0x0AFFFFFF);
      return strong ? const Color(0x1FFFFFFF) : const Color(0x14FFFFFF);
    }
    // Light bars stay bright enough for dark type, but not so opaque that
    // the backdrop blur collapses into a solid white pill.
    if (clear) return const Color(0x4DFFFFFF);
    return strong ? const Color(0x99FFFFFF) : const Color(0x80FFFFFF);
  }
}

class _VeilPainter extends CustomPainter {
  const _VeilPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    canvas.drawRRect(rrect, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _VeilPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

class _SpecularRimPainter extends CustomPainter {
  const _SpecularRimPainter({required this.radius, required this.isDark});

  final double radius;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(0.5),
      Radius.circular(math.max(0, radius - 0.5)),
    );
    final top = isDark ? 0.42 : 0.50;
    final bottom = isDark ? 0.08 : 0.10;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: top),
          Colors.white.withValues(alpha: bottom),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(rrect, stroke);

    final sheenHeight = math.min(8, size.height * 0.12).toDouble();
    if (sheenHeight < 2) return;
    canvas
      ..save()
      ..clipRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final sheen = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.07 : 0.10),
          const Color(0x00FFFFFF),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, sheenHeight));
    canvas
      ..drawRect(Rect.fromLTWH(0, 0, size.width, sheenHeight), sheen)
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _SpecularRimPainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.isDark != isDark;
  }
}
