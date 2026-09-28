import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('VibeTune home screen test', (WidgetTester tester) async {
    await tester.pumpWidget(const VibeTuneApp());

    expect(find.text('What’s your vibe?'), findsOneWidget);
    expect(find.text('Choose your mood'), findsOneWidget);
    expect(find.text('Happy'), findsOneWidget);
    expect(find.text('Chill'), findsOneWidget);
    expect(find.text('Energetic'), findsOneWidget);
    expect(find.text('Romantic'), findsOneWidget);
  });
}
