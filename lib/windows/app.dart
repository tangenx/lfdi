import 'package:fluent_ui/fluent_ui.dart';

import '../constants.dart';

class WindowsSonoraApp extends StatelessWidget {
  const WindowsSonoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: appName,
      // TODO: some notifying system for theme changes, maybe own implementation of WatchIt
      // also check https://github.com/bdlukaa/fluent_ui/blob/master/example/lib/main.dart#L91
      // TODO: home:
    );
  }
}
