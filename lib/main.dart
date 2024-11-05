import 'dart:io';

import 'package:flutter/material.dart' hide Colors;
import 'package:flutter_acrylic/flutter_acrylic.dart' as acrylic;
import 'package:macos_ui/macos_ui.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru/yaru.dart';

import 'core/constants/app_constants.dart';
import 'core/utils/extract_windows_info.dart';
import 'core/utils/get_window_effect.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await acrylic.Window.initialize();

  if (Platform.isLinux) {
    await YaruWindowTitleBar.ensureInitialized();

    windowManager.setPreventClose(true);
  }

  if (Platform.isWindows) {
    WindowsVersionInfo windowsInfo = extractWindowsInfo();

    if (windowsInfo.ntVersion != null) {
      double version = double.parse(windowsInfo.ntVersion!);
      if (version >= 10) {
        acrylic.Window.hideWindowControls();
      } else {
        windowManager.setPreventClose(true);
      }
    }
  }

  if (Platform.isMacOS) {
    windowManager.setPreventClose(true);
  }

  windowManager.setResizable(false);

  WindowOptions windowOptions = const WindowOptions(
    size: windowSize,
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    // titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    acrylic.WindowEffect windowEffect = getWindowEffect();

    acrylic.Window.setEffect(
      effect: windowEffect,
      color: Platform.isWindows
          ? isDarkMode
              ? const Color(0xCC222222)
              : const Color(0xCCDDDDDD)
          : Colors.transparent,
      dark: isDarkMode,
    );

    return switch (Platform.operatingSystem) {
      'macos' => MacosApp(
          theme: MacosThemeData.light(),
          darkTheme: MacosThemeData.dark(),
          themeMode: ThemeMode.system,
        ),
      'linux' => YaruTheme(
          builder: (context, yaru, child) => MaterialApp(
            theme: yaru.theme,
            darkTheme: yaru.darkTheme,
          ),
        ),
      String() => FluentApp(
          theme: FluentThemeData.light().copyWith(
            accentColor: SystemTheme.accentColor.accent.toAccentColor(),
          ),
          darkTheme: FluentThemeData.dark().copyWith(
            accentColor: SystemTheme.accentColor.accent.toAccentColor(),
          ),
          themeMode: ThemeMode.system,
        ),
    };
  }
}
