import 'dart:developer';

import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as acryllic;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lfdi/constants.dart';
import 'package:lfdi/pages/home.dart';
import 'package:lfdi/handlers/rpc.dart';
import 'package:lfdi/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

final prefsProvider = FutureProvider((ref) => SharedPreferences.getInstance());
final rpcProvider = Provider((ref) => RPC());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // set up window
  await acryllic.Window.initialize();
  await WindowManager.instance.ensureInitialized();

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await acryllic.Window.setEffect(
      effect: acryllic.WindowEffect.mica,
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
    final prefs = ref.watch(prefsProvider);

    return prefs.when(
      loading: () => FluentApp(
        title: 'Last.fm Discord Integrator',
        themeMode: ThemeMode.system,
        color: systemAccentColor,
        theme: lightTheme,
        darkTheme: darkTheme,
        home: const Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: ProgressRing(),
          ),
        ),
      ),
      error: (error, stack) => Text('Error: $error'),
      data: (prefs) {
        final username = prefs.getString('username');
        final apiKey = prefs.getString('apiKey');

        log('prefs discordAppID: ${prefs.getString('discordAppID')}');

        if (username != null &&
            apiKey != null &&
            username.isNotEmpty &&
            apiKey.isNotEmpty &&
            apiKey.length == 32) {
          RPC rpc = ref.read(rpcProvider);
          rpc.initialize(
            username: username,
            apiKey: apiKey,
            discordAppId:
                prefs.getString('discordAppID') ?? defaultDiscordAppID,
          );
          rpc.start();
        }

        return FluentApp(
          title: 'Last.fm Discord Integrator',
          themeMode: ThemeMode.system,
          color: systemAccentColor,
          theme: lightTheme,
          darkTheme: darkTheme,
          home: const HomePage(),
        );
      },
    );
  }
}
