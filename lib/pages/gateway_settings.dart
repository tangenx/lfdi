import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lfdi/components/discord_form.dart';
import 'package:lfdi/main.dart';
import 'package:url_launcher/url_launcher.dart';

class GatewaySettingsPage extends ConsumerStatefulWidget {
  const GatewaySettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<GatewaySettingsPage> createState() =>
      _GatewaySettingsPageState();
}

class _GatewaySettingsPageState extends ConsumerState<GatewaySettingsPage> {
  var box = Hive.box('lfdi');

  @override
  Widget build(BuildContext context) {
    final typography = FluentTheme.of(context).typography;

    final rpc = ref.watch(rpcProvider);
    final gateway = ref.watch(discordGatewayProvider);

    return ScaffoldPage.scrollable(
      header: const PageHeader(
        title: Text('Discord Gateway Settings'),
      ),
      children: [
        Row(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'These settings allow you\nto set the status to "Listening to" (seems illegal)',
                style: typography.body,
              ),
            ),
            const Spacer(),
            Button(
              child: const Text('Why?'),
              onPressed: () {
                // TODO: write an article about it
                launchUrl(Uri.parse('https://flutter.dev'));
              },
            ),
          ],
        ),
        rpc.initialized && gateway.initialized
            ? Row(
                children: [],
              )
            : const SizedBox(),
        const SizedBox(
          height: 10,
        ),
        const Align(
          alignment: Alignment.centerLeft,
          child: DiscordForm(),
        ),
        const SizedBox(
          height: 10,
        ),
        // await Future.delayed(const Duration(seconds: 1));
        // ws.sendPresence(
        //   presence: DiscordPresence(
        //     name: 'Music',
        //     applicationId: '970447707602833458',
        //     assets: PresenceAssets(
        //       largeImage:
        //           'spotify:ab67616d0000b2738863bc11d2aa12b54f5aeb36',
        //       largeText: 'Binding Lights',
        //       smallImage: '970447707602833458',
        //       smallText: 'github.com/tangenx/lfdi',
        //     ),
        //     details: 'weekend',
        //     state: 'album',
        //     url: 'https://github.com/tangenx/lfdi',
        //   ),
        // );
      ],
    );
  }
}
