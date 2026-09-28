import 'package:shared_preferences/shared_preferences.dart';

import '../data/music_data.dart';
import '../models/song.dart';
import 'recommendation_service.dart';

class RecentlyPlayedService {
  static const String _recentlyPlayedKey = 'vibetune_recently_played';
  static const int _maxHistory = 20;

  List<Song> _resolveSongs(Iterable<String> identifiers) {
    final songsById = {
      for (final song in [
        ...allSongs,
        ...RecommendationService.getAllRecommendations(),
      ])
        song.identifier: song,
    };
    return identifiers
        .map((identifier) => songsById[identifier])
        .whereType<Song>()
        .toList();
  }

  Future<List<Song>> getRecentlyPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final storedIdentifiers =
        prefs.getStringList(_recentlyPlayedKey) ?? <String>[];
    final identifiers = storedIdentifiers.toSet().take(_maxHistory).toList();
    if (identifiers.length != storedIdentifiers.length) {
      await prefs.setStringList(_recentlyPlayedKey, identifiers);
    }
    return _resolveSongs(identifiers);
  }

  Future<List<Song>> addRecentlyPlayed(Song song) async {
    final prefs = await SharedPreferences.getInstance();
    final identifiers = (prefs.getStringList(_recentlyPlayedKey) ?? <String>[])
        .toSet()
        .toList();
    identifiers
      ..removeWhere((identifier) => identifier == song.identifier)
      ..insert(0, song.identifier);
    if (identifiers.length > _maxHistory) {
      identifiers.removeRange(_maxHistory, identifiers.length);
    }
    await prefs.setStringList(_recentlyPlayedKey, identifiers);
    return _resolveSongs(identifiers);
  }

  Future<List<Song>> removeRecentlyPlayed(Song song) async {
    final prefs = await SharedPreferences.getInstance();
    final identifiers = prefs.getStringList(_recentlyPlayedKey) ?? <String>[];
    identifiers.removeWhere((identifier) => identifier == song.identifier);
    await prefs.setStringList(_recentlyPlayedKey, identifiers);
    return _resolveSongs(identifiers);
  }

  Future<void> clearRecentlyPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentlyPlayedKey);
  }
}
