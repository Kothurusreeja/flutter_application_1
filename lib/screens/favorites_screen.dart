import 'package:flutter/material.dart';

import '../controllers/favorites_controller.dart';
import '../models/song.dart';
import '../widgets/song_card.dart';
import 'now_playing_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesController _controller = FavoritesController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleControllerChange);
    _controller.loadFavorites();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    super.dispose();
  }

  void _handleControllerChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void openSong(Song song, {bool autoPlay = false}) {
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
    final favorites = _controller.favoriteSongs;

    if (_controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_controller.error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _controller.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _controller.reloadFavorites,
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: favorites.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Colors.white38,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No favorite songs yet',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tap the ❤️ icon beside a song to add it to Favorites.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: favorites.map((song) {
                return Dismissible(
                  key: ValueKey(song.identifier),
                  onDismissed: (_) async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await _controller.toggleFavorite(song);
                    } catch (error) {
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              _controller.error ??
                                  'Could not update Favorites.',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: SongCard(
                    song: song,
                    onTap: () => openSong(song),
                    onPlay: () => openSong(song, autoPlay: true),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
