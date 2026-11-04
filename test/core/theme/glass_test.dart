import 'package:alchemist/alchemist.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/core/theme/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeReduceTransparencyNotifier extends ReduceTransparencyNotifier {
  @override
  bool build() => true;
}

Future<void> main() async {
  testWidgets('GlassSurface renders child content', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(
            body: GlassSurface(child: Text('Glass content')),
          ),
        ),
      ),
    );

    expect(find.text('Glass content'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets(
    'GlassSurface uses solid background when reduceTransparency is true',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reduceTransparencyProvider.overrideWith(
              FakeReduceTransparencyNotifier.new,
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: const Scaffold(
              body: GlassSurface(child: Text('Solid content')),
            ),
          ),
        ),
      );

      expect(find.text('Solid content'), findsOneWidget);
      // When transparency is reduced, BackdropFilter is skipped
      expect(find.byType(BackdropFilter), findsNothing);
    },
  );

  await goldenTest(
    'GlassSurface golden dark and light',
    fileName: 'glass_surface',
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'dark',
          child: Theme(
            data: AppTheme.dark(),
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16),
              child: const ProviderScope(
                child: GlassSurface(
                  child: SizedBox(
                    width: 200,
                    height: 100,
                    child: Center(
                      child: Text(
                        'Dark Glass',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'light',
          child: Theme(
            data: AppTheme.light(),
            child: Container(
              color: const Color(0xFFF2F2F7),
              padding: const EdgeInsets.all(16),
              child: const ProviderScope(
                child: GlassSurface(
                  child: SizedBox(
                    width: 200,
                    height: 100,
                    child: Center(
                      child: Text(
                        'Light Glass',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
