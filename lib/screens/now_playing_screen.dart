import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../controllers/favorites_controller.dart';
import '../controllers/recently_played_controller.dart';
import '../models/song.dart';

class NowPlayingScreen extends StatefulWidget {
  final Song song;
  final bool autoPlay;

  const NowPlayingScreen({
    super.key,
    required this.song,
    this.autoPlay = false,
  });

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  final AudioPlayer player = AudioPlayer();

  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isPlaying = false;
  bool isLoading = true;
  bool _recordedSuccessfulPlayback = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    player.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          duration = newDuration;
          isLoading = false;
        });
      }
    });

    player.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          position = newPosition;
        });
      }
    });

    player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
        if (state == PlayerState.playing && !_recordedSuccessfulPlayback) {
          _recordedSuccessfulPlayback = true;
          _recordSuccessfulPlayback();
        }
      }
    });

    player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          isPlaying = false;
          position = Duration.zero;
        });
      }
    });

    _loadSong();
  }

  Future<void> _loadSong() async {
    if (widget.song.file == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'No playable audio is available for this song.';
      });
      return;
    }

    try {
      await player.setSource(AssetSource('songs/${widget.song.file}'));
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = null;
      });
      if (widget.autoPlay) {
        await _startPlayback();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load song.';
      });
    }
  }

  Future<void> _startPlayback() async {
    if (errorMessage != null) {
      return;
    }

    try {
      await player.resume();
    } catch (error) {
      if (mounted) {
        setState(() {
          isPlaying = false;
          errorMessage = 'Unable to play this song.';
        });
      }
    }
  }

  Future<void> _recordSuccessfulPlayback() async {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await RecentlyPlayedController.instance.addRecentlyPlayed(widget.song);
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Could not save Recently Played history.'),
          ),
        );
      }
    }
  }

  Future<void> togglePlay() async {
    if (isPlaying) {
      await player.pause();
    } else {
      await _startPlayback();
    }
  }

  String formatTime(Duration time) {
    final minutes = time.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = time.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxSeconds = duration.inSeconds > 0
        ? duration.inSeconds.toDouble()
        : 1.0;
    final currentSeconds = position.inSeconds
        .clamp(0, duration.inSeconds)
        .toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        actions: [
          AnimatedBuilder(
            animation: FavoritesController.instance,
            builder: (context, _) {
              final isFavorite = FavoritesController.instance.isFavorite(
                widget.song.identifier,
              );
              return IconButton(
                tooltip: isFavorite
                    ? 'Remove from Favorites'
                    : 'Add to Favorites',
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.pinkAccent : null,
                  size: 27,
                ),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await FavoritesController.instance.toggleFavorite(
                      widget.song.identifier,
                    );
                  } catch (error) {
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            FavoritesController.instance.error ??
                                'Could not update Favorites.',
                          ),
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(
                child: Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9C6BFF), Color(0xFFFF5C8A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 30,
                          spreadRadius: 5,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.song.emoji,
                        style: const TextStyle(fontSize: 100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  Text(
                    widget.song.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.song.artist,
                    style: const TextStyle(color: Colors.white60, fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  Slider(
                    min: 0.0,
                    max: maxSeconds,
                    value: currentSeconds,
                    onChanged: duration.inSeconds == 0
                        ? null
                        : (value) async {
                            await player.seek(Duration(seconds: value.toInt()));
                          },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatTime(position)),
                        Text(formatTime(duration)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  IconButton(
                    onPressed: togglePlay,
                    iconSize: 75,
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
