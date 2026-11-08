import 'dart:async';
import 'dart:io';

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

  static bool isLocalPath(String u) {
    if (u.startsWith('file://') ||
        u.startsWith('/') ||
        RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(u)) {
      return true;
    }
    return false;
  }

  static String stripSigned(String u) {
    if (isLocalPath(u)) return u;
    return u.replaceAllMapped(
      RegExp(r'(ytimg\.com/[^?]+)\?.*$'),
      (match) => match.group(1) ?? u,
    );
  }

  static String upscaleUrl(String url, {int size = 1080}) {
    if (url.isEmpty || isLocalPath(url)) return url;
    if (url.contains('googleusercontent.com') ||
        url.contains('yt3.ggpht.com') ||
        url.contains('ggpht.com')) {
      return url.replaceAll(
        RegExp(r'=(?:w\d+-h\d+|s\d+)[^?&]*'),
        '=w$size-h$size-l90-rj',
      );
    }
    return url;
  }

  static List<String> buildCandidates(Artwork? art, [String? directUrl]) {
    if (directUrl != null && directUrl.isNotEmpty) {
      if (isLocalPath(directUrl)) {
        return [directUrl];
      }
      final upscaled = upscaleUrl(directUrl);
      return [stripSigned(upscaled)];
    }
    if (art == null) return const [];

    final raw = <String>[];
    for (final s in [art.s1000, art.s480, art.s150, art.fallback]) {
      if (s != null && s.isNotEmpty && isLocalPath(s)) {
        if (!raw.contains(s)) raw.add(s);
      }
    }

    final primary = art.s480 ?? art.s1000 ?? art.s150 ?? art.fallback;
    if (primary != null && primary.isNotEmpty) {
      final cleanPrimary = isLocalPath(primary)
          ? primary
          : stripSigned(primary);
      if (!raw.contains(cleanPrimary)) raw.add(cleanPrimary);

      var path = '';
      try {
        path = Uri.parse(primary).path;
      } on Object {
        path = '';
      }

      if (path.isNotEmpty) {
        for (final m in art.mirrors) {
          raw.add('$m$path');
        }
      }
    }

    for (final s in [art.s1000, art.s480, art.s150]) {
      if (s != null && s.isNotEmpty) {
        final clean = isLocalPath(s) ? s : stripSigned(s);
        if (!raw.contains(clean)) raw.add(clean);
      }
    }

    if (art.fallback != null && art.fallback!.isNotEmpty) {
      final cleanFb = isLocalPath(art.fallback!)
          ? art.fallback!
          : stripSigned(art.fallback!);
      if (!raw.contains(cleanFb)) raw.add(cleanFb);
    }

    final localCandidates = <String>[];
    final remoteCandidates = <String>[];

    for (final c in raw) {
      if (isLocalPath(c)) {
        if (!localCandidates.contains(c)) localCandidates.add(c);
      } else {
        final up = upscaleUrl(c);
        if (up != c && !remoteCandidates.contains(up)) {
          remoteCandidates.add(up);
        }
        if (!remoteCandidates.contains(c)) remoteCandidates.add(c);
      }
    }

    return [...localCandidates, ...remoteCandidates];
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

    if (ArtworkImage.isLocalPath(currentUrl)) {
      final localPath = currentUrl.startsWith('file://')
          ? currentUrl.substring(7)
          : currentUrl;
      final file = File(localPath);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: borderRadius,
          child: Image.file(
            file,
            key: ValueKey(currentUrl),
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
      scheduleMicrotask(_onImageError);
      return _buildPlaceholder(borderRadius);
    }

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

    final safeSize = widget.size.isFinite ? widget.size : 600.0;
    final cachePixelSize =
        (safeSize * (MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0))
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
        child: ColoredBox(
          color: tokens.surfaceMuted,
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
