import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/core/util/format.dart';
import 'package:flutter/material.dart';

class GlassSlider extends StatefulWidget {
  const GlassSlider({
    required this.value,
    required this.max,
    super.key,
    this.min = 0.0,
    this.onChanged,
    this.onChangeEnd,
    this.showLabels = true,
    this.elapsedLabel,
    this.remainingLabel,
    this.trackHeight = 4.0,
    this.thumbRadius = 6.0,
    this.enabled = true,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final bool showLabels;
  final String? elapsedLabel;
  final String? remainingLabel;
  final double trackHeight;
  final double thumbRadius;
  final bool enabled;

  @override
  State<GlassSlider> createState() => _GlassSliderState();
}

class _GlassSliderState extends State<GlassSlider> {
  double? _dragValue;
  bool _isDragging = false;

  double get _currentValue {
    final v = _dragValue ?? widget.value;
    return v.clamp(
      widget.min,
      widget.max > widget.min ? widget.max : widget.min,
    );
  }

  void _handleDragStart(
    Offset localPosition,
    double width,
    TextDirection textDirection,
  ) {
    if (!widget.enabled || widget.max <= widget.min || width <= 0) {
      return;
    }
    setState(() {
      _isDragging = true;
      _updateValueFromOffset(localPosition.dx, width, textDirection);
    });
    if (_dragValue != null) {
      widget.onChanged?.call(_dragValue!);
    }
  }

  void _handleDragUpdate(
    Offset localPosition,
    double width,
    TextDirection textDirection,
  ) {
    if (!widget.enabled ||
        !_isDragging ||
        widget.max <= widget.min ||
        width <= 0) {
      return;
    }
    setState(() {
      _updateValueFromOffset(localPosition.dx, width, textDirection);
    });
    if (_dragValue != null) {
      widget.onChanged?.call(_dragValue!);
    }
  }

  void _handleDragEnd() {
    if (!_isDragging) {
      return;
    }
    final finalVal = _dragValue ?? widget.value;
    setState(() {
      _isDragging = false;
      _dragValue = null;
    });
    widget.onChangeEnd?.call(finalVal);
  }

  void _updateValueFromOffset(
    double dx,
    double width,
    TextDirection textDirection,
  ) {
    var ratio = dx / width;
    if (textDirection == TextDirection.rtl) {
      ratio = 1.0 - ratio;
    }
    ratio = ratio.clamp(0.0, 1.0);
    _dragValue = widget.min + ratio * (widget.max - widget.min);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.glass;
    final textDirection = Directionality.of(context);

    final span = widget.max - widget.min;
    final ratio = span > 0
        ? ((_currentValue - widget.min) / span).clamp(0.0, 1.0)
        : 0.0;

    final elapsed =
        widget.elapsedLabel ??
        FormatUtils.formatDuration(_currentValue.toInt());
    final remainingSecs = (widget.max - _currentValue)
        .clamp(0.0, double.infinity)
        .toInt();
    final remaining =
        widget.remainingLabel ??
        '-${FormatUtils.formatDuration(remainingSecs)}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (details) =>
                  _handleDragStart(details.localPosition, width, textDirection),
              onHorizontalDragUpdate: (details) => _handleDragUpdate(
                details.localPosition,
                width,
                textDirection,
              ),
              onHorizontalDragEnd: (_) => _handleDragEnd(),
              onHorizontalDragCancel: _handleDragEnd,
              onTapDown: (details) {
                _handleDragStart(details.localPosition, width, textDirection);
                _handleDragEnd();
              },
              child: SizedBox(
                height: 32,
                child: Center(
                  child: CustomPaint(
                    size: Size(width, widget.trackHeight),
                    painter: _SliderTrackPainter(
                      ratio: ratio,
                      trackHeight: widget.trackHeight,
                      thumbRadius: _isDragging
                          ? widget.thumbRadius * 1.3
                          : widget.thumbRadius,
                      activeColor: widget.enabled
                          ? tokens.accent
                          : tokens.textFaint,
                      inactiveColor: tokens.textFaint.withValues(alpha: 0.25),
                      thumbColor: tokens.accent,
                      textDirection: textDirection,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.showLabels) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                elapsed,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: tokens.textFaint,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                remaining,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: tokens.textFaint,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SliderTrackPainter extends CustomPainter {
  const _SliderTrackPainter({
    required this.ratio,
    required this.trackHeight,
    required this.thumbRadius,
    required this.activeColor,
    required this.inactiveColor,
    required this.thumbColor,
    required this.textDirection,
  });

  final double ratio;
  final double trackHeight;
  final double thumbRadius;
  final Color activeColor;
  final Color inactiveColor;
  final Color thumbColor;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final isRtl = textDirection == TextDirection.rtl;
    final trackRadius = Radius.circular(trackHeight / 2);
    final centerY = size.height / 2;

    // Inactive track (background)
    final bgPaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.fill;

    final bgRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, centerY - trackHeight / 2, size.width, trackHeight),
      trackRadius,
    );
    canvas.drawRRect(bgRRect, bgPaint);

    if (ratio <= 0.0) {
      return;
    }

    // Active track
    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;

    final activeWidth = size.width * ratio;
    final activeRect = isRtl
        ? Rect.fromLTWH(
            size.width - activeWidth,
            centerY - trackHeight / 2,
            activeWidth,
            trackHeight,
          )
        : Rect.fromLTWH(0, centerY - trackHeight / 2, activeWidth, trackHeight);

    canvas.drawRRect(
      RRect.fromRectAndRadius(activeRect, trackRadius),
      activePaint,
    );

    // Thumb
    final thumbCenterX = isRtl ? (size.width - activeWidth) : activeWidth;
    final thumbPaint = Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(thumbCenterX, centerY), thumbRadius, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant _SliderTrackPainter oldDelegate) {
    return oldDelegate.ratio != ratio ||
        oldDelegate.trackHeight != trackHeight ||
        oldDelegate.thumbRadius != thumbRadius ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.thumbColor != thumbColor ||
        oldDelegate.textDirection != textDirection;
  }
}
