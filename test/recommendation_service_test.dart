import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/recommendation_service.dart';

void main() {
  test('local recommendation catalog contains six tracks per mood', () {
    final recommendations = RecommendationService.getAllRecommendations();

    expect(recommendations, hasLength(36));
    for (final mood in RecommendationService.moods) {
      expect(
        RecommendationService.getRecommendationsByMood(mood),
        hasLength(6),
      );
    }
  });

  test(
    'recommendation search matches title, artist, genre, mood and language',
    () {
      expect(
        RecommendationService.searchRecommendations('Ocean Eyes').single.artist,
        'Billie Eilish',
      );
      expect(
        RecommendationService.searchRecommendations('Sid Sriram'),
        isNotEmpty,
      );
      expect(
        RecommendationService.searchRecommendations('Ambient').single.title,
        'Weightless',
      );
      expect(
        RecommendationService.searchRecommendations('Romantic'),
        hasLength(6),
      );
      expect(RecommendationService.searchRecommendations('Telugu'), isNotEmpty);
    },
  );

  test('random recommendation selection is small and mood-mixed', () {
    final recommendations = RecommendationService.getRandomRecommendations(
      limit: 6,
    );

    expect(recommendations, hasLength(6));
    expect(recommendations.map((song) => song.mood).toSet(), hasLength(6));
    expect(recommendations.every((song) => song.file == null), isTrue);
  });
}
