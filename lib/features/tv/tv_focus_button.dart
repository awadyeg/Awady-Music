import 'package:awady_music/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// D-pad navigable focusable button with high-contrast glowing scale focus
/// effect for Android TV / 1080p / 4K remote controls.
class TvFocusButton extends StatefulWidget {
  const TvFocusButton({
    required this.child,
    required this.onPressed,
    this.autofocus = false,
    this.focusNode,
    this.tooltip,
    this.borderRadius = 16.0,
    this.focusScale = 1.06,
    super.key,
  });

  final Widget child;
  final VoidCallback onPressed;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? tooltip;
  final double borderRadius;
  final double focusScale;

  @override
  State<TvFocusButton> createState() => _TvFocusButtonState();
}

class _TvFocusButtonState extends State<TvFocusButton> {
  bool _isFocused = false;

  void _handlePress() {
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;

    return Focus(
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      onFocusChange: (focused) {
        if (mounted) setState(() => _isFocused = focused);
      },
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.select ||
              key == LogicalKeyboardKey.enter ||
              key == LogicalKeyboardKey.numpadEnter ||
              key == LogicalKeyboardKey.space ||
              key == LogicalKeyboardKey.gameButtonA) {
            _handlePress();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _handlePress();
              return null;
            },
          ),
          ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
            onInvoke: (_) {
              _handlePress();
              return null;
            },
          ),
        },
        child: GestureDetector(
          onTap: _handlePress,
          behavior: HitTestBehavior.opaque,
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
      ),
    );
  }
}
