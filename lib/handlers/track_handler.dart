import 'package:lfdi/constants.dart';

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
      duration: const Duration(seconds: 0),
    );
  }

  static String getTotalListeningTime(Track track) {
    Duration trackDuration = track.duration * track.playCount;

    int hours = trackDuration.inHours;
    int minutes = trackDuration.inMinutes.remainder(60);
    int seconds = trackDuration.inSeconds.remainder(60);

    String listeningTime = '';
    if (hours != 0) {
      listeningTime += '${hours}h';
    }

    if (minutes != 0) {
      listeningTime += '${minutes}m';
    }

    if (seconds != 0) {
      listeningTime += '${seconds}s';
    }

    return listeningTime;
  }

  static String? getSpotifyCoverId(String coverURL) {
    RegExpMatch coverRegExpMatch =
        spotifyCoverRegExp.allMatches(coverURL).first;

    return coverRegExpMatch.namedGroup('cover');
  }

  static String removeFeat(String trackName) {
    return trackName.replaceAll('feat.', '').replaceAll(' & ', ' ');
  }
}

class Track {
  String artist;
  String album;
  String name;
  int playCount;
  String cover;
  bool nowPlaying;
  Duration duration;

  Track({
    required this.artist,
    required this.album,
    required this.name,
    required this.playCount,
    required this.cover,
    required this.nowPlaying,
    required this.duration,
  });
}
