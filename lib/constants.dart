import 'package:fluent_ui/fluent_ui.dart';
import 'package:tray_manager/tray_manager.dart' as tray;

// Window and tray
const appTitle = 'Last.fm Discord Integrator';
const windowSize = Size(755, 545);

List<tray.MenuItem> trayMenuItems = [
  tray.MenuItem(
    key: 'restore_window',
    label: 'Hide/Restore',
  ),
  tray.MenuItem.separator(),
  tray.MenuItem(
    key: 'close_window',
    label: 'Close LFDI',
  )
];

// Track
const String defaultCoverURL =
    'https://lastfm.freetls.fastly.net/i/u/64s/4128a6eb29f94943c9d206c08e625904.jpg';

RegExp spotifyCoverRegExp = RegExp(
  r'^https:\/\/i.scdn.co\/image\/(?<cover>.*)$',
  caseSensitive: true,
);

// Colors
const Color discordDarkBackgroundColor = Color(0xFF18191c);
const Color discordLightBackgroundColor = Color(0xFFf2f3f5);
const Color discordDarkThemeHeadingColor = Color(0xFFb9bbbe);
const Color discordDarkThemeLowerHeadingColor = Color(0xFFd7d8d9);
const Color discordLightThemeHeadingColor = Color(0xFF4f5660);
const Color discordLightThemeLowerHeadingColor = Color(0xFF2e3338);

Map<String, Color> logTypeToColor = {
  'info': const Color(0xFF5d93ff),
  'warning': const Color(0xFFff6600),
  'error': Colors.red,
  'debug': Colors.white,
};

// Gateway constants
// User-agent
const String userAgent =
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_3_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36';
// Handlers error codes
const String helloAlreadyRecievedError = 'HELLO_ALREADY_RECIEVED';

// Other
// Used for RPC Presence
enum RPCAppName {
  someMusic,
  listeningToMusic,
  music,
}

const Map<String, RPCAppName> discordAppIdToAppName = {
  defaultDiscordAppID: RPCAppName.listeningToMusic,
  someMusicDiscordAppID: RPCAppName.someMusic,
  musicDiscordAppID: RPCAppName.music,
};

const Map<RPCAppName, String> discordAppNameToAppId = {
  RPCAppName.listeningToMusic: defaultDiscordAppID,
  RPCAppName.someMusic: someMusicDiscordAppID,
  RPCAppName.music: musicDiscordAppID,
};

const Map<RPCAppName, String> discordAppEnumToAppName = {
  RPCAppName.listeningToMusic: 'Listening to music',
  RPCAppName.someMusic: 'some music',
  RPCAppName.music: 'music',
};

const String defaultDiscordAppID = '969612309209186354';
const String someMusicDiscordAppID = '970076164947316746';
const String musicDiscordAppID = '974413655649161276';

// Used for Gateway Presence
enum GatewayPresenceType {
  /// `listeningToMusic`:
  ///
  /// LISTENING TO MUSIC
  ///
  /// {track.artist}
  ///
  /// {track.name}
  ///
  /// {track.plays}
  listeningToMusic,

  /// `fullTrackInHeader`:
  ///
  /// LISTENING TO {track.artist} - {track.name}
  ///
  /// {track.album (if exists)}
  ///
  /// {track.plays}
  fullTrackInHeader,

  /// `trackNameInHeader`
  ///
  /// LISTENING TO {track.name}
  ///
  /// {track.artist}
  ///
  /// {track.plays}
  trackNameInHeader,

  /// `musicAppInHeader`
  ///
  /// LISTENING TO {listeningApp}
  ///
  /// {track.artist}
  ///
  /// {track.name}
  ///
  /// {track.plays}
  musicAppInHeader,
}

const Map<GatewayPresenceType, String> presenceTypeToName = {
  GatewayPresenceType.listeningToMusic: 'Listening to music',
  GatewayPresenceType.fullTrackInHeader: 'Full track info in header',
  GatewayPresenceType.trackNameInHeader: 'Track name in header',
  GatewayPresenceType.musicAppInHeader: 'Music app name in header',
};

const Map<String, GatewayPresenceType> stringIdToPresenceType = {
  'listeningToMusic': GatewayPresenceType.listeningToMusic,
  'fullTrackInHeader': GatewayPresenceType.fullTrackInHeader,
  'trackNameInHeader': GatewayPresenceType.trackNameInHeader,
  'musicAppInHeader': GatewayPresenceType.musicAppInHeader,
};

const Map<GatewayPresenceType, String> presenceTypeToStringID = {
  GatewayPresenceType.listeningToMusic: 'listeningToMusic',
  GatewayPresenceType.fullTrackInHeader: 'fullTrackInHeader',
  GatewayPresenceType.trackNameInHeader: 'trackNameInHeader',
  GatewayPresenceType.musicAppInHeader: 'musicAppInHeader',
};

const List<String> musicApps = [
  'Apple Music',
  'Deezer',
  'IDAGIO',
  'Jamendo',
  'Pandora',
  'Qobuz',
  'Spotify',
  'SoundCloud',
  'Tidal',
  'VK Music',
  'Yandex Music',
  'YouTube Music',
  'Zaycev.net',
  'Звук',
  'МТС Music',
];

RegExp winRegExp = RegExp(
  r'^\"(?<winstr>.*)\"\s(?<wincore>[\d]+.[\d])\s\(Build\s(?<winbuild>.*)\)$',
  caseSensitive: true,
);
