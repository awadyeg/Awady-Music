import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/app_theme.dart';
import 'package:awady_music/data/repositories/import_queue.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/widgets/import_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLibraryRepository extends Fake implements LibraryRepository;

class _FakeImportQueue extends Fake implements ImportQueue;

void main() {
  Widget buildTestWidget({String? initialUrl}) {
    return ProviderScope(
      overrides: [
        libraryRepositoryProvider.overrideWithValue(_FakeLibraryRepository()),
        importQueueProvider.overrideWithValue(_FakeImportQueue()),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        home: Scaffold(body: ImportSheet(initialUrl: initialUrl)),
      ),
    );
  }

  group('ImportSheet widget tests', () {
    testWidgets('renders all controls: field, buttons, divider, hints', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('import_url_field')), findsOneWidget);
      expect(find.byKey(const Key('import_submit_button')), findsOneWidget);
      expect(find.byKey(const Key('import_file_button')), findsOneWidget);
      expect(
        find.byKey(const Key('import_destination_selector')),
        findsOneWidget,
      );
      expect(find.text('OR'), findsOneWidget);
    });

    testWidgets('shows inline error when submitting empty url', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('import_submit_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('import_error_text')), findsOneWidget);
    });

    testWidgets('pre-fills initialUrl if provided', (tester) async {
      const sampleUrl = 'https://open.spotify.com/playlist/test123';
      await tester.pumpWidget(buildTestWidget(initialUrl: sampleUrl));
      await tester.pump();

      expect(find.text(sampleUrl), findsOneWidget);
    });
  });
}
