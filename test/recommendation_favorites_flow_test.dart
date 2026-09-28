import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/controllers/favorites_controller.dart';
import 'package:flutter_application_1/screens/favorites_screen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/services/audius_search_service.dart';
import 'package:flutter_application_1/services/recommendation_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, Object?> _track(String id, String title) => {
  'id': id,
  'track_id': id,
  'title': title,
  'is_available': true,
  'is_streamable': true,
  'is_stream_gated': false,
  'duration': 200,
  'genre': 'Pop',
  'mood': 'Happy',
  'user': {'name': 'Test Audius Artist'},
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Audius recommendation appears on Home and synchronizes with Favorites',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await FavoritesController.instance.reloadFavorites();
      final recommendationClient = MockClient((request) async {
        final query = request.url.queryParameters['query'] ?? '';
        return http.Response(
          jsonEncode({
            'data': [_track('happy-1', 'Live Audius Happy Track ($query)')],
          }),
          200,
        );
      });
      final searchClient = MockClient((_) async {
        return http.Response(jsonEncode({'data': []}), 200);
      });
      final audiobookSearch = AudiusSearchService(client: searchClient);
      final recommendations = RecommendationService(
        audius: AudiusSearchService(client: recommendationClient),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: HomeScreen(
                      audiusSearchService: audiobookSearch,
                      recommendationService: recommendations,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const FavoritesScreen(),
                      ),
                    ),
                    child: const Text('Open saved songs'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final happyChip = find.text('😊 Happy');
      await tester.ensureVisible(happyChip);
      await tester.tap(happyChip);
      await tester.pumpAndSettle();
      expect(find.text('Live Audius Happy Track (happy)'), findsOneWidget);

      final favoriteButton = find.byKey(
        const ValueKey('favorite-audius:happy-1'),
      );
      await tester.ensureVisible(favoriteButton);
      await tester.tap(favoriteButton);
      await tester.pumpAndSettle();
      expect(FavoritesController.instance.favoriteSongs, hasLength(1));
      expect(find.text('Now Playing'), findsNothing);
      await FavoritesController.instance.reloadFavorites();
      expect(
        FavoritesController.instance.favoriteSongs.single.audiusTrackId,
        'happy-1',
      );

      await tester.tap(find.text('Open saved songs'));
      await tester.pumpAndSettle();
      expect(find.text('Live Audius Happy Track (happy)'), findsOneWidget);

      await tester.tap(favoriteButton);
      await tester.pumpAndSettle();
      expect(find.text('No favorite songs yet'), findsOneWidget);
      expect(FavoritesController.instance.favoriteSongs, isEmpty);

      recommendationClient.close();
      searchClient.close();
    },
  );

  testWidgets('Home search displays real tracks returned by Audius', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await FavoritesController.instance.reloadFavorites();
    final emptyRecommendationClient = MockClient(
      (_) async => http.Response(jsonEncode({'data': []}), 200),
    );
    final searchClient = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'data': [_track('search-1', 'Ambient track from Audius')],
        }),
        200,
      ),
    );
    final recommendationService = RecommendationService(
      audius: AudiusSearchService(client: emptyRecommendationClient),
    );
    final searchService = AudiusSearchService(client: searchClient);

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          recommendationService: recommendationService,
          audiusSearchService: searchService,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ambient');
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();

    expect(find.text('Ambient track from Audius'), findsOneWidget);
    expect(find.byKey(const ValueKey('play-audius:search-1')), findsOneWidget);

    emptyRecommendationClient.close();
    searchClient.close();
  });
}
