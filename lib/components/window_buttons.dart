import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lfdi/constants.dart';
import 'package:lfdi/main.dart';
import 'package:lfdi/utils/debounce.dart';
import 'package:tray_manager/tray_manager.dart';

class WindowButtons extends ConsumerStatefulWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  ConsumerState<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends ConsumerState<WindowButtons>
    with TrayListener {
  int trayClickCount = 0;

  late final void Function() resetClickCountDebounced;

  @override
  void initState() {
    trayManager.addListener(this);

    resetClickCountDebounced = debounce(
      () => trayClickCount = 0,
      const Duration(milliseconds: 500),
    );

    initTray();

    super.initState();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    appWindow.close();

    super.dispose();
  }

  // Tray functions
  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  // tray functions
  Future<void> initTray() async {
    await trayManager.setIcon(
      Platform.isWindows
          ? 'assets/images/app_icon.ico'
          : 'assets/images/lastfm discord smol.png',
    );
    await Future.delayed(const Duration(milliseconds: 200));
    await trayManager.setContextMenu(trayMenuItems);
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

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'restore_window':
        toggleWindowState();
        break;
      case 'close_window':
        final rpc = ref.read(rpcProvider);
        final gateway = ref.read(discordGatewayProvider);

        if (rpc.started) {
          rpc.dispose();
        }

        if (gateway.started) {
          gateway.dispose();
        }

        trayManager.removeListener(this);
        trayManager.destroy();
        appWindow.close();
        break;
      default:
    }
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

  void onWindowClose() {
    showDialog(
      context: context,
      builder: (_) {
        return ContentDialog(
          title: const Text('Close or minimize to tray'),
          content: const Text(
            'Choose what you want: close the app or minimize it to tray',
          ),
          actions: [
            Button(
              child: const Text('Minimize'),
              onPressed: () {
                Navigator.pop(context);
                appWindow.minimize();
                appWindow.hide();
              },
            ),
            Button(
              child: const Text('Close'),
              onPressed: () {
                Navigator.pop(context);
                appWindow.close();
              },
            ),
            FilledButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = FluentTheme.of(context).brightness;

    final WindowButtonColors colors = WindowButtonColors(
      iconNormal: brightness.isLight ? Colors.black : Colors.white,
    );
    final WindowButtonColors closeButtonColors = WindowButtonColors(
      iconNormal: brightness.isLight ? Colors.black : Colors.white,
      mouseOver: const Color(0xFFc42b1c),
      mouseDown: const Color(0xFFb2271e),
    );

    return Row(
      children: [
        MinimizeWindowButton(colors: colors),
        MaximizeWindowButton(colors: colors),
        CloseWindowButton(
          colors: closeButtonColors,
          onPressed: onWindowClose,
        ),
      ],
    );
  }
}
