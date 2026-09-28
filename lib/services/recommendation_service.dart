import 'dart:math';

import '../models/song.dart';

class RecommendationService {
  static const List<String> moods = [
    'Happy',
    'Chill',
    'Romantic',
    'Sad',
    'Energetic',
    'Focus',
  ];

  static const List<Song> _catalog = [
    Song(
      id: 'recommendation_happy_01',
      title: 'On Top of the World',
      artist: 'Imagine Dragons',
      album: 'Local Recommendations',
      genre: 'Pop rock',
      mood: 'Happy',
      language: 'English',
      emoji: '😊',
    ),
    Song(
      id: 'recommendation_happy_02',
      title: 'Happy',
      artist: 'Pharrell Williams',
      album: 'Local Recommendations',
      genre: 'Soul, pop',
      mood: 'Happy',
      language: 'English',
      emoji: '😊',
    ),
    Song(
      id: 'recommendation_happy_03',
      title: "Can't Stop the Feeling!",
      artist: 'Justin Timberlake',
      album: 'Local Recommendations',
      genre: 'Disco pop',
      mood: 'Happy',
      language: 'English',
      emoji: '😊',
    ),
    Song(
      id: 'recommendation_happy_04',
      title: 'What Makes You Beautiful',
      artist: 'One Direction',
      album: 'Local Recommendations',
      genre: 'Teen pop',
      mood: 'Happy',
      language: 'English',
      emoji: '😊',
    ),
    Song(
      id: 'recommendation_happy_05',
      title: 'Butta Bomma',
      artist: 'Armaan Malik',
      album: 'Local Recommendations',
      genre: 'Indian pop',
      mood: 'Happy',
      language: 'Telugu',
      emoji: '😊',
    ),
    Song(
      id: 'recommendation_happy_06',
      title: 'Zinda',
      artist: 'Siddharth Mahadevan',
      album: 'Local Recommendations',
      genre: 'Rock',
      mood: 'Happy',
      language: 'Hindi',
      emoji: '😊',
    ),
    Song(
      id: 'recommendation_chill_01',
      title: 'Ocean Eyes',
      artist: 'Billie Eilish',
      album: 'Local Recommendations',
      genre: 'Dream pop',
      mood: 'Chill',
      language: 'English',
      emoji: '😌',
    ),
    Song(
      id: 'recommendation_chill_02',
      title: 'Sunset Lover',
      artist: 'Petit Biscuit',
      album: 'Local Recommendations',
      genre: 'Electronic',
      mood: 'Chill',
      language: 'Instrumental',
      emoji: '😌',
    ),
    Song(
      id: 'recommendation_chill_03',
      title: 'Until I Found You',
      artist: 'Stephen Sanchez',
      album: 'Local Recommendations',
      genre: 'Pop',
      mood: 'Chill',
      language: 'English',
      emoji: '😌',
    ),
    Song(
      id: 'recommendation_chill_04',
      title: 'Perfect',
      artist: 'Ed Sheeran',
      album: 'Local Recommendations',
      genre: 'Pop, soft rock',
      mood: 'Chill',
      language: 'English',
      emoji: '😌',
    ),
    Song(
      id: 'recommendation_chill_05',
      title: 'Inkem Inkem Inkem Kaavaale',
      artist: 'Sid Sriram',
      album: 'Local Recommendations',
      genre: 'Indian film music',
      mood: 'Chill',
      language: 'Telugu',
      emoji: '😌',
    ),
    Song(
      id: 'recommendation_chill_06',
      title: 'Samajavaragamana',
      artist: 'Sid Sriram',
      album: 'Local Recommendations',
      genre: 'Indian film music',
      mood: 'Chill',
      language: 'Telugu',
      emoji: '😌',
    ),
    Song(
      id: 'recommendation_romantic_01',
      title: 'Lover',
      artist: 'Taylor Swift',
      album: 'Local Recommendations',
      genre: 'Pop',
      mood: 'Romantic',
      language: 'English',
      emoji: '❤️',
    ),
    Song(
      id: 'recommendation_romantic_02',
      title: 'All of Me',
      artist: 'John Legend',
      album: 'Local Recommendations',
      genre: 'R&B, soul',
      mood: 'Romantic',
      language: 'English',
      emoji: '❤️',
    ),
    Song(
      id: 'recommendation_romantic_03',
      title: 'A Thousand Years',
      artist: 'Christina Perri',
      album: 'Local Recommendations',
      genre: 'Pop',
      mood: 'Romantic',
      language: 'English',
      emoji: '❤️',
    ),
    Song(
      id: 'recommendation_romantic_04',
      title: 'Tum Hi Ho',
      artist: 'Arijit Singh',
      album: 'Local Recommendations',
      genre: 'Indian film music',
      mood: 'Romantic',
      language: 'Hindi',
      emoji: '❤️',
    ),
    Song(
      id: 'recommendation_romantic_05',
      title: 'Kesariya',
      artist: 'Arijit Singh',
      album: 'Local Recommendations',
      genre: 'Indian film music',
      mood: 'Romantic',
      language: 'Hindi',
      emoji: '❤️',
    ),
    Song(
      id: 'recommendation_romantic_06',
      title: 'Vachindamma',
      artist: 'Sid Sriram',
      album: 'Local Recommendations',
      genre: 'Indian film music',
      mood: 'Romantic',
      language: 'Telugu',
      emoji: '❤️',
    ),
    Song(
      id: 'recommendation_sad_01',
      title: 'Someone You Loved',
      artist: 'Lewis Capaldi',
      album: 'Local Recommendations',
      genre: 'Pop',
      mood: 'Sad',
      language: 'English',
      emoji: '💔',
    ),
    Song(
      id: 'recommendation_sad_02',
      title: 'Lovely',
      artist: 'Billie Eilish & Khalid',
      album: 'Local Recommendations',
      genre: 'Indie pop',
      mood: 'Sad',
      language: 'English',
      emoji: '💔',
    ),
    Song(
      id: 'recommendation_sad_03',
      title: 'Let Her Go',
      artist: 'Passenger',
      album: 'Local Recommendations',
      genre: 'Folk rock',
      mood: 'Sad',
      language: 'English',
      emoji: '💔',
    ),
    Song(
      id: 'recommendation_sad_04',
      title: 'Channa Mereya',
      artist: 'Arijit Singh',
      album: 'Local Recommendations',
      genre: 'Indian film music',
      mood: 'Sad',
      language: 'Hindi',
      emoji: '💔',
    ),
    Song(
      id: 'recommendation_sad_05',
      title: 'Agar Tum Saath Ho',
      artist: 'Alka Yagnik & Arijit Singh',
      album: 'Local Recommendations',
      genre: 'Indian film music',
      mood: 'Sad',
      language: 'Hindi',
      emoji: '💔',
    ),
    Song(
      id: 'recommendation_sad_06',
      title: 'Adiga Adiga',
      artist: 'Sid Sriram',
      album: 'Local Recommendations',
      genre: 'Indian film music',
      mood: 'Sad',
      language: 'Telugu',
      emoji: '💔',
    ),
    Song(
      id: 'recommendation_energetic_01',
      title: 'Believer',
      artist: 'Imagine Dragons',
      album: 'Local Recommendations',
      genre: 'Pop rock',
      mood: 'Energetic',
      language: 'English',
      emoji: '🔥',
    ),
    Song(
      id: 'recommendation_energetic_02',
      title: 'Thunder',
      artist: 'Imagine Dragons',
      album: 'Local Recommendations',
      genre: 'Pop rock',
      mood: 'Energetic',
      language: 'English',
      emoji: '🔥',
    ),
    Song(
      id: 'recommendation_energetic_03',
      title: 'Counting Stars',
      artist: 'OneRepublic',
      album: 'Local Recommendations',
      genre: 'Pop rock',
      mood: 'Energetic',
      language: 'English',
      emoji: '🔥',
    ),
    Song(
      id: 'recommendation_energetic_04',
      title: 'Shape of You',
      artist: 'Ed Sheeran',
      album: 'Local Recommendations',
      genre: 'Pop',
      mood: 'Energetic',
      language: 'English',
      emoji: '🔥',
    ),
    Song(
      id: 'recommendation_energetic_05',
      title: 'Naatu Naatu',
      artist: 'Rahul Sipligunj & Kaala Bhairava',
      album: 'Local Recommendations',
      genre: 'Indian film music',
      mood: 'Energetic',
      language: 'Telugu',
      emoji: '🔥',
    ),
    Song(
      id: 'recommendation_energetic_06',
      title: 'Malhari',
      artist: 'Vishal Dadlani',
      album: 'Local Recommendations',
      genre: 'Indian film music',
      mood: 'Energetic',
      language: 'Hindi',
      emoji: '🔥',
    ),
    Song(
      id: 'recommendation_focus_01',
      title: 'Experience',
      artist: 'Ludovico Einaudi',
      album: 'Local Recommendations',
      genre: 'Classical, contemporary',
      mood: 'Focus',
      language: 'Instrumental',
      emoji: '📚',
    ),
    Song(
      id: 'recommendation_focus_02',
      title: 'River Flows in You',
      artist: 'Yiruma',
      album: 'Local Recommendations',
      genre: 'Classical, piano',
      mood: 'Focus',
      language: 'Instrumental',
      emoji: '📚',
    ),
    Song(
      id: 'recommendation_focus_03',
      title: "Comptine d'un autre été",
      artist: 'Yann Tiersen',
      album: 'Local Recommendations',
      genre: 'Classical, piano',
      mood: 'Focus',
      language: 'Instrumental',
      emoji: '📚',
    ),
    Song(
      id: 'recommendation_focus_04',
      title: 'Weightless',
      artist: 'Marconi Union',
      album: 'Local Recommendations',
      genre: 'Ambient',
      mood: 'Focus',
      language: 'Instrumental',
      emoji: '📚',
    ),
    Song(
      id: 'recommendation_focus_05',
      title: 'Kiss the Rain',
      artist: 'Yiruma',
      album: 'Local Recommendations',
      genre: 'Classical, piano',
      mood: 'Focus',
      language: 'Instrumental',
      emoji: '📚',
    ),
    Song(
      id: 'recommendation_focus_06',
      title: 'Nuvole Bianche',
      artist: 'Ludovico Einaudi',
      album: 'Local Recommendations',
      genre: 'Classical, contemporary',
      mood: 'Focus',
      language: 'Instrumental',
      emoji: '📚',
    ),
  ];

