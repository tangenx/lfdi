import 'dart:async';

import 'package:hive_flutter/adapters.dart';
import 'package:lfdi/api/api.dart';
import 'package:lfdi/constants.dart';
import 'package:lfdi/globals.dart';
import 'package:lfdi/handlers/discord_websocket/discord_websocket.dart';
import 'package:lfdi/handlers/discord_websocket/gateway_message.dart';
import 'package:lfdi/handlers/discord_websocket/presence_generator.dart';
import 'package:lfdi/handlers/track_handler.dart' as rpc_track;
import 'package:spotify/spotify.dart';
import 'package:oauth2/oauth2.dart';

class DiscordWebSocketManager {
  String discordToken;
  DiscordWebSocketManager({
    required this.discordToken,
  });

  /// Used to check for the use of a websocket
  bool initialized = false;

  /// Used to check if the identity is sent
  bool identifyIsSent = false;

  ///
  bool started = false;

  /// Update Presence timer
  Timer? updatePresenceTimer;

  // Needs for Presence updating
  /// Last.fm username
  String? lastFmUsername;

  /// Last.fm API Key
  String? lastFmApiKey;

  /// Spotify API instance
  SpotifyApi? spotifyApi;

  /// Current Presence type
  GatewayPresenceType? presenceType;

  /// Default music app
  String? defaultMusicApp;

  /// Current track
  rpc_track.Track? currentTrack;

  final DiscordWebSoket ws = DiscordWebSoket();

  /// Init websockets and setup listeners
  void init() {
    logger.i('[DWS: Manager]: Triggered init');
    if (initialized) {
      return;
    }
    logger.i('[DWS: Manager]: Start init');

    ws.addListener(
      name: 'onReconnect_Manager',
      listener: () {
        logger.i('[DWS: Manager onReconnect_Manager] Triggered.');
        if (started) {
          logger.i('[DWS: Manager onReconnect_Manager] Stop updating.');
          stopUpdating();
        }
      },
    );
    ws.addListener(
        name: 'onReconnected_Manager',
        listener: () async {
          logger.i('[DWS: Manager onReconnected_Manager] Triggered.');
          if (initialized) {
            identifyIsSent = false;
            logger.i('[DWS: Manager onReconnected_Manager] Sending identify.');
            await Future.delayed(const Duration(seconds: 1));
            sendIdentify();
            if (spotifyApi != null) {
              var box = Hive.box('lfdi');

              if (box.get('priorUsing') == 'discord') {
                startUpdating();
              }
            }
          }
        });

    // Add listener to dispose manager after websocket closed state.
    ws.addListener(
      name: 'onClose_Manager',
      listener: () {
        logger.i('[DWS: Manager onClose_Manager] Triggered.');
        initialized = false;
        identifyIsSent = false;
        started = false;
        stopUpdating();
      },
    );
    ws.addListener(
        name: 'onReconnectOp7_Manager',
        listener: () {
          logger.i('[DWS: Manager onReconnect_Manager] Triggered.');
          sendIdentify();
          initialized = true;
          started = true;
        });
    ws.init();
    initialized = true;
    logger.i('[DWS: Manager]: Successfully initialized');
  }

  void reinit() {
    logger.i('[DWS: Manager]: Triggered reinit');
    if (!initialized) {
      return;
    }
    logger.i('[DWS: Manager]: Start reinit');

    dispose();

    init();
  }

