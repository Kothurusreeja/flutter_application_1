import 'package:flutter/material.dart';

import '../data/music_data.dart';
import '../models/song.dart';
import '../services/recommendation_service.dart';
import '../widgets/search_field.dart';
import '../widgets/song_card.dart';
import 'now_playing_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  List<Song> get filteredSongs {
    final query = _searchQuery.trim();
    if (query.isEmpty) {
      return [...allSongs, ...RecommendationService.getAllRecommendations()];
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
    final recommendationMatches =
        RecommendationService.searchRecommendations(query).where((song) {
          return !existingSongKeys.contains(
            '${song.title.toLowerCase()}|${song.artist.toLowerCase()}',
          );
        });
    return [...existingMatches, ...recommendationMatches];
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
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
            if (songs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF191923),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'No songs found',
                  style: TextStyle(color: Colors.white70),
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
