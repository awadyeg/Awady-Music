import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class LargeTitleScaffold extends StatelessWidget {
  const LargeTitleScaffold({
    required this.title,
    super.key,
    this.leading,
    this.actions,
    this.slivers,
    this.body,
    this.onRefresh,
    this.bottom,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.expandedHeight = 110.0,
  }) : assert(
         slivers != null || body != null,
         'Either slivers or body must be provided',
       );

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final List<Widget>? slivers;
  final Widget? body;
  final Future<void> Function()? onRefresh;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final double expandedHeight;

  TextDirection _detectDirection(String text) {
    return intl.Bidi.detectRtlDirectionality(text)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;
    final effectiveExpandedHeight = expandedHeight + bottomHeight;

    Widget scrollView = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: effectiveExpandedHeight,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          leading: leading,
          actions: actions,
          bottom: bottom,
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              final topPadding = MediaQuery.paddingOf(context).top;
              final minHeight = kToolbarHeight + topPadding + bottomHeight;
              final maxHeight = effectiveExpandedHeight + topPadding;
              final currentHeight = constraints.maxHeight;

              final scrollRatio =
                  ((maxHeight - currentHeight) /
                          (maxHeight - minHeight).clamp(1.0, double.infinity))
                      .clamp(0.0, 1.0);

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Glass background that fades in as user scrolls
                  Opacity(
                    opacity: scrollRatio,
                    child: const GlassSurface(
                      radius: 0,
                      strong: true,
                      child: SizedBox.expand(),
                    ),
                  ),
                  // Compact title (centered or aligned) fading in on collapse
                  Positioned(
                    top: topPadding,
                    left: leading != null ? 56 : 16,
                    right: (actions != null && actions!.isNotEmpty) ? 56 : 16,
                    height: kToolbarHeight,
                    child: Opacity(
                      opacity: (scrollRatio - 0.6).clamp(0.0, 0.4) / 0.4,
                      child: Center(
                        child: Text(
                          title,
                          textDirection: _detectDirection(title),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: tokens.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  // Large title at the bottom of flexible space
                  PositionedDirectional(
                    start: 16,
                    end: 16,
                    bottom: 12 + bottomHeight,
                    child: Opacity(
                      opacity: (1.0 - scrollRatio * 2.0).clamp(0.0, 1.0),
                      child: Text(
                        title,
                        textDirection: _detectDirection(title),
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: tokens.textPrimary,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        ...?slivers,
        if (body != null) SliverToBoxAdapter(child: body),
      ],
    );

    if (onRefresh != null) {
      scrollView = RefreshIndicator(
        onRefresh: onRefresh!,
        color: tokens.accent,
        backgroundColor: tokens.bgElevated,
        child: scrollView,
      );
    }

    return Scaffold(
      backgroundColor: tokens.bg,
      body: scrollView,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
