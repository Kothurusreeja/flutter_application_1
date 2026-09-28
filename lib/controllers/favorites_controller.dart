import 'package:flutter/material.dart';

import '../data/music_data.dart';
import '../models/song.dart';
import '../services/recommendation_service.dart';
import '../services/favorites_service.dart';

class FavoritesController extends ChangeNotifier {
  static final FavoritesController instance = FavoritesController._internal();

  factory FavoritesController() => instance;

  FavoritesController._internal();

  final FavoritesService _service = FavoritesService();
  final Set<String> _favorites = <String>{};
  bool _isLoading = true;
  bool _hasLoaded = false;
  Future<void>? _loadFuture;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Set<String> get favorites => Set.unmodifiable(_favorites);

  List<Song> get favoriteSongs => [
    ...allSongs,
    ...RecommendationService.getAllRecommendations(),
  ].where((song) => _favorites.contains(song.identifier)).toList();

  bool isFavorite(String songId) => _favorites.contains(songId);

  Future<void> loadFavorites() {
    if (_hasLoaded) return Future<void>.value();
    final activeLoad = _loadFuture;
    if (activeLoad != null) return activeLoad;

    final loadFuture = _loadFavorites();
    _loadFuture = loadFuture;
    return loadFuture;
  }

  Future<void> _loadFavorites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final savedFavorites = await _service.loadFavorites();
      _favorites
        ..clear()
        ..addAll(savedFavorites);
      _hasLoaded = true;
    } catch (error) {
      _error = 'Unable to load favorites right now.';
    } finally {
      _loadFuture = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadFavorites() async {
    _hasLoaded = false;
    await loadFavorites();
  }

  Future<void> toggleFavorite(String songId) async {
    await loadFavorites();
    if (!_hasLoaded) {
      throw StateError(_error ?? 'Favorites are not available yet.');
    }

    final wasFavorite = _favorites.contains(songId);
    if (wasFavorite) {
      _favorites.remove(songId);
    } else {
      _favorites.add(songId);
    }
    _error = null;
    notifyListeners();

    try {
      await _service.saveFavorites(_favorites);
    } catch (error) {
      if (wasFavorite) {
        _favorites.add(songId);
      } else {
        _favorites.remove(songId);
      }
      _error = 'Unable to save favorites.';
      notifyListeners();
      rethrow;
    }
  }
}
