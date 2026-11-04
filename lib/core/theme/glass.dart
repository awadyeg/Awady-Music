import 'dart:ui';

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

class GlassSurface extends ConsumerWidget {
  const GlassSurface({
    required this.child,
    super.key,
    this.radius = GlassTokens.radiusCard,
    this.strong = false,
    this.padding,
    this.margin,
  });

  final Widget child;
  final double radius;
  final bool strong;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).glass;
    final reduceTransparency = ref.watch(reduceTransparencyProvider);
    final highContrast = MediaQuery.maybeHighContrastOf(context) ?? false;
    final shouldReduce = reduceTransparency || highContrast;
    final borderRadius = BorderRadius.circular(radius);

    var content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (shouldReduce) {
      Widget box = DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.bgElevated,
          borderRadius: borderRadius,
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

    Widget glass = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: borderRadius,
            border: Border.all(color: tokens.glassStroke),
          ),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        tokens.glassHighlightStart,
                        tokens.glassHighlightEnd,
                      ],
                      stops: const [0, 0.4],
                    ),
                  ),
                ),
              ),
              content,
            ],
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
