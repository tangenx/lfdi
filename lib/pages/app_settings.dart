import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:lfdi/main.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppSettingsPage extends ConsumerStatefulWidget {
  const AppSettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends ConsumerState<AppSettingsPage> {
  final Future<PackageInfo> packageInfo = PackageInfo.fromPlatform();
  bool isLaunchAtStartup = false;
  bool startMinimized = false;
  bool debug = false;
  late bool hideTokens;
  late Box box;

  @override
  void initState() {
    box = Hive.box('lfdi');

    hideTokens = box.get('hideTokens');

    getStartupStatus();
    super.initState();
  }

  Future<void> getStartupStatus() async {
    bool isStartupEnabled = await LaunchAtStartup.instance.isEnabled();
    bool startMinimizedEnabled = box.get('startMinimized');
    bool debug = box.get('debug');

    setState(() {
      isLaunchAtStartup = isStartupEnabled;
      startMinimized = startMinimizedEnabled;
      debug = debug;
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
        const SizedBox(height: 16.0),
        Text(
          'Debug console (will be applied on startup):',
          style: typography.body,
        ),
        const SizedBox(
          height: 10,
        ),
        ToggleSwitch(
          checked: debug,
          content: Text(debug ? 'On' : 'Off'),
          onChanged: (value) {
            box.put('debug', value);
            setState(() => debug = value);
          },
        ),
        const SizedBox(height: 16.0),
        Text(
          'Hide API keys and tokens:',
          style: typography.body,
        ),
        const SizedBox(
          height: 10,
        ),
        ToggleSwitch(
          checked: hideTokens,
          content: Text(hideTokens ? 'Yes' : 'No'),
          onChanged: (value) {
            box.put('hideTokens', value);
            ref.read(hideTokensProvider.notifier).state = value;
            setState(() => hideTokens = value);
          },
        ),
      ],
    );
  }
}
