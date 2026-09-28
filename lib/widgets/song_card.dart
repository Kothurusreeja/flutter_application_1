import 'package:flutter/material.dart';

import '../controllers/favorites_controller.dart';
import '../models/song.dart';

class SongCard extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final VoidCallback? onPlay;

  const SongCard({
    super.key,
    required this.song,
    required this.onTap,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: 1,
      child: AnimatedBuilder(
        animation: FavoritesController.instance,
        builder: (context, _) {
          final favoritesController = FavoritesController.instance;
          final isFavorite = favoritesController.isFavorite(song.identifier);

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF191923),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9C6BFF), Color(0xFFFF5C8A)],
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: song.artworkUrl == null
                            ? Center(
                                child: Text(
                                  song.emoji,
                                  style: const TextStyle(fontSize: 27),
                                ),
                              )
                            : Image.network(
                                song.artworkUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Center(
                                  child: Text(
                                    song.emoji,
                                    style: const TextStyle(fontSize: 27),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              song.artist,
                              style: const TextStyle(color: Colors.white54),
                            ),
                            if (song.durationSeconds != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                _formatDuration(song.durationSeconds!),
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        key: ValueKey('favorite-${song.identifier}'),
                        tooltip: isFavorite
                            ? 'Remove from Favorites'
                            : 'Add to Favorites',
                        onPressed: () async {
                          try {
                            await favoritesController.toggleFavorite(song);
                          } catch (error) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    favoritesController.error ??
                                        'Could not update Favorites.',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? Colors.pinkAccent
                              : Colors.white70,
                          size: 27,
                        ),
                      ),
                      IconButton(
                        key: ValueKey('play-${song.identifier}'),
                        tooltip: 'Play ${song.title}',
                        onPressed: onPlay ?? onTap,
                        icon: const Icon(Icons.play_circle_fill, size: 34),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

String _formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final remainder = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$remainder';
}
