import 'package:flutter/material.dart';

class Song {
  final String? id;
  final String title;
  final String artist;
  final String album;
  final String? file;
  final String? audiusTrackId;
  final String? artworkUrl;
  final int? durationSeconds;
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
    this.audiusTrackId,
    this.artworkUrl,
    this.durationSeconds,
    required this.mood,
    this.emoji = '🎵',
    this.genre = '',
    this.language = '',
  });

  String get identifier =>
      file ?? id ?? '${artist.toLowerCase()}:${title.toLowerCase()}';

  bool get isAudiusTrack => audiusTrackId != null;

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'album': album,
    'file': file,
    'audiusTrackId': audiusTrackId,
    'artworkUrl': artworkUrl,
    'durationSeconds': durationSeconds,
    'mood': mood,
    'emoji': emoji,
    'genre': genre,
    'language': language,
  };

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String?,
      title: json['title'] as String? ?? 'Unknown title',
      artist: json['artist'] as String? ?? 'Unknown artist',
      album: json['album'] as String? ?? '',
      file: json['file'] as String?,
      audiusTrackId: json['audiusTrackId'] as String?,
      artworkUrl: json['artworkUrl'] as String?,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      mood: json['mood'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🎵',
      genre: json['genre'] as String? ?? '',
      language: json['language'] as String? ?? '',
    );
  }

  Song copyWith({String? mood}) {
    return Song(
      id: id,
      title: title,
      artist: artist,
      album: album,
      file: file,
      audiusTrackId: audiusTrackId,
      artworkUrl: artworkUrl,
      durationSeconds: durationSeconds,
      mood: mood ?? this.mood,
      emoji: emoji,
      genre: genre,
      language: language,
    );
  }
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
