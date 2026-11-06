import 'package:awady_music/core/theme/tokens.dart';
import 'package:flutter/material.dart';

/// D-pad navigable focusable button with high-contrast glowing scale focus
/// effect for Android TV / 1080p / 4K remote controls.
class TvFocusButton extends StatefulWidget {
  const TvFocusButton({
    required this.child,
    required this.onPressed,
    this.autofocus = false,
    this.tooltip,
    this.borderRadius = 16.0,
    this.focusScale = 1.06,
    super.key,
  });

  final Widget child;
  final VoidCallback onPressed;
  final bool autofocus;
  final String? tooltip;
  final double borderRadius;
  final double focusScale;

  @override
  State<TvFocusButton> createState() => _TvFocusButtonState();
}

class _TvFocusButtonState extends State<TvFocusButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;

    return FocusableActionDetector(
      autofocus: widget.autofocus,
      onFocusChange: (focused) {
        if (mounted) setState(() => _isFocused = focused);
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => widget.onPressed(),
        ),
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _isFocused ? widget.focusScale : 1.0,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: _isFocused
                  ? Border.all(color: tokens.accent, width: 2.5)
                  : null,
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: tokens.accent.withValues(alpha: 0.4),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: widget.tooltip != null
                ? Tooltip(message: widget.tooltip ?? '', child: widget.child)
                : widget.child,
          ),
        ),
      ),
    );
  }
}
