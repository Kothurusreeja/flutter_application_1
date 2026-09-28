import 'package:flutter/material.dart';

import '../data/music_data.dart';
import '../widgets/song_card.dart';
import 'now_playing_screen.dart';

class MoodSongsScreen extends StatelessWidget {
  final String mood;

  const MoodSongsScreen({super.key, required this.mood});

  @override
  Widget build(BuildContext context) {
    final moodSongs = songsForMood(mood);

    return Scaffold(
      appBar: AppBar(title: Text('$mood Vibes')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$mood playlist',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Music selected for your $mood mood.',
              style: const TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 25),
            if (moodSongs.isEmpty)
              const Expanded(
                child: Center(child: Text('No songs available for this mood.')),
              )
            else
              Expanded(
                child: ListView(
                  children: moodSongs.map((song) {
                    return SongCard(
                      song: song,
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, _, _) =>
                                NowPlayingScreen(song: song),
                            transitionsBuilder: (_, animation, _, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      onPlay: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder<void>(
                            pageBuilder: (_, _, _) =>
                                NowPlayingScreen(song: song, autoPlay: true),
                            transitionsBuilder: (_, animation, _, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
