import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:lfdi/constants.dart';
import 'package:lfdi/main.dart';
import 'package:lfdi/utils/debounce.dart';
import 'package:tray_manager/tray_manager.dart';

class Tray with TrayListener {
  int trayClickCount = 0;

  late final void Function() resetClickCountDebounced;

  Future<void> init() async {
    trayManager.addListener(this);

    resetClickCountDebounced = debounce(
      () => trayClickCount = 0,
      const Duration(milliseconds: 500),
    );

    await trayManager.setIcon(
      Platform.isWindows
          ? 'assets/images/app_icon.ico'
          : 'assets/images/lastfm discord smol.png',
    );

    await Future.delayed(const Duration(milliseconds: 200));
    await trayManager.setContextMenu(Menu(items: trayMenuItems));
    if (runMinimized) {
      await Future.delayed(const Duration(seconds: 1));
      appWindow.minimize();
      appWindow.hide();
    }
  }

  void toggleWindowState() {
    bool isVisible = appWindow.isVisible;
    if (isVisible) {
      appWindow.minimize();
      return appWindow.hide();
    }

    appWindow.restore();
    appWindow.show();
  }

  // Tray functions
  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconMouseDown() {
    trayClickCount++;
    resetClickCountDebounced();

    if (trayClickCount == 2) {
      toggleWindowState();

      trayClickCount = 0;
    }
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'restore_window':
        toggleWindowState();
        break;
      case 'close_window':
        // final rpc = ref.read(rpcProvider);
        // final gateway = ref.read(discordGatewayProvider);

        // if (rpc.started) {
        //   rpc.dispose();
        // }

        // if (gateway.started) {
        //   gateway.dispose();
        // }

        trayManager.removeListener(this);
        trayManager.destroy();
        appWindow.close();
        break;
    }
  }
}
