import 'dart:io';

import 'package:tray_manager/tray_manager.dart';

class TrayManager with TrayListener {
  Future<void> initialize() async {
    trayManager.addListener(this);
    await trayManager.setIcon(
      Platform.isWindows
          ? 'assets/images/app_icon.ico'
          : 'assets/images/lastfm discord smol.png',
    );

    List<MenuItem> items = [
      MenuItem(
        key: 'restore_window',
        title: 'Restore',
      ),
      MenuItem.separator,
      MenuItem(
        key: 'close_window',
        title: 'Close LFDI',
      )
    ];

    await trayManager.setContextMenu(items);
  }
}
