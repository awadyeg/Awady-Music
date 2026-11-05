import 'package:awady_music/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders AwadyMusicApp', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AwadyMusicApp()));
    await tester.pumpAndSettle();
    expect(find.byType(AwadyMusicApp), findsOneWidget);
  });
}
