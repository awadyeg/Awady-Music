import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A delight-driven favorite button featuring a solid vivid red heart,
/// an elastic scale bounce, and a 650ms fantasy burst animation on like.
class AnimatedFavoriteButton extends StatefulWidget {
  const AnimatedFavoriteButton({
    required this.isLiked,
    required this.onTap,
    super.key,
    this.size = 26.0,
    this.tooltip,
    this.unlikedColor,
    this.onLongPress,
  });

  final bool isLiked;
  final VoidCallback onTap;
  final double size;
  final String? tooltip;
  final Color? unlikedColor;
  final VoidCallback? onLongPress;

  static const Color likedColor = Color(0xFFFF1744);

  @override
  State<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 1.45,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.45,
          end: 0.9,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.9,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.15,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 20,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(AnimatedFavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isLiked && widget.isLiked) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isLiked) {
      _controller.forward(from: 0);
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveUnlikedColor =
        widget.unlikedColor ?? Theme.of(context).iconTheme.color;

    return Semantics(
      button: true,
      tooltip: widget.tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        onLongPress: widget.onLongPress != null
            ? () {
                unawaited(HapticFeedback.mediumImpact());
                widget.onLongPress!();
              }
            : null,
        child: SizedBox(
          width: widget.size + 20,
          height: widget.size + 20,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  if (!_controller.isAnimating) return const SizedBox.shrink();
                  return CustomPaint(
                    size: Size(widget.size + 20, widget.size + 20),
                    painter: _FantasyBurstPainter(progress: _controller.value),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  final scale = _controller.isAnimating
                      ? _scaleAnimation.value
                      : 1.0;
                  return Transform.scale(scale: scale, child: child);
                },
                child: widget.isLiked
                    ? Icon(
                        Icons.favorite_rounded,
                        size: widget.size,
                        color: AnimatedFavoriteButton.likedColor,
                        shadows: const [
                          Shadow(color: Color(0x66FF1744), blurRadius: 10),
                        ],
                      )
                    : Icon(
                        Icons.favorite_border_rounded,
                        size: widget.size,
                        color: effectiveUnlikedColor,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FantasyBurstPainter extends CustomPainter {
  const _FantasyBurstPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringRadius = progress * 24.0;
    final ringOpacity = (1.0 - progress).clamp(0.0, 1.0);

    // Glowing expanding shockwave ring
    final ringPaint = Paint()
      ..color = const Color(0xFFFF1744).withValues(alpha: ringOpacity * 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (1.0 - progress) * 2.5;
    canvas.drawCircle(center, ringRadius, ringPaint);

    // 8 radiating mini particles / sparkles
    const particleCount = 8;
    final particleDistance = progress * 28.0;
    final particleRadius = ((1.0 - progress) * 3.2).clamp(0.0, 3.2);

    final sparklePaint = Paint()
      ..color = const Color(0xFFFF5252).withValues(alpha: ringOpacity)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < particleCount; i++) {
      final angle = (i * 2 * math.pi / particleCount) + (progress * 0.35);
      final offset = Offset(
        center.dx + math.cos(angle) * particleDistance,
        center.dy + math.sin(angle) * particleDistance,
      );

      if (i.isEven) {
        // Star sparkle
        _drawSparkle(canvas, offset, particleRadius, sparklePaint);
      } else {
        // Glowing dot
        canvas.drawCircle(offset, particleRadius, sparklePaint);
      }
    }
  }

  void _drawSparkle(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r * 1.5)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r * 1.5, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r * 1.5)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r * 1.5, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r * 1.5)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_FantasyBurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
