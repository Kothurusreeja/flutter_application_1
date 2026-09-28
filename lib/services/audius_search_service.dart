import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/song.dart';

class AudiusApiException implements Exception {
  final String message;

  const AudiusApiException(this.message);

  @override
  String toString() => message;
}

class AudiusSearchService {
  static const String _baseUrl = 'https://api.audius.co/v1';
  static const String _appName = 'SingVibesCollegeProject';
  static const Duration _requestTimeout = Duration(seconds: 15);

  final http.Client _client;
  final bool _ownsClient;

  AudiusSearchService({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  Future<List<Song>> searchTracks(String query, {int limit = 20}) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return [];

    final uri = Uri.parse('$_baseUrl/tracks/search').replace(
      queryParameters: {
        'query': normalizedQuery,
        'app_name': _appName,
        'limit': limit.clamp(1, 50).toString(),
      },
    );

    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(_requestTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AudiusApiException(
          'Audius search is unavailable (HTTP ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['data'] is! List) {
        throw const AudiusApiException('Audius returned an invalid response.');
      }

      return (decoded['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(_songFromTrack)
          .whereType<Song>()
          .toList();
    } on TimeoutException {
      throw const AudiusApiException(
        'Audius took too long to respond. Check your connection and try again.',
      );
    } on http.ClientException {
      throw const AudiusApiException(
        'Could not connect to Audius. Check your internet connection.',
      );
    } on FormatException {
      throw const AudiusApiException('Audius returned invalid track data.');
    }
  }

  Uri streamUri(String trackId) {
    return Uri.parse('$_baseUrl/tracks/${Uri.encodeComponent(trackId)}/stream')
        .replace(queryParameters: {'app_name': _appName});
  }

  Song? _songFromTrack(Map<String, dynamic> track) {
    final streamable = track['is_streamable'] == true;
    final access = track['access'];
    final accessAllowsStream = access is! Map || access['stream'] != false;
    if (!streamable ||
        !accessAllowsStream ||
        track['is_stream_gated'] == true ||
        track['is_delete'] == true ||
        track['is_available'] == false) {
      return null;
    }

    final rawTrackId = track['track_id'] ?? track['id'];
    if (rawTrackId == null) return null;
    final trackId = rawTrackId.toString();
    final user = track['user'];
    final artistName = user is Map
        ? (user['name'] ?? user['handle'] ?? 'Audius artist').toString()
        : 'Audius artist';
    final albumBacklink = track['album_backlink'];
    final albumTitle = albumBacklink is Map
        ? (albumBacklink['playlist_name'] ?? '').toString()
        : '';
    final artwork = track['artwork'];
    final artworkUrl = artwork is Map
        ? (artwork['480x480'] ?? artwork['1000x1000'] ?? artwork['150x150'])
              ?.toString()
        : track['cover_art']?.toString();
    final duration = (track['duration'] as num?)?.toInt();

    return Song(
      id: 'audius:$trackId',
      audiusTrackId: trackId,
      title: track['title']?.toString().trim().isNotEmpty == true
          ? track['title'].toString()
          : 'Untitled Audius track',
      artist: artistName,
      album: albumTitle.isEmpty ? 'Audius' : albumTitle,
      artworkUrl: artworkUrl,
      durationSeconds: duration,
      mood: track['mood']?.toString() ?? '',
      genre: track['genre']?.toString() ?? '',
      language: '',
    );
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }

  @visibleForTesting
  void close() {
    dispose();
  }
}
