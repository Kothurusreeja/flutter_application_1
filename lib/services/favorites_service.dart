import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/song.dart';

class FavoritesService {
  static const String _favoritesKey = 'vibetune_favorites';
  static const String _favoriteSongsKey = 'vibetune_favorite_songs';

  Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_favoritesKey) ?? <String>[];
    return saved.toSet();
  }

  Future<void> saveFavorites(Set<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites.toList());
  }

  Future<List<Song>> loadFavoriteSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedSongs = prefs.getString(_favoriteSongsKey);
    if (encodedSongs == null) return [];

    final decoded = jsonDecode(encodedSongs);
    if (decoded is! List) {
      throw const FormatException('Saved favorite songs have invalid data.');
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Song.fromJson)
        .toList();
  }

  Future<void> saveFavoriteSongs(Iterable<Song> songs) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(songs.map((song) => song.toJson()).toList());
    await prefs.setString(_favoriteSongsKey, json);
  }
}
