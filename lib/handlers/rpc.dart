import 'dart:async';

import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';
import 'package:hive/hive.dart';
import 'package:lfdi/api/api.dart';
import 'package:lfdi/constants.dart';
import 'package:lfdi/globals.dart';
import 'package:lfdi/handlers/track_handler.dart' as rpc_track;
import 'package:spotify/spotify.dart';

class RPC {
  bool initialized = false;
  bool started = false;
  Timer? timer;
  String username = '';
  String apiKey = '';
  String applicationId = defaultDiscordAppID;
  FlutterDiscordRPC? rpc;

  /// Spotify API instance
  SpotifyApi? spotifyApi;

  /// Stores all listeners
  Map<String, Function> listeners = {};

  /// Current track
  rpc_track.Track currentTrack = rpc_track.Track(
    album: 'Test album',
    artist: 'Test artist',
    cover: defaultCoverURL,
    duration: const Duration(seconds: 0),
    name: 'Test name',
    nowPlaying: false,
    playCount: 0,
    createdAt: DateTime.now().millisecondsSinceEpoch,
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

    await FlutterDiscordRPC.initialize(discordAppId ?? applicationId);
    rpc = FlutterDiscordRPC.instance;

    this.username = username;
    this.apiKey = apiKey;
    applicationId = discordAppId ?? defaultDiscordAppID;

    rpc?.connect(autoRetry: true, retryDelay: const Duration(seconds: 10));
    logger.info('Initialize complete', name: 'RPC');
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

      rpc_track.Track track =
          rpc_track.TrackHandler.getTrack(response['message']);
      currentTrack = track;
      if (!track.nowPlaying) {
        logger.warning('No playing tracks now, abort.', name: 'RPC');
        rpc?.clearActivity();
        return;
      }

      Map trackInfo = API.checkAPI(
          await API.getTrackInfo(username, apiKey, track.name, track.artist));
      if (trackInfo['status'] == 'error') {
        logger.warning('Error getting track info, abort.', name: 'RPC');
        return;
      }

      if (trackInfo['message']['track']['userplaycount'] == null) {
        logger.warning('Error getting user\'s track playcount, abort.',
            name: 'RPC');
        return;
      }

      final Track? spotifyTrack =
          spotifyApi != null ? await getCurrentSpotifyTrack() : null;

      // Building track cover from Spotify
      if (spotifyApi != null) {
        String coverId;

        if (spotifyTrack != null) {
          String? trackCoverUrl;

          if (spotifyTrack.album != null) {
            if (spotifyTrack.album!.images != null) {
              trackCoverUrl = spotifyTrack.album!.images!.first.url;
            }
          }

          coverId = trackCoverUrl ?? defaultCoverURL;
        } else {
          coverId = defaultCoverURL;
        }

        currentTrack.cover = coverId;
      }

      // build large image text
      String largeImageText = '';

      track.playCount =
          int.parse(trackInfo['message']['track']['userplaycount']);

      largeImageText += '${track.playCount} plays';

      String trackDuration = trackInfo['message']['track']['duration'] ?? '0';
      int trackDurationMs = int.parse(trackDuration);

      // Get duration from Spotify (why not)
      if (trackDurationMs == 0) {
        if (spotifyTrack != null) {
          logger.info('Last.fm didnt give the duration, look at Spotify...');

          trackDurationMs = spotifyTrack.durationMs ?? 0;
        }
      }

      if (trackDurationMs != 0 && track.playCount > 1) {
        track.duration = Duration(milliseconds: trackDurationMs);
        largeImageText +=
            ' (~${rpc_track.TrackHandler.getTotalListeningTime(track)})';
      }

      // Get duration from Spotify (why not)

      // update rich presence
      rpc?.setActivity(
        activity: RPCActivity(
          activityType: ActivityType.listening,
          assets: RPCAssets(
            largeImage: currentTrack.cover.isEmpty
                ? defaultCoverURL
                : currentTrack.cover,
            largeText: largeImageText,
            smallImage:
                'https://cdn.discordapp.com/app-icons/969612309209186354/9d9a045feac2fa39d2a1598ad2d06e25.png',
            smallText: 'github.com/tangenx/lfdi',
          ),
          buttons: [
            RPCButton(
              label: 'View song',
              url: rpc_track.TrackHandler.makeLastFmUrl(track),
            ),
          ],
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
    rpc?.clearActivity();
    timer?.cancel();
  }

  /// Dispose the RPC
  dispose() {
    logger.debug('Triggered dispose', name: 'RPC');
    if (!initialized) {
      return;
    }
    logger.info('Disposing...', name: 'RPC');

    timer?.cancel();
    rpc?.clearActivity();
    started = false;
    initialized = false;
    rpc?.disconnect();
    rpc?.dispose();
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

  Future<Track?> getCurrentSpotifyTrack() async {
    logger.info('Search track: ${currentTrack.artist} - ${currentTrack.name}');
    logger.info(
      'Search query: ${rpc_track.TrackHandler.removeFeat(currentTrack.artist)} ${currentTrack.name}',
    );
    List<Page<dynamic>> search;

    try {
      search = await spotifyApi!.search
          .get(
            Uri.encodeComponent(
              '${rpc_track.TrackHandler.removeFeat(currentTrack.artist)} ${currentTrack.name}',
            ),
          )
          .first(1);
    } on ExpirationException {
      refreshSpotify();

      search = await spotifyApi!.search
          .get(
            Uri.encodeComponent(
              '${rpc_track.TrackHandler.removeFeat(currentTrack.artist)} ${currentTrack.name}',
            ),
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

    return results.isEmpty ? null : results.first;
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
