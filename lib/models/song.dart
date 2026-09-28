import 'package:flutter/material.dart';

class Song {
  final String? id;
  final String title;
  final String artist;
  final String album;
  final String? file;
  final String mood;
  final String emoji;
  final String genre;
  final String language;

  const Song({
    this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.file,
    required this.mood,
    this.emoji = '🎵',
    this.genre = '',
    this.language = '',
  });

  String get identifier =>
      file ?? id ?? '${artist.toLowerCase()}:${title.toLowerCase()}';
}

class MoodOption {
  final String name;
  final String emoji;
  final Color color;

  const MoodOption({
    required this.name,
    required this.emoji,
    required this.color,
  });
}
