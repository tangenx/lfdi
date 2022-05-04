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
  GatewayPresenceType? currentGatewayPresenceType;
  bool changing = false;

  @override
  Widget build(BuildContext context) {
    final rpc = ref.watch(rpcProvider);
    final gateway = ref.watch(discordGatewayProvider);
    var box = Hive.box('lfdi');
    final typography = FluentTheme.of(context).typography;

    setState(() {
      boxValue = discordAppIdToAppName[rpc.applicationId];
      currentGatewayPresenceType = gateway.presenceType;
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
        const Align(
          alignment: Alignment.centerLeft,
          child: DiscordStatusPreview(),
        ),
        const SizedBox(
          height: 10,
        ),
        box.get('priorUsing') == 'lastfm'
            ? InfoLabel(
                label: '"Playing to" text',
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
                          setState(() {
                            changing = false;
                          });
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
            : InfoLabel(
                label: 'Presence style',
                child: Combobox<GatewayPresenceType>(
                  placeholder: const Text('Choose a Presence style'),
                  isExpanded: true,
                  items: GatewayPresenceType.values
                      .map((e) => ComboboxItem<GatewayPresenceType>(
                            value: e,
                            child: Text(
                              presenceTypeToName[e]!,
                            ),
                          ))
                      .toList(),
                  value: currentGatewayPresenceType,
                  onChanged: (value) {
                    if (changing) {
                      return;
                    }

                    setState(() {
                      changing = true;
                    });

                    if (value != null) {
                      setState(() {
                        currentGatewayPresenceType = value;
                      });
                    }

                    GatewayPresenceType? presenceType = value;

                    String changingPresenceType =
                        presenceTypeToStringID[presenceType]!;

                    String storedPresenceType = box.get('gatewayPresenceType');

                    if (storedPresenceType == changingPresenceType) {
                      setState(() {
                        changing = false;
                      });
                      return;
                    }

                    box.put('gatewayPresenceType', changingPresenceType);

                    if (gateway.started) {
                      gateway.stopUpdating();
                    }

                    gateway.presenceType = presenceType;

                    gateway.startUpdating();

                    showSnackbar(
                      context,
                      const Snackbar(
                        content: Text('Presence style successfully changed'),
                      ),
                    );

                    setState(() {
                      changing = false;
                    });
                  },
                ),
              ),
      ],
    );
  }
}
