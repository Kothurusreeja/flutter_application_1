import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/favorites_controller.dart';
import '../controllers/recently_played_controller.dart';
import '../data/music_data.dart';
import '../models/song.dart';
import '../services/audius_search_service.dart';
import '../services/recommendation_service.dart';
import '../widgets/search_field.dart';
import '../widgets/song_card.dart';
import 'mood_songs_screen.dart';
import 'now_playing_screen.dart';
import 'recently_played_screen.dart';

class HomeScreen extends StatefulWidget {
  final AudiusSearchService? audiusSearchService;
  final RecommendationService? recommendationService;

  const HomeScreen({
    super.key,
    this.audiusSearchService,
    this.recommendationService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecentlyPlayedController _recentlyPlayedController =
      RecentlyPlayedController.instance;
  late final RecommendationService _recommendationService;
  late final AudiusSearchService _audiusSearchService;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';
  String? _selectedRecommendationMood;
  List<Song> _audiusSearchResults = [];
  List<Song> _recommendedSongs = [];
  bool _isSearchLoading = false;
  bool _isRecommendationsLoading = true;
  String? _searchError;
  String? _recommendationError;

  @override
  void initState() {
    super.initState();
    _recommendationService =
        widget.recommendationService ?? RecommendationService();
    _audiusSearchService = widget.audiusSearchService ?? AudiusSearchService();
    _recentlyPlayedController.addListener(_handleRecentlyPlayedChange);
    FavoritesController.instance.loadFavorites();
    _recentlyPlayedController.loadRecentlyPlayed();
    _loadRecommendations();
  }

  @override
  void dispose() {
    _recentlyPlayedController.removeListener(_handleRecentlyPlayedChange);
    _searchDebounce?.cancel();
    _audiusSearchService.dispose();
    _recommendationService.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleRecentlyPlayedChange() {
    if (mounted) setState(() {});
  }

  void _updateSearch(String value) {
    final query = value.trim();
    _searchDebounce?.cancel();
    setState(() {
      _searchQuery = query.toLowerCase();
      _audiusSearchResults = [];
      _searchError = null;
      _isSearchLoading = query.isNotEmpty;
    });
    if (query.isEmpty) return;
    _searchDebounce = Timer(
      const Duration(milliseconds: 400),
      () => _searchAudius(query),
    );
  }

  Future<void> _searchAudius(String query) async {
    try {
      final songs = await _audiusSearchService.searchTracks(query);
      if (mounted && _searchQuery == query.toLowerCase()) {
        setState(() {
          _audiusSearchResults = songs;
          _isSearchLoading = false;
        });
      }
    } on AudiusApiException catch (error) {
      if (mounted && _searchQuery == query.toLowerCase()) {
        setState(() {
          _searchError = error.message;
          _isSearchLoading = false;
        });
      }
    } catch (error) {
      if (mounted && _searchQuery == query.toLowerCase()) {
        setState(() {
          _searchError = 'Audius search failed. Please try again.';
          _isSearchLoading = false;
        });
      }
    }
  }

  Future<void> _loadRecommendations() async {
    if (mounted) {
      setState(() {
        _isRecommendationsLoading = true;
        _recommendationError = null;
      });
    }
    try {
      final songs = _selectedRecommendationMood == null
          ? await _recommendationService.getRandomRecommendations()
          : await _recommendationService.getRecommendationsByMood(
              _selectedRecommendationMood!,
            );
      if (mounted) {
        setState(() {
          _recommendedSongs = songs;
          _isRecommendationsLoading = false;
        });
      }
    } on AudiusApiException catch (error) {
      if (mounted) {
        setState(() {
          _recommendationError = error.message;
          _isRecommendationsLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _recommendationError =
              'Could not load Audius recommendations. Please try again.';
          _isRecommendationsLoading = false;
        });
      }
    }
  }

  void _selectRecommendationMood(String? mood) {
    setState(() => _selectedRecommendationMood = mood);
    _loadRecommendations();
  }

  List<Song> get filteredSongs {
    final query = _searchQuery.trim();
    if (query.isEmpty) {
      return allSongs;
    }

    final existingMatches = allSongs.where((song) {
      final title = song.title.toLowerCase();
      final artist = song.artist.toLowerCase();
      final album = song.album.toLowerCase();
      final mood = song.mood.toLowerCase();
      return [
        title,
        artist,
        album,
        mood,
        song.genre.toLowerCase(),
        song.language.toLowerCase(),
      ].any((value) => value.contains(query));
    }).toList();
    final existingSongKeys = existingMatches
        .map(
          (song) => '${song.title.toLowerCase()}|${song.artist.toLowerCase()}',
        )
        .toSet();
    final audiusMatches = _audiusSearchResults.where((song) {
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

  void openMood(BuildContext context, String mood) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => MoodSongsScreen(mood: mood),
        transitionsBuilder: (_, animation, _, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displaySongs = filteredSongs;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'VibeTune',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Good evening 👋',
              style: TextStyle(fontSize: 15, color: Colors.white60),
            ),
            const SizedBox(height: 6),
            const Text(
              'What’s your vibe?',
              style: TextStyle(fontSize: 29, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SearchField(
              controller: _searchController,
              onChanged: _updateSearch,
              onSearch: () => _updateSearch(_searchController.text),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Search results',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              if (_isSearchLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(),
                ),
              if (_searchError != null) _emptyMessage(_searchError!),
              if (displaySongs.isEmpty)
                _emptyMessage(
                  _isSearchLoading
                      ? 'Searching Audius…'
                      : _searchError ?? 'No songs found',
                )
              else
                ...displaySongs.map(
                  (song) => SongCard(
                    song: song,
                    onTap: () => openSong(context, song),
                    onPlay: () => openSong(context, song, autoPlay: true),
                  ),
                ),
            ] else ...[
              const SizedBox(height: 28),
              const Text(
                'Choose your mood',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: moods.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final mood = moods[index];
                    return AnimatedScale(
                      duration: const Duration(milliseconds: 180),
                      scale: 1,
                      child: GestureDetector(
                        onTap: () => openMood(context, mood.name),
                        child: Container(
                          width: 105,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: mood.color,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                mood.emoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                mood.name,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recommended for You',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (_selectedRecommendationMood != null)
                    TextButton(
                      onPressed: () => _selectRecommendationMood(null),
                      child: const Text('Clear'),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 2,
                children:
                    const [
                      ('😊', 'Happy'),
                      ('😌', 'Chill'),
                      ('❤️', 'Romantic'),
                      ('💔', 'Sad'),
                      ('🔥', 'Energetic'),
                      ('📚', 'Focus'),
                    ].map((mood) {
                      final isSelected = _selectedRecommendationMood == mood.$2;
                      return ChoiceChip(
                        label: Text('${mood.$1} ${mood.$2}'),
                        selected: isSelected,
                        onSelected: (_) => _selectRecommendationMood(
                          isSelected ? null : mood.$2,
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 15),
              if (_isRecommendationsLoading)
                const Center(child: CircularProgressIndicator())
              else if (_recommendationError != null)
                Column(
                  children: [
                    _emptyMessage(_recommendationError!),
                    TextButton(
                      onPressed: _loadRecommendations,
                      child: const Text('Try recommendations again'),
                    ),
                  ],
                )
              else if (_recommendedSongs.isEmpty)
                _emptyMessage(
                  _selectedRecommendationMood == null
                      ? 'No Audius recommendations available right now.'
                      : 'No Audius tracks found for '
                            '$_selectedRecommendationMood right now.',
                )
              else
                ..._recommendedSongs.map(
                  (song) => SongCard(
                    song: song,
                    onTap: () => openSong(context, song),
                    onPlay: () => openSong(context, song, autoPlay: true),
                  ),
                ),
              const SizedBox(height: 14),
              const Text(
                'Recently Played',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (_recentlyPlayedController.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_recentlyPlayedController.error != null)
                _emptyMessage(_recentlyPlayedController.error!)
              else if (_recentlyPlayedController.songs.isEmpty)
                _emptyMessage('No songs played yet.')
              else ...[
                ..._recentlyPlayedController.songs
                    .take(3)
                    .map(
                      (song) => SongCard(
                        song: song,
                        onTap: () => openSong(context, song),
                        onPlay: () => openSong(context, song, autoPlay: true),
                      ),
                    ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const RecentlyPlayedScreen(),
                      ),
                    ),
                    child: const Text('See all'),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Text(
                'Made for your vibe',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              ...allSongs.map(
                (song) => SongCard(
                  song: song,
                  onTap: () => openSong(context, song),
                  onPlay: () => openSong(context, song, autoPlay: true),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _emptyMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF191923),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(child: Text(message, textAlign: TextAlign.center)),
    );
  }
}