  static List<Song> getAllRecommendations() => List.unmodifiable(_catalog);

  static List<Song> getRecommendationsByMood(String mood) => _catalog
      .where((song) => song.mood.toLowerCase() == mood.trim().toLowerCase())
      .toList();

  static List<Song> getRecommendationsByGenre(String genre) => _catalog
      .where(
        (song) => song.genre.toLowerCase().contains(genre.trim().toLowerCase()),
      )
      .toList();

  static List<Song> searchRecommendations(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return getAllRecommendations();

    return _catalog.where((song) {
      return [
        song.title,
        song.artist,
        song.album,
        song.genre,
        song.mood,
        song.language,
      ].any((value) => value.toLowerCase().contains(normalizedQuery));
    }).toList();
  }

  static List<Song> getRandomRecommendations({int limit = 6}) {
    if (limit <= 0) return [];
    final random = Random();
    final selected = <Song>[];
    for (final mood in moods) {
      final matching = getRecommendationsByMood(mood);
      if (matching.isNotEmpty && selected.length < limit) {
        selected.add(matching[random.nextInt(matching.length)]);
      }
    }
    final remaining =
        _catalog.where((song) => !selected.contains(song)).toList()
          ..shuffle(random);
    selected.addAll(remaining.take(limit - selected.length));
    return selected;
  }
}
