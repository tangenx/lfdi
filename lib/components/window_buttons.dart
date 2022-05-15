import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lfdi/functions/show_close_dialog.dart';
import 'package:window_manager/window_manager.dart';

class WindowButtons extends ConsumerStatefulWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  ConsumerState<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends ConsumerState<WindowButtons> {
  @override
  void dispose() {
    appWindow.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = FluentTheme.of(context).brightness;

    return SizedBox(
      height: 32,
      child: Row(
        children: [
          WindowCaptionButton.minimize(
            onPressed: () {
              appWindow.minimize();
            },
            brightness: brightness,
          ),
          WindowCaptionButton.close(
            onPressed: () => showCloseDialog(context),
            brightness: brightness,
          ),
        ],
      ),
    );
  }
}
