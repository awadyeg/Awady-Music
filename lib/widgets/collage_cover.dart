import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/data/models/artwork.dart';
import 'package:awady_music/widgets/artwork_image.dart';
import 'package:flutter/material.dart';

class CollageCover extends StatelessWidget {
  const CollageCover({
    required this.artworks,
    super.key,
    this.size = 200,
    this.radius = GlassTokens.radiusCard,
  });

  final List<Artwork> artworks;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final validArtworks = artworks.take(4).toList();

    if (validArtworks.length >= 4) {
      final half = size / 2;
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: size,
          height: size,
          child: Column(
            children: [
              Row(
                children: [
                  ArtworkImage(art: validArtworks[0], size: half, radius: 0),
                  ArtworkImage(art: validArtworks[1], size: half, radius: 0),
                ],
              ),
              Row(
                children: [
                  ArtworkImage(art: validArtworks[2], size: half, radius: 0),
                  ArtworkImage(art: validArtworks[3], size: half, radius: 0),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (validArtworks.isNotEmpty) {
      return ArtworkImage(art: validArtworks.first, size: size, radius: radius);
    }

    return ArtworkImage(size: size, radius: radius);
  }
}
