import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../constants.dart';

class LinuxSonoraApp extends StatelessWidget {
  const LinuxSonoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      // TODO: some notifying system for theme changes, maybe own implementation of WatchIt
      // check https://github.com/ubuntu/yaru.dart/blob/main/example/lib/example_model.dart
      builder: (context, yaru, child) => MaterialApp(
        title: appName,
        themeMode: ThemeMode.system,
        theme: yaruLight,
        darkTheme: yaruDark,
        highContrastTheme: yaruHighContrastLight,
        highContrastDarkTheme: yaruHighContrastDark,
        // TODO: home:
      ),
    );
  }
}
