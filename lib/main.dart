import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as acryllic;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:lfdi/constants.dart';
import 'package:lfdi/globals.dart';

import 'package:lfdi/handlers/discord_websocket/websocket_manager.dart';
import 'package:lfdi/pages/home.dart';
import 'package:lfdi/handlers/rpc.dart';
import 'package:lfdi/theme.dart';
import 'package:lfdi/utils/extract_windows_info.dart';
import 'package:lfdi/utils/get_window_effect.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:spotify/spotify.dart';
import 'package:system_theme/system_theme.dart';

final rpcProvider = Provider((ref) => RPC());
final discordGatewayProvider =
    Provider((ref) => DiscordWebSocketManager(discordToken: ''));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  LaunchAtStartup.instance.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
  );

  WindowsVersionInfo windowsInfo = extractWindowsInfo();

  // set up window
  await acryllic.Window.initialize();
  if (windowsInfo.ntVersion != null &&
      double.parse(windowsInfo.ntVersion!) >= 10) {
    acryllic.Window.hideWindowControls();
  }

  // set up Hive
  await Hive.initFlutter();
  await Hive.openBox('lfdi');

  logger.init();

  DiscordRPC.initialize();

  doWhenWindowReady(() async {
    appWindow
      ..minSize = windowSize
      ..size = windowSize
      ..alignment = Alignment.center
      ..title = 'Last.fm Discord Integrator';

    appWindow.show();
  });

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var box = Hive.box('lfdi');

    final username = box.get('username');
    final apiKey = box.get('apiKey');
    final discordApplicationId = box.get('discordAppID');
    final discordToken = box.get('discordToken');
    String? gatewayPresenceType = box.get('gatewayPresenceType');
    String? priorUsing = box.get('priorUsing');

    final spotifyApiKey = box.get('spotifyApiKey');
    final spotifyApiSecret = box.get('spotifyApiSecret');
    String? defaultMusicApp = box.get('defaultMusicApp');

    if (gatewayPresenceType == null) {
      box.put('gatewayPresenceType', 'listeningToMusic');
      gatewayPresenceType = 'listeningToMusic';
    }

    if (defaultMusicApp == null) {
      box.put('defaultMusicApp', 'Spotify');
      defaultMusicApp = 'Spotify';
    }

    if (priorUsing == null) {
      box.put('priorUsing', 'lastfm');
      priorUsing = 'lastfm';
    }

    // Check for Last.fm username & apiKey
    if (username != null && apiKey != null) {
      if (username.isNotEmpty && apiKey.isNotEmpty) {
        // Set up RPC
        RPC rpc = ref.read(rpcProvider);
        rpc.initialize(
          username: username,
          apiKey: apiKey,
          discordAppId: discordApplicationId ?? defaultDiscordAppID,
        );

        if (priorUsing == 'lastfm') {
          rpc.start();
        }

        // Check for Discord token
        if (discordToken != null) {
          if (discordToken.isNotEmpty) {
            // Set up Gateway
            DiscordWebSocketManager webSocketManager =
                ref.read(discordGatewayProvider);
            webSocketManager.discordToken = discordToken;
            webSocketManager.lastFmApiKey = apiKey;
            webSocketManager.lastFmUsername = username;
            webSocketManager.presenceType =
                stringIdToPresenceType[box.get('gatewayPresenceType')];
            webSocketManager.defaultMusicApp = box.get('defaultMusicApp');

            webSocketManager.init();

            // Check for Spotify dev app
            if (spotifyApiKey != null && spotifyApiSecret != null) {
              webSocketManager.spotifyApi = SpotifyApi(
                SpotifyApiCredentials(
                  spotifyApiKey,
                  spotifyApiSecret,
                ),
              );

              if (priorUsing == 'discord') {
                webSocketManager.startUpdating();
              }
            }
          }
        }
      }
    }

    final isDarkMode = SystemTheme.isDarkMode;
    acryllic.WindowEffect windowEffect = getWindowEffect();

    acryllic.Window.setEffect(
      effect: windowEffect,
      color: Platform.isWindows
          ? isDarkMode
              ? const Color(0xCC222222)
              : const Color(0xCCDDDDDD)
          : Colors.transparent,
      dark: isDarkMode,
    );

    return FluentApp(
      title: 'Last.fm Discord Integrator',
      themeMode: ThemeMode.system,
      color: systemAccentColor,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const HomePage(),
    );
  }
}
