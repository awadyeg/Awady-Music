import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:flutter/material.dart';

class GlassSheet extends StatelessWidget {
  const GlassSheet({
    required this.child,
    super.key,
    this.maxHeightFraction = 0.88,
    this.showGrabber = true,
  });

  final Widget child;
  final double maxHeightFraction;
  final bool showGrabber;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height * maxHeightFraction;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(GlassTokens.radiusSheet),
        ),
        child: GlassSurface(
          radius: 0,
          strong: true,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showGrabber) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: tokens.textFaint,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Flexible(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<T?> showGlassBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
  bool isScrollControlled = true,
  bool useRootNavigator = true,
  bool isDismissible = true,
  bool enableDrag = true,
  double maxHeightFraction = 0.88,
  bool showGrabber = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => GlassSheet(
      maxHeightFraction: maxHeightFraction,
      showGrabber: showGrabber,
      child: builder(context),
    ),
  );
}
