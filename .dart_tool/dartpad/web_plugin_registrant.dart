// Flutter web plugin registrant file.
//
// Generated file. Do not edit.
//

// @dart = 2.13
// ignore_for_file: type=lint

import 'package:system_theme_web/system_theme_web.dart';
import 'package:yaru_window_web/src/web_window.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins([final Registrar? pluginRegistrar]) {
  final Registrar registrar = pluginRegistrar ?? webPluginRegistrar;
  SystemThemeWeb.registerWith(registrar);
  YaruWebWindow.registerWith(registrar);
  registrar.registerMessageHandler();
}
