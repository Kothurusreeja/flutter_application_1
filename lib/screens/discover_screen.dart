import 'dart:async';

import 'package:flutter/material.dart';

import '../data/music_data.dart';
import '../models/song.dart';
import '../services/audius_search_service.dart';
import '../widgets/search_field.dart';
import '../widgets/song_card.dart';
import 'now_playing_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final AudiusSearchService _audiusService = AudiusSearchService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';
  List<Song> _audiusMatches = [];
  bool _isSearchingAudius = false;
  String? _searchError;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _audiusService.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    _updateSearch(_searchController.text);
  }

  void _updateSearch(String value) {
    final query = value.trim();
    _searchDebounce?.cancel();
    setState(() {
      _searchQuery = query.toLowerCase();
      _audiusMatches = [];
      _searchError = null;
      _isSearchingAudius = query.isNotEmpty;
    });
    if (query.isEmpty) return;
    _searchDebounce = Timer(
      const Duration(milliseconds: 400),
      () => _searchAudius(query),
    );
  }

  Future<void> _searchAudius(String query) async {
    try {
      final matches = await _audiusService.searchTracks(query);
      if (mounted && _searchQuery == query.toLowerCase()) {
        setState(() {
          _audiusMatches = matches;
          _isSearchingAudius = false;
        });
      }
    } on AudiusApiException catch (error) {
      if (mounted && _searchQuery == query.toLowerCase()) {
        setState(() {
          _searchError = error.message;
          _isSearchingAudius = false;
        });
      }
    } catch (error) {
      if (mounted && _searchQuery == query.toLowerCase()) {
        setState(() {
          _searchError = 'Audius search failed. Please try again.';
          _isSearchingAudius = false;
        });
      }
    }
  }

  List<Song> get filteredSongs {
    final query = _searchQuery.trim();
    if (query.isEmpty) {
      return allSongs;
    }

    final existingMatches = allSongs.where((song) {
      return [
        song.title,
        song.artist,
        song.album,
        song.genre,
        song.mood,
        song.language,
      ].any((value) => value.toLowerCase().contains(query));
    }).toList();
    final existingSongKeys = existingMatches
        .map(
          (song) => '${song.title.toLowerCase()}|${song.artist.toLowerCase()}',
        )
        .toSet();
    final audiusMatches = _audiusMatches.where((song) {
      return !existingSongKeys.contains(
        '${song.title.toLowerCase()}|${song.artist.toLowerCase()}',
      );
    });
    return [...existingMatches, ...audiusMatches];
  }

  void openSong(BuildContext context, Song song, {bool autoPlay = false}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) =>
            NowPlayingScreen(song: song, autoPlay: autoPlay),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final songs = filteredSongs;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Discover',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Explore your sound',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Find music based on how you feel.',
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 20),
            SearchField(
              controller: _searchController,
              onChanged: _updateSearch,
              onSearch: _triggerSearch,
            ),
            const SizedBox(height: 25),
            const Text(
              'Moods',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: moods.map((mood) {
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 145,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: mood.color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mood.emoji, style: const TextStyle(fontSize: 30)),
                        const SizedBox(height: 10),
                        Text(
                          mood.name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            const Text(
              'All songs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            if (_isSearchingAudius)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(),
              ),
            if (_searchError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Audius: $_searchError',
                  style: const TextStyle(color: Colors.orangeAccent),
                ),
              ),
            if (songs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF191923),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  _isSearchingAudius
                      ? 'Searching Audius…'
                      : _searchError ?? 'No songs found',
                  style: const TextStyle(color: Colors.white70),
                ),
              )
            else
              ...songs.map(
                (song) => SongCard(
                  song: song,
                  onTap: () => openSong(context, song),
                  onPlay: () => openSong(context, song, autoPlay: true),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
