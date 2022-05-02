import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lfdi/components/discord_status_preview.dart';
import 'package:lfdi/constants.dart';
import 'package:lfdi/handlers/discord_websocket/discord_websocket.dart';
import 'package:lfdi/main.dart';
import 'package:url_launcher/url_launcher.dart';

class DiscordRPCPage extends ConsumerStatefulWidget {
  const DiscordRPCPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DiscordRPCPage> createState() => _DiscordRPCPageState();
}

class _DiscordRPCPageState extends ConsumerState<DiscordRPCPage> {
  RPCAppName? boxValue;
  bool changing = false;

  @override
  Widget build(BuildContext context) {
    final rpc = ref.watch(rpcProvider);
    var box = Hive.box('lfdi');
    final typography = FluentTheme.of(context).typography;

    setState(() {
      boxValue = discordAppIdToAppName[rpc.applicationId];
    });

    return ScaffoldPage(
      header: const PageHeader(
        title: Text('Discord Rich Presence Settings'),
      ),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status preview',
              style: typography.bodyLarge,
            ),
            const SizedBox(
              height: 10,
            ),
            DiscordStatusPreview(
              track: rpc.currentTrack,
              playingText: discordAppEnumToAppName[boxValue]!,
            ),
            const SizedBox(
              height: 10,
            ),
            InfoLabel(
              label: 'Playing text',
              child: Combobox<RPCAppName>(
                placeholder: const Text('Choose a playing text'),
                isExpanded: true,
                items: RPCAppName.values
                    .map((e) => ComboboxItem<RPCAppName>(
                          value: e,
                          child: Text(
                            discordAppEnumToAppName[e]!,
                          ),
                        ))
                    .toList(),
                value: boxValue,
                onChanged: (value) async {
                  if (!changing) {
                    setState(() {
                      changing = true;
                    });

                    if (value != null) {
                      setState(() {
                        boxValue = value;
                      });

                      String changingApplicationId =
                          discordAppNameToAppId[value]!;

                      String? storedApplicationId = box.get('discordAppID');

                      if (storedApplicationId != null &&
                          storedApplicationId == changingApplicationId) {
                        return;
                      }

                      box.put('discordAppID', changingApplicationId);

                      rpc.reinitialize(applicationid: changingApplicationId);

                      showSnackbar(
                        context,
                        const Snackbar(
                          content: Text('Playing text successfully changed'),
                        ),
                      );

                      setState(() {
                        changing = false;
                      });
                    }
                  }
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text(
                  'Set "Listening to" status (seems illegal)',
                  style: typography.bodyLarge,
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
            const SizedBox(
              height: 10,
            ),
            Button(
              child: const Text('Open ws connection'),
              onPressed: () {
                final ws = DiscordWebSoket();
                ws.init();
              },
            ),
          ],
        ),
      ),
    );
  }
}
