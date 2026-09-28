import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'vibetune_favorites';

  Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_favoritesKey) ?? <String>[];
    return saved.toSet();
  }

  Future<void> saveFavorites(Set<String> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, favorites.toList());
    } catch (_) {
      rethrow;
    }
  }
}
