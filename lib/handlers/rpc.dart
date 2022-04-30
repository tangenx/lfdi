import 'dart:async';
import 'dart:developer';

import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:lfdi/api/api.dart';
import 'package:lfdi/constants.dart';
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
    log('Trying init');
    if (initialized) {
      return;
    }
    log('init');

    initialized = true;

    // ignore: unnecessary_this
    rpc = DiscordRPC(applicationId: discordAppId ?? this.applicationId);

    this.username = username;
    this.apiKey = apiKey;
    applicationId = discordAppId ?? defaultDiscordAppID;

    rpc?.start(autoRegister: true);
  }

  /// Required for changing ApplicationID
  reinitialize({
    required String applicationid,
  }) {
    log('reinit');
    dispose();

    initialize(
      username: username,
      apiKey: apiKey,
      discordAppId: applicationid,
    );

    start();
    log('reinit done');
  }

  /// Start the RPC
  start() {
    log('Trying start');
    if (!initialized || started) {
      return;
    }
    log('start');

    timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      log('update track');
      // get info about current scrobbling track
      Map response = API.checkAPI(await API.getRecentTrack(username, apiKey));
      if (response['status'] == 'error') {
        return;
      }

      Track track = TrackHandler.getTrack(response['message']);
      currentTrack = track;
      if (!track.nowPlaying) {
        rpc?.clearPresence();
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
    });

    started = true;
  }

  /// Stop the RPC
  stop() {
    log('Trying stop');
    if (!started) {
      return;
    }
    log('stop');

    started = false;
    timer.cancel();
  }

  /// Dispose the RPC
  dispose() {
    log('Trying dispose');
    if (!initialized) {
      return;
    }
    log('dispose');

    timer.cancel();
    rpc?.updatePresence(DiscordPresence());
    started = false;
    initialized = false;
    rpc?.shutDown();
  }
}
