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

  /// Stores all listeners
  Map<String, Function> listeners = {};

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
    logger.debug('Triggered init', name: 'RPC');
    if (initialized) {
      return;
    }
    logger.debug('Initializing...', name: 'RPC');

    initialized = true;

    // ignore: unnecessary_this
    rpc = DiscordRPC(applicationId: discordAppId ?? this.applicationId);

    this.username = username;
    this.apiKey = apiKey;
    applicationId = discordAppId ?? defaultDiscordAppID;

    rpc?.start(autoRegister: true);
    logger.info('Initialize complete', name: 'RPC');
  }

  /// Required for changing ApplicationID
  reinitialize({
    required String applicationid,
  }) {
    logger.debug('Triggered reinit', name: 'RPC');
    dispose();

    initialize(
      username: username,
      apiKey: apiKey,
      discordAppId: applicationid,
    );

    start();
    logger.info('Reinit complete', name: 'RPC');
  }

  /// Start the RPC
  start() {
    logger.debug('Triggered start', name: 'RPC');
    if (!initialized || started) {
      return;
    }
    logger.info('Starting..', name: 'RPC');

    timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      logger.info('Start updating track...', name: 'RPC');
      // get info about current scrobbling track
      Map response = API.checkAPI(await API.getRecentTrack(username, apiKey));
      if (response['status'] == 'error') {
        logger.warning('Error getting recent tracks, abort.', name: 'RPC');
        return;
      }

      Track track = TrackHandler.getTrack(response['message']);
      currentTrack = track;
      if (!track.nowPlaying) {
        logger.warning('No playing tracks now, abort.', name: 'RPC');
        rpc?.clearPresence();
        return;
      }

      Map trackInfo = API.checkAPI(
          await API.getTrackInfo(username, apiKey, track.name, track.artist));
      if (trackInfo['status'] == 'error') {
        logger.warning('Error getting track info, abort.', name: 'RPC');
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
      logger.info('Track updated', name: 'RPC');
      if (listeners['onTrackChange'] != null) {
        listeners['onTrackChange']!();
      }
    });

    started = true;
  }

  /// Stop the RPC
  stop() {
    logger.debug('Triggered stop', name: 'RPC');
    if (!started) {
      return;
    }
    logger.info('Stopping...', name: 'RPC');

    started = false;
    rpc?.clearPresence();
    timer.cancel();
  }

  /// Dispose the RPC
  dispose() {
    logger.debug('Triggered dispose', name: 'RPC');
    if (!initialized) {
      return;
    }
    logger.info('Disposing...', name: 'RPC');

    timer.cancel();
    rpc?.updatePresence(DiscordPresence());
    started = false;
    initialized = false;
    rpc?.shutDown();
  }

  /// Set up listeners (must before init)
  void setUpListeners(Map<String, Function> listeners) {
    this.listeners = listeners;
  }

  void addListener({
    required String name,
    required Function listener,
  }) {
    listeners[name] = listener;
  }

  void removeListener({required String listenerName}) {
    listeners.remove(listenerName);
  }

  void removeAllListeners() {
    listeners.clear();
  }
}
