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

    return ScaffoldPage.scrollable(
      header: const PageHeader(
        title: Text('Discord Rich Presence Settings'),
      ),
      children: [
        Text(
          'Status preview',
          style: typography.bodyLarge,
        ),
        const SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: DiscordStatusPreview(
            track: rpc.currentTrack,
            playingText: discordAppEnumToAppName[boxValue]!,
          ),
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

                  String changingApplicationId = discordAppNameToAppId[value]!;

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
      ],
    );
  }
}
