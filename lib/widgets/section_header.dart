import 'package:awady_music/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    super.key,
    this.trailing,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 12),
  });

  final String title;
  final Widget? trailing;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsDirectional padding;

  TextDirection _detectDirection(String text) {
    return intl.Bidi.detectRtlDirectionality(text)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.glass;

    var actionWidget = trailing;
    if (actionWidget == null && actionLabel != null) {
      actionWidget = TextButton(
        onPressed: onAction,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          actionLabel!,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: tokens.textDim,
          ),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              textDirection: _detectDirection(title),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actionWidget != null) ...[const SizedBox(width: 8), actionWidget],
        ],
      ),
    );
  }
}
