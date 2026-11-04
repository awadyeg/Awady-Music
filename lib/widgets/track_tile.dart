import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/core/util/format.dart';
import 'package:awady_music/data/models/artwork.dart';
import 'package:awady_music/widgets/artwork_image.dart';
import 'package:awady_music/widgets/live_bars.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TrackTile extends StatelessWidget {
  const TrackTile({
    required this.title,
    required this.artist,
    super.key,
    this.artwork,
    this.artworkUrl,
    this.duration,
    this.isPlaying = false,
    this.isPending = false,
    this.isDownloaded = false,
    this.onTap,
    this.onMoreTap,
    this.leading,
    this.showTrailing = true,
  });

  final String title;
  final String artist;
  final Artwork? artwork;
  final String? artworkUrl;
  final int? duration;
  final bool isPlaying;
  final bool isPending;
  final bool isDownloaded;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final Widget? leading;
  final bool showTrailing;

  TextDirection _detectDirection(String text) {
    return intl.Bidi.detectRtlDirectionality(text)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.glass;

    return InkWell(
      onTap: isPending ? null : onTap,
      borderRadius: BorderRadius.circular(GlassTokens.radiusSmall),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            // Artwork with playing or pending overlay
            Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: isPending ? 0.45 : 1.0,
                  child: ArtworkImage(art: artwork, url: artworkUrl),
                ),
                if (isPlaying)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(
                        GlassTokens.radiusSmall,
                      ),
                    ),
                    child: Center(
                      child: LiveBars(
                        playing: true,
                        color: tokens.accent,
                        height: 16,
                      ),
                    ),
                  ),
                if (isPending)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            // Title and Artist / Duration
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textDirection: _detectDirection(title),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isPlaying ? FontWeight.w600 : FontWeight.w500,
                      color: isPlaying ? tokens.accent : tokens.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (isDownloaded) ...[
                        Icon(
                          LucideIcons.arrowDownToLine,
                          size: 13,
                          color: tokens.textDim,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          duration != null && duration! > 0
                              ? '$artist · '
                                    '${FormatUtils.formatDuration(duration!)}'
                              : artist,
                          textDirection: _detectDirection(artist),
                          style: TextStyle(fontSize: 13, color: tokens.textDim),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (showTrailing) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  LucideIcons.ellipsis,
                  size: 20,
                  color: tokens.textDim,
                ),
                onPressed: onMoreTap,
                tooltip: 'More options',
                splashRadius: 22,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
