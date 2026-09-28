import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'home recommendation can be favorited and removed from Favorites',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const VibeTuneApp());
      await tester.pumpAndSettle();

      expect(find.text('Recommended for You'), findsOneWidget);

      final happyChip = find.text('😊 Happy');
      await tester.ensureVisible(happyChip);
      await tester.tap(happyChip);
      await tester.pumpAndSettle();
      expect(find.text('On Top of the World'), findsOneWidget);

      final favoriteButton = find.byKey(
        const ValueKey('favorite-recommendation_happy_01'),
      );
      await tester.ensureVisible(favoriteButton);
      await tester.tap(favoriteButton);
      await tester.pumpAndSettle();
      expect(find.text('Now Playing'), findsNothing);

      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();
      expect(find.text('On Top of the World'), findsOneWidget);

      await tester.tap(favoriteButton);
      await tester.pumpAndSettle();
      expect(find.text('No favorite songs yet'), findsOneWidget);
    },
  );
}
