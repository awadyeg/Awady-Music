import 'package:awady_music/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders AwadyMusicApp', (tester) async {
    await tester.pumpWidget(const AwadyMusicApp());
    expect(find.byType(AwadyMusicApp), findsOneWidget);
  });
}
