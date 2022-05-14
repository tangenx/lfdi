import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        //MaximizeWindowButton(colors: colors),
        CloseWindowButton(
          colors: closeButtonColors,
          onPressed: onWindowClose,
        ),
      ],
    );
  }
}
