import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Floating capsule tab bar with frosted glass styling and instant responsive
/// taps.
class GlassTabBar extends StatefulWidget {
  const GlassTabBar({
    required this.currentIndex,
    required this.onTap,
    this.onDoubleTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final ValueChanged<int>? onDoubleTap;

  @override
  State<GlassTabBar> createState() => _GlassTabBarState();
}

class _GlassTabBarState extends State<GlassTabBar> {
  int? _lastTappedIndex;
  DateTime? _lastTapTime;

  void _handleTap(int index) {
    final now = DateTime.now();
    final isDouble =
        _lastTappedIndex == index &&
        _lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 350);
    _lastTappedIndex = index;
    _lastTapTime = now;

    widget.onTap(index);
    if (isDouble && widget.onDoubleTap != null) {
      widget.onDoubleTap!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.glass;
    final l10n = context.l10n;
    final motion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : GlassTokens.motionDefault;
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    final items = [
      (icon: LucideIcons.house, label: l10n.navHome),
      (icon: LucideIcons.search, label: l10n.navSearch),
      (icon: LucideIcons.library, label: l10n.navLibrary),
      (icon: LucideIcons.chartColumn, label: l10n.navStats),
    ];

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        16,
        0,
        16,
        bottomPadding > 0 ? bottomPadding : 16,
      ),
      child: SizedBox(
        height: 64,
        child: GlassSurface(
          radius: GlassTokens.radiusCapsule,
          strong: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  Expanded(
                    child: _TabItem(
                      icon: items[i].icon,
                      label: items[i].label,
                      isSelected: widget.currentIndex == i,
                      onTap: () => _handleTap(i),
                      tokens: tokens,
                      motion: motion,
                      isDark: theme.brightness == Brightness.dark,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.tokens,
    required this.motion,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final GlassTokens tokens;
  final Duration motion;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GlassTokens.radiusCapsule),
      child: AnimatedContainer(
        duration: motion,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? Colors.white.withValues(alpha: 0.16)
                    : Colors.black.withValues(alpha: 0.08))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(GlassTokens.radiusCapsule),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? tokens.accent : tokens.textDim,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? tokens.accent : tokens.textDim,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
