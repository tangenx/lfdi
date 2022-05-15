import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

void showCloseDialog(BuildContext context, {Function? resetAltF4Counter}) {
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
              if (resetAltF4Counter != null) {
                resetAltF4Counter();
              }

              Navigator.pop(context);
              appWindow.minimize();
              appWindow.hide();
            },
          ),
          Button(
            child: const Text('Close'),
            onPressed: () async {
              Navigator.pop(context);
              windowManager.destroy();
            },
          ),
          FilledButton(
            child: const Text('Cancel'),
            onPressed: () {
              if (resetAltF4Counter != null) {
                resetAltF4Counter();
              }

              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}
