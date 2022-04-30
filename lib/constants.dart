import 'package:fluent_ui/fluent_ui.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

const appTitle = 'Last.fm Discord Integrator';
const windowSize = Size(755, 545);

List<MenuItem> trayMenuItems = [
  MenuItem(
    key: 'restore_window',
    title: 'Hide/Restore',
  ),
  MenuItem.separator,
  MenuItem(
    key: 'close_window',
    title: 'Close LFDI',
  )
];

WindowOptions windowOptions = WindowOptions(
  size: windowSize,
  minimumSize: windowSize,
  center: true,
  skipTaskbar: false,
  titleBarStyle: TitleBarStyle.hidden,
);
