import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/data/models/artwork.dart';
import 'package:awady_music/widgets/artwork_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class MediaCard extends StatelessWidget {
  const MediaCard({
    required this.title,
    super.key,
    this.subtitle,
    this.artwork,
    this.artworkUrl,
    this.size = 150,
    this.radius = 16,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Artwork? artwork;
  final String? artworkUrl;
  final double size;
  final double radius;
  final VoidCallback? onTap;

  TextDirection _detectDirection(String text) {
    return intl.Bidi.detectRtlDirectionality(text)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ArtworkImage(
              art: artwork,
              url: artworkUrl,
              size: size,
              radius: radius,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textDirection: _detectDirection(title),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                textDirection: _detectDirection(subtitle!),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: tokens.textDim,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
