import 'dart:async';

import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:lfdi/api/api.dart';
import 'package:lfdi/handlers/track_handler.dart';

final GlobalKey<SnackbarState> scaffoldKey = GlobalKey<SnackbarState>();

class RPC {
  RPC();

  final DiscordRPC rpc = DiscordRPC(applicationId: '969612309209186354');
  bool initialized = false;
  bool started = false;
  late Timer timer;
  late String username;
  late String apiKey;

  initialize({
    required String username,
    required String apiKey,
  }) async {
    if (initialized) {
      return;
    }

    initialized = true;

    this.username = username;
    this.apiKey = apiKey;

    rpc.start(autoRegister: true);
  }

  start() {
    if (!initialized || started) {
      return;
    }

    timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      // get info about current scrobbling track
      Map response = API.checkAPI(await API.getRecentTrack(username, apiKey));
      if (response['status'] == 'error') {
        return;
      }

      Track track = TrackHandler.getTrack(response['message']);
      if (!track.nowPlaying) {
        return;
      }

      Map trackInfo = API.checkAPI(
          await API.getTrackInfo(username, apiKey, track.name, track.artist));
      if (trackInfo['status'] == 'error') {
        return;
      }

      // build large image text
      String largeImageText = '';

      track.playCount =
          int.parse(trackInfo['message']['track']['userplaycount']);

      largeImageText += '${track.playCount} plays';

      String trackDuration = trackInfo['message']['track']['duration'] ?? '0';
      int trackDurationMs = int.parse(trackDuration);

      if (trackDurationMs != 0 && track.playCount > 1) {
        track.duration = Duration(milliseconds: trackDurationMs);
        largeImageText += ' (~${TrackHandler.getTotalListeningTime(track)})';
      }

      // update rich presence
      rpc.updatePresence(
        DiscordPresence(
          largeImageKey: track.cover,
          largeImageText: largeImageText,
          smallImageKey:
              'https://cdn.discordapp.com/app-icons/969612309209186354/9d9a045feac2fa39d2a1598ad2d06e25.png',
          smallImageText: 'github.com/tangenx/lfdi',
          details: track.name,
          state: track.artist,
        ),
      );
    });

    started = true;
  }

  stop() {
    if (!started) {
      return;
    }

    started = false;
    timer.cancel();
  }

  dispose() {
    if (!initialized) {
      return;
    }

    timer.cancel();
    rpc.updatePresence(DiscordPresence());
    started = false;
    initialized = false;
    rpc.shutDown();
  }
}
