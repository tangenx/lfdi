import 'package:fluent_ui/fluent_ui.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({Key? key}) : super(key: key);

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  bool isLaunchAtStartup = false;

  @override
  void initState() {
    getStartupStatus();
    super.initState();
  }

  Future<void> getStartupStatus() async {
    bool isStartupEnabled = await LaunchAtStartup.instance.isEnabled();

    setState(() {
      isLaunchAtStartup = isStartupEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final typography = FluentTheme.of(context).typography;

    return ScaffoldPage.scrollable(
      header: const PageHeader(
        title: Text('LFDI Settings'),
      ),
      children: [
        Text(
          'Run at startup:',
          style: typography.body,
        ),
        const SizedBox(
          height: 10,
        ),
        ToggleSwitch(
          checked: isLaunchAtStartup,
          content: Text(
            isLaunchAtStartup ? 'Enabled' : 'Disabled',
          ),
          onChanged: (value) async {
            if (value) {
              await LaunchAtStartup.instance.enable();

              setState(() {
                isLaunchAtStartup = true;
              });

              return;
            }

            await LaunchAtStartup.instance.disable();

            setState(() {
              isLaunchAtStartup = false;
            });
          },
        ),
      ],
    );
  }
}
