import 'dart:math';

import '../models/song.dart';
import 'audius_search_service.dart';

class RecommendationService {
  static const List<String> moods = [
    'Happy',
    'Chill',
    'Romantic',
    'Sad',
    'Energetic',
    'Focus',
  ];

  static const Map<String, String> _searchQueries = {
    'Happy': 'happy',
    'Chill': 'chill',
    'Romantic': 'romantic',
    'Sad': 'sad',
    'Energetic': 'energetic',
    'Focus': 'focus instrumental',
  };

  final AudiusSearchService _audius;
  final Map<String, List<Song>> _cache = {};
  final Map<String, DateTime> _cacheTime = {};

  RecommendationService({AudiusSearchService? audius})
    : _audius = audius ?? AudiusSearchService();

  void dispose() => _audius.dispose();

  Future<List<Song>> getAllRecommendations() async {
    final moodResults = await Future.wait(
      moods.map((mood) => getRecommendationsByMood(mood, limit: 4)),
    );
    return _distinctTracks(moodResults.expand((tracks) => tracks))
        .take(12)
        .toList();
  }

  Future<List<Song>> getRecommendationsByMood(
    String mood, {
    int limit = 12,
  }) async {
    final normalizedMood = moods.firstWhere(
      (supportedMood) =>
          supportedMood.toLowerCase() == mood.trim().toLowerCase(),
      orElse: () => '',
    );
    if (normalizedMood.isEmpty) return [];

    final tracks = await _searchCached(_searchQueries[normalizedMood]!);
    return tracks.take(limit.clamp(0, 50).toInt()).toList();
  }

  Future<List<Song>> getRecommendationsByGenre(
    String genre, {
    int limit = 12,
  }) async {
    if (genre.trim().isEmpty) return [];
    return (await _searchCached(genre))
        .take(limit.clamp(0, 50).toInt())
        .toList();
  }

  Future<List<Song>> searchRecommendations(String query) {
    return _audius.searchTracks(query);
  }

  Future<List<Song>> getRandomRecommendations({int limit = 6}) async {
    if (limit <= 0) return [];
    final results = await Future.wait(
      moods.map((mood) => getRecommendationsByMood(mood, limit: 3)),
    );
    final mixed = _distinctTracks(results.expand((tracks) => tracks)).toList()
      ..shuffle(Random());
    return mixed.take(limit).toList();
  }

  Future<List<Song>> _searchCached(String query) async {
    final key = query.toLowerCase();
    final cached = _cache[key];
    final cachedAt = _cacheTime[key];
    if (cached != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < const Duration(minutes: 5)) {
      return cached;
    }

    final tracks = await _audius.searchTracks(query, limit: 20);
    _cache[key] = tracks;
    _cacheTime[key] = DateTime.now();
    return tracks;
  }

  Iterable<Song> _distinctTracks(Iterable<Song> tracks) sync* {
    final seen = <String>{};
    for (final track in tracks) {
      if (seen.add(track.identifier)) yield track;
    }
  }
}
