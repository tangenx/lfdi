import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:lfdi/utils/get_window_effect.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  Future<String> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(
        title: Text('About'),
      ),
      children: [
        FutureBuilder(
          future: getVersion(),
          initialData: '',
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return Row(
                children: [
                  const Image(
                    image: AssetImage('assets/images/lastfm discord smol.png'),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    'LFDI ${snapshot.data}',
                    style: FluentTheme.of(context).typography.subtitle,
                  ),
                ],
              );
            }

            return const SizedBox(
              width: 25,
              height: 25,
              child: ProgressRing(),
            );
          },
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            const Icon(FluentIcons.code),
            const SizedBox(
              width: 15,
            ),
            const Text('Coded by tangenx'),
            const SizedBox(
              width: 15,
            ),
            Button(
              child: const Text('GitHub'),
              onPressed: () {
                launchUrl(
                  Uri.parse('https://github.com/tangenx'),
                );
              },
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            const Icon(FluentIcons.open_source),
            const SizedBox(
              width: 15,
            ),
            const Text('LFDI repository'),
            const SizedBox(
              width: 15,
            ),
            Button(
              child: const Text('Open'),
              onPressed: () {
                launchUrl(
                  Uri.parse('https://github.com/tangenx/lfdi'),
                );
              },
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            const FlutterLogo(size: 18),
            const SizedBox(
              width: 15,
            ),
            const Text('Powered by Flutter 💖'),
            const SizedBox(
              width: 15,
            ),
            Button(
              child: const Text('Site'),
              onPressed: () {
                launchUrl(
                  Uri.parse('https://flutter.dev'),
                );
              },
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Text('Window effect: ${getWindowEffect().toString()}'),
        Text('Windows version: ${Platform.operatingSystemVersion}'),
      ],
    );
  }
}