  /// Start updating Presence
  void startUpdating() {
    logger.i('[DWS: Manager]: Triggered startUpdating');
    if (!initialized || started) {
      return;
    }

    logger.i('[DWS: Manager]: Presence updating started');
    if (!identifyIsSent) {
      sendIdentify();
    }
    updatePresenceTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) async {
        // get info about current scrobbling track
        Map response = API
            .checkAPI(await API.getRecentTrack(lastFmUsername!, lastFmApiKey!));
        if (response['status'] == 'error') {
          logger.w('[DWS: Manager] Error getting recent tracks, abort.');
          return;
        }

        // Get curent scrobbling track
        rpc_track.Track track =
            rpc_track.TrackHandler.getTrack(response['message']);
        currentTrack = track;

        if (!track.nowPlaying) {
          logger.w('[DWS: Manager] No playing tracks now, abort.');
          clearPresence();
          return;
        }

        // Get track info from Last.fm
        Map trackInfo = API.checkAPI(await API.getTrackInfo(
            lastFmUsername!, lastFmApiKey!, track.name, track.artist));
        if (trackInfo['status'] == 'error') {
          logger.w('[DWS: Manager] Error getting track info, abort.');
          return;
        }

        // Building track cover from Spotify
        String coverId;
        logger.i('Search track: ${track.artist} - ${track.name}');
        logger.i(
          'Search query: ${rpc_track.TrackHandler.removeFeat(track.artist)} ${track.name}',
        );
        List<Page<dynamic>> search;

        try {
          search = await spotifyApi!.search
              .get(
                '${rpc_track.TrackHandler.removeFeat(track.artist)} ${track.name}',
              )
              .first(1);
        } on ExpirationException {
          refreshSpotify();

          search = await spotifyApi!.search
              .get(
                '${rpc_track.TrackHandler.removeFeat(track.artist)} ${track.name}',
              )
              .first(1);
        }

        List<Track> results = [];

        if (search.isNotEmpty) {
          List listPages = [];

          for (var pages in search) {
            listPages.add(pages);
          }

          listPages.remove(listPages[4]);

          for (var pages in listPages) {
            if (pages.items != null &&
                pages.items.length != 0 &&
                pages.items!.first != null) {
              for (var item in pages.items!) {
                if (item is Track) {
                  results.add(item);
                }
              }
            }
          }
        }

        // Building large image text
        String largeImageText = '';

        track.playCount =
            int.parse(trackInfo['message']['track']['userplaycount']);
        currentTrack!.playCount =
            int.parse(trackInfo['message']['track']['userplaycount']);

        largeImageText += '${track.playCount} plays';

        String trackDuration = trackInfo['message']['track']['duration'] ?? '0';
        int trackDurationMs = int.parse(trackDuration);

        // Get duration from Spotify (why not)
        if (trackDurationMs == 0) {
          logger.i('Last.fm didnt give the duration, look at Spotify...');
          if (results.isNotEmpty) {
            trackDurationMs = results.first.durationMs ?? 0;
          }
        }

        if (trackDurationMs != 0 && track.playCount > 1) {
          track.duration = Duration(milliseconds: trackDurationMs);
          currentTrack!.duration = Duration(milliseconds: trackDurationMs);
          largeImageText +=
              ' (~${rpc_track.TrackHandler.getTotalListeningTime(track)})';
        }

        logger.i('Music search results length: ${results.length}');

        if (results.isNotEmpty) {
          final spotifyTrack = results.first;
          String? trackUrl;

          if (spotifyTrack.album != null) {
            if (spotifyTrack.album!.images != null) {
              trackUrl = spotifyTrack.album!.images!.first.url;
            }
          }

          if (trackUrl == null) {
            coverId = '971488024401690635';
          } else {
            currentTrack!.cover = trackUrl;
            String? getCoverId =
                rpc_track.TrackHandler.getSpotifyCoverId(trackUrl);
            coverId = getCoverId != null
                ? 'spotify:$getCoverId'
                : '971488024401690635';
          }
        } else {
          coverId = '971488024401690635';
        }

        // Building Presence
        DiscordPresence presence = DiscordPresence.generateWithType(
          type: presenceType!,
          largeImage: coverId,
          largeText: largeImageText,
          track: track,
          musicApp: defaultMusicApp!,
        );

        sendPresence(presence: presence);
        logger.i('[DWS: Manager] Presence updated.');
      },
    );

    started = true;
  }

  void stopUpdating() {
    logger.i('[DWS: Manager] Triggered stopUpdating.');
    started = false;
    updatePresenceTimer?.cancel();
    logger.i(
      '[DWS: Manager] updatePresenceTimer state: ${updatePresenceTimer?.isActive}.',
    );
  }

  void dispose() {
    logger.i('[DWS: Manager]: Triggered dispose');
    ws.dispose();
  }

  /// Sends message to the websocket
  void sendMessage(DiscordGatewayMessage message) {
    ws.sendMessage(message);
  }

  void addListener({
    required String name,
    required Function listener,
  }) {
    ws.addListener(name: name, listener: listener);
  }

  void removeListener({required String listenerName}) {
    ws.removeListener(listenerName: listenerName);
  }

  void sendIdentify() {
    logger.i('[DWS: Manager sendIdentify] Triggered.');
    if (identifyIsSent) {
      logger.w('[DWS: Manager sendIdentify] Identify is sent, aborting.');
      return;
    }

    logger.i('[DWS: Manager sendIdentify] Sending identify.');
    DiscordGatewayMessage message = DiscordGatewayMessage(
      // OP Code 2 - Identify -	used for client handshake
      operationCode: 2,
      data: {
        'token': discordToken,
        'properties': {
          '\$os': 'windows',
          '\$browser': 'discord.js',
          '\$device': 'discord.js',
          '\$referrer': '',
          '\$referring_domain': '',
        },
        'large_threshold': 250,
        'compress': true,
        // this property is taken from discord.js library
        'version': 6,
      },
      eventName: null,
      sequence: null,
    );

    sendMessage(message);
    identifyIsSent = true;
  }

  void sendPresence({required DiscordPresence presence}) {
    DiscordGatewayMessage message = DiscordGatewayMessage(
      operationCode: 3,
      data: {
        'status': 'offline',
        'game': presence.toMap(),
        'afk': false,
        'since': 0,
      },
      eventName: null,
      sequence: null,
    );

    sendMessage(message);
  }

  void clearPresence() {
    DiscordGatewayMessage message = DiscordGatewayMessage(
      operationCode: 3,
      data: {
        'status': 'offline',
        'game': null,
        'afk': false,
        'since': 0,
      },
      eventName: null,
      sequence: null,
    );

    sendMessage(message);
  }

  void refreshSpotify() {
    var box = Hive.box('lfdi');
    final clientId = box.get('spotifyApiKey');
    final clientSecret = box.get('spotifyApiSecret');

    spotifyApi = SpotifyApi(
      SpotifyApiCredentials(
        clientId,
        clientSecret,
      ),
    );
  }
}
