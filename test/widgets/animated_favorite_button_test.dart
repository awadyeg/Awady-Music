import 'package:awady_music/widgets/animated_favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimatedFavoriteButton widget tests', () {
    testWidgets('renders border icon when unliked and filled red when liked', (
      tester,
    ) async {
      var liked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AnimatedFavoriteButton(
                  isLiked: liked,
                  onTap: () {
                    setState(() {
                      liked = !liked;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Initially unliked
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsNothing);

      // Tap to like
      await tester.tap(find.byType(AnimatedFavoriteButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      final iconWidget = tester.widget<Icon>(
        find.byIcon(Icons.favorite_rounded),
      );
      expect(iconWidget.color, equals(const Color(0xFFFF1744)));

      await tester.pumpAndSettle();
    });
  });
}
