import 'dart:convert';

import 'package:lfdi/constants.dart';
import 'package:lfdi/handlers/track_handler.dart' as rpc_track;

class DiscordPresence {
  /// App name
  String? name;

  /// Type of activity. Default is 2 (LISTENING)
  int type = 2;

  /// Application ID
  String? applicationId;

  /// Image assets
  PresenceAssets? assets;

  /// First string in detalied view
  String? details;

  /// Url (idk what it's for, it doesn't show up)
  String? url;

  /// Second string in detalied view
  String? state;

  /// Array of buttons (maximum 2)
  List<PresenceButton>? buttons;

  DiscordPresence({
    this.name,
    this.type = 2,
    this.applicationId,
    this.assets,
    this.details,
    this.state,
    this.buttons,
  });

  Map toMap() {
    return {
      'name': name,
      'type': type,
      'application_id': applicationId,
      'assets': assets?.toMap(),
      'details': details,
      'state': state,
      // 'buttons': [
      //   jsonEncode({
      //     'label': 'Open GitHub',
      //     'url': 'https://github.com/',
      //   }),
      // ],
      'instance': true,
    };
  }

  static DiscordPresence generateWithType({
    required GatewayPresenceType type,
    required rpc_track.Track track,
    required String largeImage,
    required String largeText,
    required String musicApp,
    List<PresenceButton>? buttons,
  }) {
    DiscordPresence presence;

    switch (type) {
      case GatewayPresenceType.listeningToMusic:
        presence = DiscordPresence(
          name: 'music',
          applicationId: '970447707602833458',
          assets: PresenceAssets(
            largeImage: largeImage,
            largeText: largeText,
            smallImage: '971195306563747900',
            smallText: 'github.com/tangenx/lfdi',
          ),
          details: track.name,
          state: track.artist,
          buttons: buttons,
        );
        break;

      case GatewayPresenceType.fullTrackInHeader:
        presence = DiscordPresence(
          name: '${track.artist} - ${track.name}',
          applicationId: '970447707602833458',
          assets: PresenceAssets(
            largeImage: largeImage,
            largeText: largeText,
            smallImage: '971195306563747900',
            smallText: 'github.com/tangenx/lfdi',
          ),
          details: track.album,
          buttons: buttons,
        );
        break;

      case GatewayPresenceType.trackNameInHeader:
        presence = DiscordPresence(
          name: track.name,
          applicationId: '970447707602833458',
          assets: PresenceAssets(
            largeImage: largeImage,
            largeText: largeText,
            smallImage: '971195306563747900',
            smallText: 'github.com/tangenx/lfdi',
          ),
          details: track.artist,
          buttons: buttons,
        );
        break;

      case GatewayPresenceType.musicAppInHeader:
        presence = DiscordPresence(
          name: musicApp,
          applicationId: '970447707602833458',
          assets: PresenceAssets(
            largeImage: largeImage,
            largeText: largeText,
            smallImage: '971195306563747900',
            smallText: 'github.com/tangenx/lfdi',
          ),
          details: track.name,
          state: track.artist,
          buttons: buttons,
        );
        break;
    }

    return presence;
  }
}

class PresenceAssets {
  /// Large image id.
  ///
  /// Usually the application's id is used (its avatar is used),
  /// or the application's id:asset.
  /// It is also possible to specify the format string
  /// `spotify:<id_cover_track>`, which we will use.
  String? largeImage;

  /// Large image text.
  ///
  /// For some reason is also displayed
  /// in the third line of the detalied view.
  String? largeText;

  /// Small image id.
  ///
  /// Similarly with the large image.
  String? smallImage;

  /// Small image text.
  String? smallText;

  PresenceAssets({
    this.largeImage,
    this.largeText,
    this.smallImage,
    this.smallText,
  });

  Map toMap() {
    return {
      'large_image': largeImage,
      'large_text': largeText,
      'small_image': smallImage,
      'small_text': smallText,
    };
  }
}

class PresenceButton {
  String? label;
  String? url;

  PresenceButton({
    this.label,
    this.url,
  });

  Map toMap() {
    return {
      'label': label,
      'url': url,
    };
  }
}
