import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive/hive.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({Key? key}) : super(key: key);

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  final Future<PackageInfo> packageInfo = PackageInfo.fromPlatform();
  bool isLaunchAtStartup = false;
  bool startMinimized = false;

  @override
  void initState() {
    getStartupStatus();
    super.initState();
  }

  Future<void> getStartupStatus() async {
    bool isStartupEnabled = await LaunchAtStartup.instance.isEnabled();
    bool startMinimizedEnabled = Hive.box('lfdi').get('startMinimized');

    setState(() {
      isLaunchAtStartup = isStartupEnabled;
      startMinimized = startMinimizedEnabled;
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
            PackageInfo packageInfo = await this.packageInfo;

            LaunchAtStartup.instance.setup(
              appName: packageInfo.appName,
              appPath: '"${Platform.resolvedExecutable}"'
                  '${startMinimized ? ' --minimize' : ''}',
            );
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
        if (isLaunchAtStartup) ...[
          const SizedBox(height: 16.0),
          ToggleSwitch(
            checked: startMinimized,
            content: Text(
              startMinimized ? 'Start minimized' : 'Start maximized',
            ),
            onChanged: (value) async {
              PackageInfo packageInfo = await this.packageInfo;

              LaunchAtStartup.instance.setup(
                appName: packageInfo.appName,
                appPath: '"${Platform.resolvedExecutable}"'
                    '${value ? ' --minimize' : ''}',
              );

              await LaunchAtStartup.instance.enable();
              Hive.box('lfdi').put('startMinimized', value);
              setState(() => startMinimized = value);
            },
          ),
        ],
      ],
    );
  }
}
