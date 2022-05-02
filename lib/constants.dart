import 'package:fluent_ui/fluent_ui.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

// Window and tray
const appTitle = 'Last.fm Discord Integrator';
const windowSize = Size(755, 545);

List<MenuItem> trayMenuItems = [
  MenuItem(
    key: 'restore_window',
    title: 'Hide/Restore',
  ),
  MenuItem.separator,
  MenuItem(
    key: 'close_window',
    title: 'Close LFDI',
  )
];

WindowOptions windowOptions = WindowOptions(
  size: windowSize,
  minimumSize: windowSize,
  center: true,
  skipTaskbar: false,
  titleBarStyle: TitleBarStyle.hidden,
);

// Track
const String defaultCoverURL =
    'https://lastfm.freetls.fastly.net/i/u/64s/4128a6eb29f94943c9d206c08e625904.jpg';

// Colors
const Color discordDarkBackgroundColor = Color(0xFF18191c);
const Color discordLightBackgroundColor = Color(0xFFf2f3f5);

// Gateway constants
// Handlers error codes
const String helloAlreadyRecievedError = 'HELLO_ALREADY_RECIEVED';

// Other
enum RPCAppName {
  someMusic,
  listeningToMusic,
}

const Map<String, RPCAppName> discordAppIdToAppName = {
  defaultDiscordAppID: RPCAppName.listeningToMusic,
  someMusicDiscordAppID: RPCAppName.someMusic
};

const Map<RPCAppName, String> discordAppNameToAppId = {
  RPCAppName.listeningToMusic: defaultDiscordAppID,
  RPCAppName.someMusic: someMusicDiscordAppID,
};

const Map<RPCAppName, String> discordAppEnumToAppName = {
  RPCAppName.listeningToMusic: 'Listening to music',
  RPCAppName.someMusic: 'some music',
};

const String defaultDiscordAppID = '969612309209186354';
const String someMusicDiscordAppID = '970076164947316746';

RegExp winRegExp = RegExp(
  r'^\"(?<winstr>.*)\"\s(?<wincore>[\d]+.[\d])\s\(Build\s(?<winbuild>.*)\)$',
  caseSensitive: true,
);
