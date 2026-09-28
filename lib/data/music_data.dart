import 'package:flutter/material.dart';

import '../models/song.dart';

const List<Song> allSongs = [
  Song(
    title: 'Sunny Vibes',
    artist: 'VibeTune',
    album: 'Morning Glow',
    file: 'happy.mp3',
    mood: 'Happy',
    emoji: '😊',
    genre: 'Pop',
    language: 'English',
  ),
  Song(
    title: 'Midnight Chill',
    artist: 'VibeTune',
    album: 'Night Drift',
    file: 'chill.mp3',
    mood: 'Chill',
    emoji: '🌙',
    genre: 'Chill pop',
    language: 'English',
  ),
  Song(
    title: 'Power Mode',
    artist: 'VibeTune',
    album: 'Rise Up',
    file: 'energetic.mp3',
    mood: 'Energetic',
    emoji: '⚡',
    genre: 'Electronic pop',
    language: 'English',
  ),
  Song(
    title: 'Love Waves',
    artist: 'VibeTune',
    album: 'Heartline',
    file: 'romantic.mp3',
    mood: 'Romantic',
    emoji: '❤️',
    genre: 'Pop',
    language: 'English',
  ),
  Song(
    title: 'Rainy Feelings',
    artist: 'VibeTune',
    album: 'Soft Storm',
    file: 'sad.mp3',
    mood: 'Sad',
    emoji: '🌧️',
    genre: 'Indie pop',
    language: 'English',
  ),
];

const List<MoodOption> moods = [
  MoodOption(name: 'Happy', emoji: '😊', color: Color(0xFFFFC857)),
  MoodOption(name: 'Chill', emoji: '🌙', color: Color(0xFF6C8CFF)),
  MoodOption(name: 'Energetic', emoji: '⚡', color: Color(0xFFFF6B6B)),
  MoodOption(name: 'Romantic', emoji: '❤️', color: Color(0xFFFF5C8A)),
  MoodOption(name: 'Sad', emoji: '🌧️', color: Color(0xFF7C83FD)),
];

List<Song> songsForMood(String mood) {
  return allSongs.where((song) => song.mood == mood).toList();
}
