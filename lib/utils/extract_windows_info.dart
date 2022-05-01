import 'dart:io';

import 'package:lfdi/constants.dart';

/// Extract Windows version info from `Platform.operatingSystemVersion`
WindowsVersionInfo extractWindowsInfo() {
  final windowsString = Platform.operatingSystemVersion;

  RegExpMatch match = winRegExp.allMatches(windowsString).first;

  WindowsVersionInfo winverInfo = WindowsVersionInfo(
    build: match.namedGroup('winbuild'),
    name: match.namedGroup('winstr'),
    ntVersion: match.namedGroup('wincore'),
  );

  return winverInfo;
}

class WindowsVersionInfo {
  final String? name;
  final String? ntVersion;
  final String? build;

  WindowsVersionInfo({
    required this.name,
    required this.ntVersion,
    required this.build,
  });
}
