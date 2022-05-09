import 'dart:io';

import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:lfdi/utils/extract_windows_info.dart';

/// Get window effect dependent on OS version
WindowEffect getWindowEffect() {
  if (Platform.isWindows) {
    WindowsVersionInfo windowsInfo = extractWindowsInfo();

    // Detect Windows version (10 or 11) by build number (fuck Microsoft)
    if (windowsInfo.build != null) {
      int buildNumber = int.parse(windowsInfo.build!);
      // Windows 10 earlier than 1803
      if (buildNumber < 17134) {
        return WindowEffect.solid;
      }

      // Windows 10 1803 and higher
      if (buildNumber >= 17134 && buildNumber < 22000) {
        return WindowEffect.solid;
      }

      // Windows 11+
      if (buildNumber >= 22000) {
        return WindowEffect.mica;
      }

      return WindowEffect.disabled;
    }

    return WindowEffect.disabled;
  }

  return WindowEffect.disabled;
}

/// Windows window effect dependent on Windows NT version
Map<String, WindowEffect> windowsWindowEffect = {
  /// Windows Vista
  '6.0': WindowEffect.disabled,

  /// Windows 7
  '6.1': WindowEffect.disabled,

  /// Windows 8
  '6.2': WindowEffect.disabled,

  /// Windows 8.1
  '6.3': WindowEffect.disabled,

  /// Windows 10+
  '10.0': WindowEffect.acrylic,
};
