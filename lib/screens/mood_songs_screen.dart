import 'package:flutter/material.dart';

import '../data/music_data.dart';
import '../models/song.dart';
import '../services/audius_search_service.dart';
import '../services/recommendation_service.dart';
import '../widgets/song_card.dart';
import 'now_playing_screen.dart';

class MoodSongsScreen extends StatefulWidget {
  final String mood;

  const MoodSongsScreen({super.key, required this.mood});

  @override
  State<MoodSongsScreen> createState() => _MoodSongsScreenState();
}

class _MoodSongsScreenState extends State<MoodSongsScreen> {
  final RecommendationService _recommendationService = RecommendationService();
  List<Song> _audiusSongs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  @override
  void dispose() {
    _recommendationService.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final songs = await _recommendationService.getRecommendationsByMood(
        widget.mood,
      );
      if (mounted) {
        setState(() {
          _audiusSongs = songs;
          _isLoading = false;
        });
      }
    } on AudiusApiException catch (error) {
      if (mounted) {
        setState(() {
          _error = error.message;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = 'Could not load Audius tracks. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  List<Song> get _moodSongs {
    final localSongs = songsForMood(widget.mood);
    final existingSongs = localSongs
        .map(
          (song) => '${song.title.toLowerCase()}|${song.artist.toLowerCase()}',
        )
        .toSet();
    return [
      ...localSongs,
      ..._audiusSongs.where(
        (song) => !existingSongs.contains(
          '${song.title.toLowerCase()}|${song.artist.toLowerCase()}',
        ),
      ),
    ];
  }

  void _openSong(Song song, {bool autoPlay = false}) {
    Navigator.push(
      context,
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) =>
            NowPlayingScreen(song: song, autoPlay: autoPlay),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final moodSongs = _moodSongs;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.mood} Vibes')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.mood} playlist',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Music selected for your ${widget.mood} mood.',
              style: const TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 25),
            if (_isLoading) const LinearProgressIndicator(),
            if (_error != null)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Audius: $_error',
                      style: const TextStyle(color: Colors.orangeAccent),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Retry',
                    onPressed: _loadRecommendations,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            Expanded(
              child: moodSongs.isEmpty
                  ? Center(
                      child: Text(
                        _isLoading
                            ? 'Loading Audius tracks…'
                            : _error ?? 'No tracks found for this mood.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView(
                      children: moodSongs
                          .map(
                            (song) => SongCard(
                              song: song,
                              onTap: () => _openSong(song),
                              onPlay: () => _openSong(song, autoPlay: true),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
