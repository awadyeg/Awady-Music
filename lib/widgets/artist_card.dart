import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/data/models/artwork.dart';
import 'package:awady_music/widgets/artwork_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ArtistCard extends StatelessWidget {
  const ArtistCard({
    required this.name,
    super.key,
    this.artwork,
    this.artworkUrl,
    this.subtitle,
    this.isVerified = false,
    this.size = 140,
    this.onTap,
  });

  final String name;
  final Artwork? artwork;
  final String? artworkUrl;
  final String? subtitle;
  final bool isVerified;
  final double size;
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
      borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
      child: SizedBox(
        width: size,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: ArtworkImage(
                art: artwork,
                url: artworkUrl,
                size: size,
                radius: size / 2,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    name,
                    textDirection: _detectDirection(name),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (isVerified) ...[
                  const SizedBox(width: 4),
                  Icon(LucideIcons.badgeCheck, size: 15, color: tokens.accent),
                ],
              ],
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                subtitle!,
                textDirection: _detectDirection(subtitle!),
                style: TextStyle(fontSize: 12, color: tokens.textDim),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
