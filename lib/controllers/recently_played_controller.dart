import 'package:flutter/material.dart';

import '../models/song.dart';
import '../services/recently_played_service.dart';

class RecentlyPlayedController extends ChangeNotifier {
  static final RecentlyPlayedController instance =
      RecentlyPlayedController._internal();

  factory RecentlyPlayedController() => instance;

  RecentlyPlayedController._internal();

  final RecentlyPlayedService _service = RecentlyPlayedService();
  List<Song> _songs = [];
  bool _isLoading = true;
  bool _hasLoaded = false;
  int _changeVersion = 0;
  Future<void>? _loadFuture;
  String? _error;

  List<Song> get songs => List.unmodifiable(_songs);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRecentlyPlayed() {
    if (_hasLoaded) return Future<void>.value();
    final activeLoad = _loadFuture;
    if (activeLoad != null) return activeLoad;

    final loadFuture = _loadRecentlyPlayed();
    _loadFuture = loadFuture;
    return loadFuture;
  }

  Future<void> _loadRecentlyPlayed() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final loadVersion = _changeVersion;
    try {
      final loadedSongs = await _service.getRecentlyPlayed();
      if (loadVersion == _changeVersion) {
        _songs = loadedSongs;
        _hasLoaded = true;
      }
    } catch (error) {
      _error = 'Unable to load recently played songs.';
    } finally {
      _loadFuture = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadRecentlyPlayed() async {
    _hasLoaded = false;
    await loadRecentlyPlayed();
  }

  Future<void> addRecentlyPlayed(Song song) async {
    await loadRecentlyPlayed();
    if (!_hasLoaded) {
      throw StateError(_error ?? 'Recently Played is not available yet.');
    }
    _changeVersion++;
    try {
      _songs = await _service.addRecentlyPlayed(song);
      _hasLoaded = true;
      _error = null;
      notifyListeners();
    } catch (error) {
      _error = 'Unable to save recently played songs.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeRecentlyPlayed(Song song) async {
    await loadRecentlyPlayed();
    if (!_hasLoaded) {
      throw StateError(_error ?? 'Recently Played is not available yet.');
    }
    _changeVersion++;
    try {
      _songs = await _service.removeRecentlyPlayed(song);
      _error = null;
      notifyListeners();
    } catch (error) {
      _error = 'Unable to remove this song from recently played.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> clearRecentlyPlayed() async {
    await loadRecentlyPlayed();
    if (!_hasLoaded) {
      throw StateError(_error ?? 'Recently Played is not available yet.');
    }
    _changeVersion++;
    try {
      await _service.clearRecentlyPlayed();
      _songs = [];
      _error = null;
      notifyListeners();
    } catch (error) {
      _error = 'Unable to clear recently played songs.';
      notifyListeners();
      rethrow;
    }
  }
}
