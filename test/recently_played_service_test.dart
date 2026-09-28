import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/services/recently_played_service.dart';
import 'package:flutter_application_1/models/song.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('history is newest first, unique, and persistent', () async {
    final service = RecentlyPlayedService();
    final songs = List.generate(
      23,
      (index) => Song(
        id: 'audius:$index',
        audiusTrackId: '$index',
        title: 'Song $index',
        artist: 'Artist',
        album: 'Album',
        mood: '',
      ),
    );
    final songA = songs[0];
    final songB = songs[1];
    final songC = songs[2];

    await service.addRecentlyPlayed(songA);
    await service.addRecentlyPlayed(songB);
    await service.addRecentlyPlayed(songC);
    await service.addRecentlyPlayed(songB);

    final reloaded = await RecentlyPlayedService().getRecentlyPlayed();
    expect(reloaded.take(3).map((song) => song.identifier), [
      songB.identifier,
      songC.identifier,
      songA.identifier,
    ]);
    expect(reloaded.first.title, songB.title);
    expect(reloaded.first.audiusTrackId, songB.audiusTrackId);
    expect(
      reloaded.map((song) => song.identifier).toSet(),
      hasLength(reloaded.length),
    );
  });

  test('history can be removed, cleared, and is limited to 20 songs', () async {
    final service = RecentlyPlayedService();
    final songs = List.generate(
      23,
      (index) => Song(
        id: 'audius:$index',
        audiusTrackId: '$index',
        title: 'Song $index',
        artist: 'Artist',
        album: 'Album',
        mood: '',
      ),
    );
    for (final song in songs.take(23)) {
      await service.addRecentlyPlayed(song);
    }
    expect(await service.getRecentlyPlayed(), hasLength(20));

    await service.removeRecentlyPlayed(songs[22]);
    expect(
      (await service.getRecentlyPlayed()).any(
        (song) => song.identifier == songs[22].identifier,
      ),
      isFalse,
    );

    await service.clearRecentlyPlayed();
    expect(await service.getRecentlyPlayed(), isEmpty);
  });
}
