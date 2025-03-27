import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

import 'windows/app.dart';
import 'linux/app.dart';
import 'macos/app.dart';

/// Returns the current platform's *App widget.
class Sonora extends StatelessWidget {
  const Sonora({super.key});

  @override
  Widget build(BuildContext context) {
    return switch (defaultTargetPlatform) {
      TargetPlatform.linux => const LinuxSonoraApp(),
      TargetPlatform.macOS => const MacosSonoraApp(),
      // Windows by default I guess
      _ => const WindowsSonoraApp(),
    };
  }
}
