import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class GlassTabBar extends StatelessWidget {
  const GlassTabBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.glass;
    final l10n = context.l10n;
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
                      isSelected: currentIndex == i,
                      onTap: () => onTap(i),
                      tokens: tokens,
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
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final GlassTokens tokens;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GlassTokens.radiusCapsule),
      child: AnimatedContainer(
        duration: GlassTokens.motionDefault,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected
              ? tokens.accent.withValues(alpha: 0.14)
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
