import 'dart:math' as math;

import 'package:awady_music/core/theme/tokens.dart';
import 'package:flutter/material.dart';

class LiveBars extends StatefulWidget {
  const LiveBars({
    required this.playing,
    super.key,
    this.color,
    this.height = 18,
    this.barCount = 4,
    this.barWidth = 3,
    this.gap = 2,
  });

  final bool playing;
  final Color? color;
  final double height;
  final int barCount;
  final double barWidth;
  final double gap;

  @override
  State<LiveBars> createState() => _LiveBarsState();
}

class _LiveBarsState extends State<LiveBars>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    if (widget.playing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(LiveBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playing != oldWidget.playing) {
      if (widget.playing) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;
    final barColor = widget.color ?? tokens.accent;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(widget.barCount, (i) {
            final t = _controller.value;
            // Phase offsets and speed multiplier per bar
            final phase = (i * 0.28) + (math.sin(i * 1.5) * 0.1);
            final val = math.sin((t + phase) * 2 * math.pi);
            // Height fraction between 0.2 and 1.0 when playing, else 0.2
            final fraction = widget.playing
                ? 0.2 + (0.8 * ((val + 1) / 2))
                : 0.2;
            final barH = (fraction * widget.height).clamp(3.0, widget.height);

            return Container(
              margin: EdgeInsets.only(
                right: i < widget.barCount - 1 ? widget.gap : 0,
              ),
              width: widget.barWidth,
              height: barH,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(1.5),
              ),
            );
          }),
        );
      },
    );
  }
}
