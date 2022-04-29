class TrackHandler {
  static Track getTrack(Map response) {
    Map recentTrack = response['recenttracks']['track'][0] ??
        response['recenttracks']['track'];

    return Track(
      name: recentTrack['name'],
      album: recentTrack['album']['#text'],
      artist: recentTrack['artist']['#text'],
      playCount: 0,
      cover: recentTrack['image'].last['#text'],
      nowPlaying: recentTrack['@attr'] == null
          ? false
          : recentTrack['@attr']['nowplaying'] == 'true',
    );
  }
}

class Track {
  String artist;
  String album;
  String name;
  int playCount;
  String cover;
  bool nowPlaying;

  Track({
    required this.artist,
    required this.album,
    required this.name,
    required this.playCount,
    required this.cover,
    required this.nowPlaying,
  });
}
