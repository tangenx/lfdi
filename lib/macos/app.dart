import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import '../constants.dart';

class MacosSonoraApp extends StatelessWidget {
  const MacosSonoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      // TODO: some notifying system for theme changes, maybe own implementation of WatchIt (idk if I need it for macos)
      title: appName,
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      themeMode: ThemeMode.system,
      // TODO: home:
    );
  }
}
