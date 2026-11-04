import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/models/artwork.dart';
import 'package:awady_music/widgets/artwork_image.dart';
import 'package:awady_music/widgets/glass_toast.dart';
import 'package:awady_music/widgets/live_bars.dart';
import 'package:awady_music/widgets/skeletons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@immutable
class FailingImageProvider extends ImageProvider<FailingImageProvider> {
  const FailingImageProvider(this.url);
  final String url;

  @override
  Future<FailingImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<FailingImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    FailingImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return OneFrameImageStreamCompleter(
      Future<ImageInfo>.error(Exception('Failed to load image from $url')),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FailingImageProvider && other.url == url;

  @override
  int get hashCode => url.hashCode;
}

void main() {
  test('ArtworkImage builds candidate list in priority order', () {
    const art = Artwork(
      s480: 'https://i.ytimg.com/vi/123/hqdefault.jpg?sqp=test',
      s1000: 'https://i.ytimg.com/vi/123/maxresdefault.jpg',
      s150: 'https://i.ytimg.com/vi/123/default.jpg',
      fallback: 'https://i.ytimg.com/vi/123/fallback.jpg',
    );

    final candidates = ArtworkImage.buildCandidates(art);
    expect(candidates, isNotEmpty);
    // Verified signed params are stripped
    expect(candidates.first, 'https://i.ytimg.com/vi/123/hqdefault.jpg');
    expect(
      candidates,
      contains('https://i.ytimg.com/vi/123/maxresdefault.jpg'),
    );
    expect(candidates, contains('https://i.ytimg.com/vi/123/default.jpg'));
    expect(candidates, contains('https://i.ytimg.com/vi/123/fallback.jpg'));
  });

  testWidgets(
    'ArtworkImage advances to next URL on error and settles on placeholder',
    (tester) async {
      const art = Artwork(
        s480: 'https://url1.com/img.jpg',
        s1000: 'https://url2.com/img.jpg',
        fallback: 'https://url3.com/img.jpg',
      );

      final triedUrls = <String>[];

      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().contains('Failed to load image')) {
          return;
        }
        originalOnError?.call(details);
      };

      try {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.dark(),
              home: Scaffold(
                body: ArtworkImage(
                  art: art,
                  imageProviderFactory: (url) {
                    triedUrls.add(url);
                    return FailingImageProvider(url);
                  },
                ),
              ),
            ),
          ),
        );

        // Pump frames for microtasks and error callbacks to advance
        for (var i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(triedUrls.length, greaterThanOrEqualTo(2));
        expect(find.byIcon(LucideIcons.music), findsOneWidget);
      } finally {
        FlutterError.onError = originalOnError;
      }
    },
  );

  testWidgets('Skeletons render correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                CardsRowSkeleton(count: 2),
                RowsSkeleton(count: 2),
                HeroSkeleton(),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CardsRowSkeleton), findsOneWidget);
    expect(find.byType(RowsSkeleton), findsOneWidget);
    expect(find.byType(HeroSkeleton), findsOneWidget);
  });

  testWidgets('GlassToast displays message and auto-dismisses', (tester) async {
    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(body: GlassToast()),
        ),
      ),
    );

    expect(find.text('Toast test'), findsNothing);

    container
        .read(toastProvider.notifier)
        .show('Toast test', duration: const Duration(milliseconds: 500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Toast test'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Toast test'), findsNothing);
  });

  testWidgets('LiveBars renders in playing and paused states', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Column(
            children: [LiveBars(playing: true), LiveBars(playing: false)],
          ),
        ),
      ),
    );

    expect(find.byType(LiveBars), findsNWidgets(2));
  });
}
