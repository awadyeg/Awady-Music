import 'dart:async';

import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/data/models/artwork.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

typedef ImageProviderFactory = ImageProvider Function(String url);

class ArtworkImage extends StatefulWidget {
  const ArtworkImage({
    super.key,
    this.art,
    this.url,
    this.size = 48,
    this.radius = GlassTokens.radiusSmall,
    this.iconSize,
    this.fit = BoxFit.cover,
    this.imageProviderFactory,
  });

  final Artwork? art;
  final String? url;
  final double size;
  final double radius;
  final double? iconSize;
  final BoxFit fit;
  final ImageProviderFactory? imageProviderFactory;

  static String stripSigned(String u) {
    return u.replaceAllMapped(
      RegExp(r'(ytimg\.com/[^?]+)\?.*$'),
      (match) => match.group(1) ?? u,
    );
  }

  static List<String> buildCandidates(Artwork? art, [String? directUrl]) {
    if (directUrl != null && directUrl.isNotEmpty) {
      return [stripSigned(directUrl)];
    }
    if (art == null) return const [];

    final primary = art.s480 ?? art.s1000 ?? art.s150 ?? art.fallback;
    if (primary == null) return const [];

    var path = '';
    try {
      path = Uri.parse(primary).path;
    } on Object {
      path = '';
    }

    final candidates = <String>[stripSigned(primary)];

    if (path.isNotEmpty) {
      for (final m in art.mirrors) {
        candidates.add('$m$path');
      }
    }

    for (final s in [art.s1000, art.s480, art.s150]) {
      if (s != null && s.isNotEmpty) {
        final clean = stripSigned(s);
        if (!candidates.contains(clean)) candidates.add(clean);
      }
    }

    if (art.fallback != null && art.fallback!.isNotEmpty) {
      final cleanFb = stripSigned(art.fallback!);
      if (!candidates.contains(cleanFb)) candidates.add(cleanFb);
    }

    return candidates;
  }

  @override
  State<ArtworkImage> createState() => _ArtworkImageState();
}

class _ArtworkImageState extends State<ArtworkImage> {
  int _candidateIndex = 0;
  List<String> _candidates = const [];

  @override
  void initState() {
    super.initState();
    _initCandidates();
  }

  @override
  void didUpdateWidget(ArtworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.art != widget.art || oldWidget.url != widget.url) {
      _initCandidates();
    }
  }

  void _initCandidates() {
    _candidates = ArtworkImage.buildCandidates(widget.art, widget.url);
    _candidateIndex = 0;
  }

  void _onImageError() {
    if (!mounted) return;
    if (_candidateIndex < _candidates.length - 1) {
      setState(() {
        _candidateIndex++;
      });
    } else {
      setState(() {
        _candidateIndex = _candidates.length; // all failed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(widget.radius);

    if (_candidates.isEmpty || _candidateIndex >= _candidates.length) {
      return _buildPlaceholder(borderRadius);
    }

    final currentUrl = _candidates[_candidateIndex];

    if (widget.imageProviderFactory != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image(
          key: ValueKey(currentUrl),
          image: widget.imageProviderFactory!(currentUrl),
          width: widget.size,
          height: widget.size,
          fit: widget.fit,
          errorBuilder: (_, _, _) {
            scheduleMicrotask(_onImageError);
            return _buildPlaceholder(borderRadius);
          },
        ),
      );
    }

    final cachePixelSize =
        (widget.size * (MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0))
            .round()
            .clamp(64, 1024);

    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        key: ValueKey(currentUrl),
        imageUrl: currentUrl,
        width: widget.size,
        height: widget.size,
        memCacheWidth: cachePixelSize,
        memCacheHeight: cachePixelSize,
        fit: widget.fit,
        fadeInDuration: const Duration(milliseconds: 180),
        placeholder: (_, _) => _buildPlaceholder(borderRadius),
        errorWidget: (_, _, _) {
          scheduleMicrotask(_onImageError);
          return _buildPlaceholder(borderRadius);
        },
      ),
    );
  }

  Widget _buildPlaceholder(BorderRadius borderRadius) {
    final theme = Theme.of(context);
    final tokens = theme.glass;
    final iconSz = widget.iconSize ?? (widget.size * 0.42).clamp(16.0, 48.0);

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: GlassSurface(
          radius: widget.radius,
          child: Center(
            child: Icon(
              LucideIcons.music,
              size: iconSz,
              color: tokens.textFaint,
            ),
          ),
        ),
      ),
    );
  }
}
