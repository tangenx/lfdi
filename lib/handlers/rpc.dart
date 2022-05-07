import 'dart:async';

import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:lfdi/api/api.dart';
import 'package:lfdi/constants.dart';
import 'package:lfdi/globals.dart';
import 'package:lfdi/handlers/track_handler.dart';

final GlobalKey<SnackbarState> scaffoldKey = GlobalKey<SnackbarState>();

class RPC {
  bool initialized = false;
  bool started = false;
  late Timer timer;
  String username = '';
  String apiKey = '';
  String applicationId = defaultDiscordAppID;
  DiscordRPC? rpc;

  Track currentTrack = Track(
    album: 'Test album',
    artist: 'Test artist',
    cover: defaultCoverURL,
    duration: const Duration(seconds: 0),
    name: 'Test name',
    nowPlaying: false,
    playCount: 0,
  );

  RPC({applicationID});

  /// Initialize the RPC
  initialize({
    required String username,
    required String apiKey,
    String? discordAppId,
  }) async {
    logger.i('[RPC] trying init');
    if (initialized) {
      return;
    }
    logger.i('[RPC] initializing...');

    initialized = true;

    // ignore: unnecessary_this
    rpc = DiscordRPC(applicationId: discordAppId ?? this.applicationId);

    this.username = username;
    this.apiKey = apiKey;
    applicationId = discordAppId ?? defaultDiscordAppID;

    rpc?.start(autoRegister: true);
    logger.i('[RPC] initialize complete.');
  }

  /// Required for changing ApplicationID
  reinitialize({
    required String applicationid,
  }) {
    logger.i('[RPC] re-initializing...');
    dispose();

    initialize(
      username: username,
      apiKey: apiKey,
      discordAppId: applicationid,
    );

    start();
    logger.i('[RPC] re-init complete.');
  }

  /// Start the RPC
  start() {
    logger.i('[RPC] trying start');
    if (!initialized || started) {
      return;
    }
    logger.i('[RPC] starting..');

    timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      logger.i('[RPC] start updating track...');
      // get info about current scrobbling track
      Map response = API.checkAPI(await API.getRecentTrack(username, apiKey));
      if (response['status'] == 'error') {
        logger.w('[RPC] error getting recent tracks, abort.');
        return;
      }

      Track track = TrackHandler.getTrack(response['message']);
      currentTrack = track;
      if (!track.nowPlaying) {
        logger.w('[RPC] no playing tracks now, abort.');
        rpc?.clearPresence();
        return;
      }

      Map trackInfo = API.checkAPI(
          await API.getTrackInfo(username, apiKey, track.name, track.artist));
      if (trackInfo['status'] == 'error') {
        logger.w('[RPC] error getting track info, abort.');
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
      rpc?.updatePresence(
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
      logger.i('[RPC] track updated.');
    });

    started = true;
  }

  /// Stop the RPC
  stop() {
    logger.i('[RPC] trying stop');
    if (!started) {
      return;
    }
    logger.i('[RPC] stopping...');

    started = false;
    rpc?.clearPresence();
    timer.cancel();
  }

  /// Dispose the RPC
  dispose() {
    logger.i('[RPC] trying dispose');
    if (!initialized) {
      return;
    }
    logger.i('[RPC] disposing...');

    timer.cancel();
    rpc?.updatePresence(DiscordPresence());
    started = false;
    initialized = false;
    rpc?.shutDown();
  }
}
