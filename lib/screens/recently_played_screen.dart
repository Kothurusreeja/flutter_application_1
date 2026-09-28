import 'package:flutter/material.dart';

import '../controllers/recently_played_controller.dart';
import '../models/song.dart';
import '../widgets/song_card.dart';
import 'now_playing_screen.dart';

class RecentlyPlayedScreen extends StatefulWidget {
  const RecentlyPlayedScreen({super.key});

  @override
  State<RecentlyPlayedScreen> createState() => _RecentlyPlayedScreenState();
}

class _RecentlyPlayedScreenState extends State<RecentlyPlayedScreen> {
  final RecentlyPlayedController _controller =
      RecentlyPlayedController.instance;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleChange);
    _controller.loadRecentlyPlayed();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    if (mounted) setState(() {});
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

  Future<void> _clearHistory() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _controller.clearRecentlyPlayed();
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              _controller.error ?? 'Could not clear Recently Played.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recently Played',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_controller.songs.isNotEmpty)
            TextButton(onPressed: _clearHistory, child: const Text('Clear')),
        ],
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _controller.error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_controller.error!, textAlign: TextAlign.center),
                  TextButton(
                    onPressed: _controller.reloadRecentlyPlayed,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            )
          : _controller.songs.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Text(
                  'No songs played yet.\nStart playing a song and it will appear here.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: _controller.songs
                  .map(
                    (song) => Dismissible(
                      key: ValueKey(song.identifier),
                      onDismissed: (_) async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          await _controller.removeRecentlyPlayed(song);
                        } catch (error) {
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  _controller.error ??
                                      'Could not remove song from history.',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: SongCard(
                        song: song,
                        onTap: () => _openSong(song),
                        onPlay: () => _openSong(song, autoPlay: true),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
