import 'dart:async';
import 'dart:developer';

import 'package:lfdi/api/api.dart';
import 'package:lfdi/constants.dart';
import 'package:lfdi/handlers/discord_websocket/discord_websocket.dart';
import 'package:lfdi/handlers/discord_websocket/gateway_message.dart';
import 'package:lfdi/handlers/discord_websocket/presence_generator.dart';
import 'package:lfdi/handlers/track_handler.dart' as rpc_track;
import 'package:spotify/spotify.dart';

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

  /// Current track
  rpc_track.Track? currentTrack;

  final DiscordWebSoket ws = DiscordWebSoket();

  /// Init websockets and setup listeners
  void init() {
    log('[DWS: Manager]: Triggered init');
    if (initialized) {
      return;
    }
    log('[DWS: Manager]: Start init');
    // Add listener to dispose manager after websocket closed state.
    ws.addListener(
      name: 'onClose_Manager',
      listener: () {
        if (identifyIsSent) {
          clearPresence();
        }

        initialized = false;
        identifyIsSent = false;
        started = false;
        stopUpdating();
      },
    );
    ws.addListener(
        name: 'onReconnect_Manager',
        listener: () {
          sendIdentify();
        });
    ws.init();
    initialized = true;
    log('[DWS: Manager]: Successfully initialized');
  }

  void reinit() {
    log('[DWS: Manager]: Triggered reinit');
    if (!initialized) {
      return;
    }
    log('[DWS: Manager]: Start reinit');

    dispose();

    init();
  }

  /// Start updating Presence
  void startUpdating() {
    log('[DWS: Manager]: Triggered startUpdating');
    if (!initialized || started) {
      return;
    }

    log('[DWS: Manager]: Presence updating started');
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
          log('[DWS: Manager] Error getting recent tracks, abort.');
          return;
        }

        // Get curent scrobbling track
        rpc_track.Track track =
            rpc_track.TrackHandler.getTrack(response['message']);
        currentTrack = track;

        if (!track.nowPlaying) {
          log('[DWS: Manager] No playing tracks now, abort.');
          clearPresence();
          return;
        }

        // Get track info from Last.fm
        Map trackInfo = API.checkAPI(await API.getTrackInfo(
            lastFmUsername!, lastFmApiKey!, track.name, track.artist));
        if (trackInfo['status'] == 'error') {
          log('[DWS: Manager] Error getting track info, abort.');
          return;
        }

        // Building track cover from Spotify
        String coverId;
        log('Search track: ${track.artist} - ${track.name}');
        log('Search query: ${rpc_track.TrackHandler.removeFeat(track.artist)} ${track.name}');
        final search = await spotifyApi!.search
            .get(
              '${rpc_track.TrackHandler.removeFeat(track.artist)} ${track.name}',
            )
            .first(1);
        List<Track> results = [];

        if (search.isNotEmpty) {
          List listPages = [];

          for (var pages in search) {
            listPages.add(pages);
          }

          listPages.remove(listPages[4]);

          for (var pages in listPages) {
            for (var item in pages.items!) {
              if (item is Track) {
                results.add(item);
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
          log('Last.fm didnt give the duration, look at Spotify...');
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

        log('Music search results length: ${results.length}');

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
        );

        sendPresence(presence: presence);
        log('[DWS: Manager] Presence updated.');
      },
    );

    started = true;
  }

  void stopUpdating() {
    log('[DWS: Manager] Triggered stopUpdating.');
    started = false;
    clearPresence();
    updatePresenceTimer?.cancel();
    log('[DWS: Manager] updatePresenceTimer state: ${updatePresenceTimer?.isActive}.');
  }

  void dispose() {
    log('[DWS: Manager]: Triggered dispose');
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
    if (identifyIsSent) {
      return;
    }

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
}
