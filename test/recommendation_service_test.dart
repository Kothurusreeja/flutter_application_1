import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/audius_search_service.dart';
import 'package:flutter_application_1/services/recommendation_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, Object?> _track({
  required String id,
  required String title,
  bool streamable = true,
}) {
  return {
    'id': id,
    'track_id': id,
    'title': title,
    'is_available': true,
    'is_streamable': streamable,
    'is_stream_gated': false,
    'duration': 185,
    'genre': 'Electronic',
    'mood': 'Chill',
    'artwork': {'480x480': 'https://example.test/art.jpg'},
    'user': {'name': 'Audius Artist'},
  };
}

void main() {
  test(
    'Audius search maps actual results and filters unavailable tracks',
    () async {
      Uri? requestedUri;
      Map<String, String>? requestedHeaders;
      final client = MockClient((request) async {
        requestedUri = request.url;
        requestedHeaders = request.headers;
        return http.Response(
          jsonEncode({
            'data': [
              _track(id: '123', title: 'Actual Audius track'),
              _track(id: '456', title: 'Unavailable track', streamable: false),
            ],
          }),
          200,
        );
      });
      final service = AudiusSearchService(client: client);

      final tracks = await service.searchTracks('ambient');

      expect(requestedUri?.path, '/v1/tracks/search');
      expect(requestedUri?.queryParameters['query'], 'ambient');
      expect(
        requestedUri?.queryParameters['app_name'],
        'SingVibesCollegeProject',
      );
      expect(requestedHeaders?.containsKey('Authorization'), isFalse);
      expect(tracks, hasLength(1));
      expect(tracks.single.title, 'Actual Audius track');
      expect(tracks.single.artist, 'Audius Artist');
      expect(tracks.single.durationSeconds, 185);
      expect(tracks.single.artworkUrl, 'https://example.test/art.jpg');
      expect(tracks.single.audiusTrackId, '123');
      expect(service.streamUri('123').path, '/v1/tracks/123/stream');
      expect(service.streamUri('123').queryParameters['app_name'], isNotEmpty);
      client.close();
    },
  );

  test('mood recommendation queries return actual Audius tracks', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/v1/tracks/search');
      return http.Response(
        jsonEncode({
          'data': [_track(id: 'mood-1', title: 'Track returned by Audius')],
        }),
        200,
      );
    });
    final service = AudiusSearchService(client: client);
    final recommendations = RecommendationService(audius: service);

    final tracks = await recommendations.getRecommendationsByMood('Happy');

    expect(tracks.single.title, 'Track returned by Audius');
    expect(tracks.single.isAudiusTrack, isTrue);
    client.close();
  });

  test(
    'Audius non-success responses produce a user-facing API error',
    () async {
      final client = MockClient((_) async => http.Response('unavailable', 503));
      final service = AudiusSearchService(client: client);

      await expectLater(
        service.searchTracks('jazz'),
        throwsA(isA<AudiusApiException>()),
      );
      client.close();
    },
  );
}
