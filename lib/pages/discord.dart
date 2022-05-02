import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lfdi/components/discord_status_preview.dart';
import 'package:lfdi/constants.dart';
import 'package:lfdi/main.dart';

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
              // boxValue == RPCAppName.listeningToMusic
              //     ? 'Listening to music'
              //     : 'some music',
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
                            // e == RPCAppName.listeningToMusic
                            //     ? 'Listening to music'
                            //     : 'some music',
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
                      // switch (value) {
                      //   case RPCAppName.listeningToMusic:
                      //     changingApplicationId = defaultDiscordAppID;
                      //     break;
                      //   case RPCAppName.someMusic:
                      //     changingApplicationId = '970076164947316746';
                      //     break;
                      // }

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
            )
          ],
        ),
      ),
    );
  }
}
