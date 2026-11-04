import 'package:awady_music/core/theme/tokens.dart';
import 'package:flutter/material.dart';

class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.radius = GlassTokens.radiusSmall,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double? height;
  final double radius;
  final BoxShape shape;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.08,
      end: 0.22,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: tokens.textPrimary.withValues(alpha: _animation.value),
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.rectangle
                ? BorderRadius.circular(widget.radius)
                : null,
          ),
        );
      },
    );
  }
}

class CardsRowSkeleton extends StatelessWidget {
  const CardsRowSkeleton({super.key, this.count = 6, this.cardWidth = 150});

  final int count;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardWidth + 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (_, _) {
          return SizedBox(
            width: cardWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                  width: cardWidth,
                  height: cardWidth,
                  radius: GlassTokens.radiusCard,
                ),
                const SizedBox(height: 10),
                ShimmerBox(width: cardWidth * 0.75, height: 14, radius: 4),
                const SizedBox(height: 6),
                ShimmerBox(width: cardWidth * 0.5, height: 12, radius: 4),
              ],
            ),
          );
        },
      ),
    );
  }
}

class RowsSkeleton extends StatelessWidget {
  const RowsSkeleton({super.key, this.count = 8});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) {
        return const Row(
          children: [
            ShimmerBox(width: 48, height: 48),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 140, height: 14, radius: 4),
                  SizedBox(height: 6),
                  ShimmerBox(width: 90, height: 12, radius: 4),
                ],
              ),
            ),
            SizedBox(width: 12),
            ShimmerBox(width: 32, height: 12, radius: 4),
          ],
        );
      },
    );
  }
}

class HeroSkeleton extends StatelessWidget {
  const HeroSkeleton({super.key, this.hasCover = true});

  final bool hasCover;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasCover) ...[
            const Center(
              child: ShimmerBox(
                width: 200,
                height: 200,
                radius: GlassTokens.radiusCard,
              ),
            ),
            const SizedBox(height: 20),
          ],
          const ShimmerBox(width: 220, height: 26, radius: 6),
          const SizedBox(height: 10),
          const ShimmerBox(width: 140, height: 14, radius: 4),
        ],
      ),
    );
  }
}
