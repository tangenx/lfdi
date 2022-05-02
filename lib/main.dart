import 'dart:developer';

import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as acryllic;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lfdi/constants.dart';
import 'package:lfdi/pages/home.dart';
import 'package:lfdi/handlers/rpc.dart';
import 'package:lfdi/theme.dart';
import 'package:lfdi/utils/get_window_effect.dart';
import 'package:window_manager/window_manager.dart';

final rpcProvider = Provider((ref) => RPC());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // set up window
  await acryllic.Window.initialize();
  await WindowManager.instance.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('lfdi');

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    acryllic.WindowEffect windowEffect = getWindowEffect();

    await acryllic.Window.setEffect(
      effect: windowEffect,
    );
    await windowManager.setPreventClose(true);

    await windowManager.show();
    await windowManager.focus();
  });

  DiscordRPC.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var box = Hive.box('lfdi');

    String? username = box.get('username');
    String? apiKey = box.get('apiKey');
    String? discordApplicationId = box.get('discordAppID');

    log('check for username and apiKey');
    log('username is $username\napiKey is $apiKey');
    if (username != null && apiKey != null) {
      if (username.isNotEmpty && apiKey.isNotEmpty) {
        RPC rpc = ref.read(rpcProvider);
        rpc.initialize(
          username: username,
          apiKey: apiKey,
          discordAppId: discordApplicationId ?? defaultDiscordAppID,
        );

        rpc.start();
      }
    }

    log('build app');
    return FluentApp(
      title: 'Last.fm Discord Integrator',
      themeMode: ThemeMode.system,
      color: systemAccentColor,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const HomePage(),
    );

    // final prefs = ref.watch(prefsProvider);

    // return prefs.when(
    //   loading: () => FluentApp(
    //     title: 'Last.fm Discord Integrator',
    //     themeMode: ThemeMode.system,
    //     color: systemAccentColor,
    //     theme: lightTheme,
    //     darkTheme: darkTheme,
    //     home: const Center(
    //       child: SizedBox(
    //         width: 40,
    //         height: 40,
    //         child: ProgressRing(),
    //       ),
    //     ),
    //   ),
    //   error: (error, stack) => Text('Error: $error'),
    //   data: (prefs) {
    //     final username = prefs.getString('username');
    //     final apiKey = prefs.getString('apiKey');

    //     if (username != null &&
    //         apiKey != null &&
    //         username.isNotEmpty &&
    //         apiKey.isNotEmpty &&
    //         apiKey.length == 32) {
    //       RPC rpc = ref.read(rpcProvider);
    //       rpc.initialize(
    //         username: username,
    //         apiKey: apiKey,
    //         discordAppId:
    //             prefs.getString('discordAppID') ?? defaultDiscordAppID,
    //       );
    //       rpc.start();
    //     }

    //     return FluentApp(
    //       title: 'Last.fm Discord Integrator',
    //       themeMode: ThemeMode.system,
    //       color: systemAccentColor,
    //       theme: lightTheme,
    //       darkTheme: darkTheme,
    //       home: const HomePage(),
    //     );
    //   },
    // );
  }
}
