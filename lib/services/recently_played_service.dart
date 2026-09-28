import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/music_data.dart';
import '../models/song.dart';

class RecentlyPlayedService {
  static const String _recentlyPlayedKey = 'vibetune_recently_played';
  static const String _recentlyPlayedSongsKey =
      'vibetune_recently_played_songs';
  static const int _maxHistory = 20;

  Map<String, Song> _loadSongMetadata(SharedPreferences prefs) {
    final encodedSongs = prefs.getString(_recentlyPlayedSongsKey);
    if (encodedSongs == null) return {};
    final decoded = jsonDecode(encodedSongs);
    if (decoded is! List) {
      throw const FormatException('Recently played metadata is invalid.');
    }
    final songs = decoded.whereType<Map<String, dynamic>>().map(Song.fromJson);
    return {for (final song in songs) song.identifier: song};
  }

  List<Song> _resolveSongs(
    Iterable<String> identifiers,
    Map<String, Song> savedSongs,
  ) {
    final songsById = {
      for (final song in allSongs) song.identifier: song,
      ...savedSongs,
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
    return _resolveSongs(identifiers, _loadSongMetadata(prefs));
  }

  Future<List<Song>> addRecentlyPlayed(Song song) async {
    final prefs = await SharedPreferences.getInstance();
    final identifiers = (prefs.getStringList(_recentlyPlayedKey) ?? <String>[])
        .toSet()
        .toList();
    final savedSongs = _loadSongMetadata(prefs);
    identifiers
      ..removeWhere((identifier) => identifier == song.identifier)
      ..insert(0, song.identifier);
    savedSongs[song.identifier] = song;
    if (identifiers.length > _maxHistory) {
      identifiers.removeRange(_maxHistory, identifiers.length);
    }
    savedSongs.removeWhere(
      (identifier, _) => !identifiers.contains(identifier),
    );
    await prefs.setStringList(_recentlyPlayedKey, identifiers);
    await _saveSongMetadata(prefs, savedSongs);
    return _resolveSongs(identifiers, savedSongs);
  }

  Future<List<Song>> removeRecentlyPlayed(Song song) async {
    final prefs = await SharedPreferences.getInstance();
    final identifiers = prefs.getStringList(_recentlyPlayedKey) ?? <String>[];
    identifiers.removeWhere((identifier) => identifier == song.identifier);
    final savedSongs = _loadSongMetadata(prefs)..remove(song.identifier);
    await prefs.setStringList(_recentlyPlayedKey, identifiers);
    await _saveSongMetadata(prefs, savedSongs);
    return _resolveSongs(identifiers, savedSongs);
  }

  Future<void> clearRecentlyPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentlyPlayedKey);
    await prefs.remove(_recentlyPlayedSongsKey);
  }

  Future<void> _saveSongMetadata(
    SharedPreferences prefs,
    Map<String, Song> songs,
  ) async {
    await prefs.setString(
      _recentlyPlayedSongsKey,
      jsonEncode(songs.values.map((song) => song.toJson()).toList()),
    );
  }
}
