import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:system_theme/system_theme.dart';

ThemeData lightTheme = ThemeData(
  //brightness: Brightness.light,
  accentColor: systemAccentColor,
  visualDensity: VisualDensity.standard,
  focusTheme: FocusThemeData(
    glowFactor: is10footScreen() ? 2.0 : 0.0,
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  micaBackgroundColor: Colors.transparent,
  accentColor: systemAccentColor,
  visualDensity: VisualDensity.standard,
  focusTheme: FocusThemeData(
    glowFactor: is10footScreen() ? 2.0 : 0.0,
  ),
);

AccentColor get systemAccentColor {
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.android ||
      kIsWeb) {
    return AccentColor('normal', {
      'darkest': SystemTheme.accentColor.darkest,
      'darker': SystemTheme.accentColor.darker,
      'dark': SystemTheme.accentColor.dark,
      'normal': SystemTheme.accentColor.accent,
      'light': SystemTheme.accentColor.light,
      'lighter': SystemTheme.accentColor.lighter,
      'lightest': SystemTheme.accentColor.lightest,
    });
  }
  return Colors.blue;
}
