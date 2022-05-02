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

  DiscordPresence({
    this.name,
    this.type = 2,
    this.applicationId,
    this.assets,
    this.details,
    this.url,
    this.state,
  });

  Map toMap() {
    return {
      'name': name,
      'type': type,
      'application_id': applicationId,
      'assets': assets?.toMap(),
      'details': details,
      'url': url,
      'state': state,
    };
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
