import 'package:awady_music/widgets/artwork_image.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArtworkImage upscaling tests', () {
    test('upscaleUrl upgrades Google and YTM thumbnail URLs to 1080', () {
      const googleThumb =
          'https://lh3.googleusercontent.com/abc=w120-h120-l90-rj';
      final upscaled = ArtworkImage.upscaleUrl(googleThumb);
      expect(
        upscaled,
        'https://lh3.googleusercontent.com/abc=w1080-h1080-l90-rj',
      );

      const yt3Thumb = 'https://yt3.ggpht.com/xyz=s60-c-k-c0x00ffffff-no-rj';
      final upscaledYt3 = ArtworkImage.upscaleUrl(yt3Thumb, size: 544);
      expect(upscaledYt3, 'https://yt3.ggpht.com/xyz=w544-h544-l90-rj');
    });

    test('upscaleUrl leaves non-Google URLs intact', () {
      const normal = 'https://example.com/cover.jpg';
      expect(ArtworkImage.upscaleUrl(normal), equals(normal));
    });
  });
}
