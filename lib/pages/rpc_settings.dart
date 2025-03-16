import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lfdi/components/discord_status_preview.dart';
import 'package:lfdi/constants.dart';
import 'package:lfdi/handlers/discord_websocket/websocket_manager.dart';
import 'package:lfdi/handlers/rpc.dart';
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
  String? currentMusicApp;
  var box = Hive.box('lfdi');
  RPC? rpc;
  DiscordWebSocketManager? gateway;

  @override
  void initState() {
    rpc = ref.read(rpcProvider);
    gateway = ref.read(discordGatewayProvider);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final typography = FluentTheme.of(context).typography;

    setState(() {
      boxValue = discordAppIdToAppName[rpc!.applicationId];
      currentGatewayPresenceType = gateway!.presenceType;
      currentMusicApp = gateway!.defaultMusicApp;
    });

    if (rpc!.initialized || gateway!.initialized) {
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
                  label: '"Listening to" text',
                  child: ComboBox<RPCAppName>(
                    placeholder: const Text('Choose a playing text'),
                    isExpanded: true,
                    items: RPCAppName.values
                        .map((e) => ComboBoxItem<RPCAppName>(
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

                          displayInfoBar(
                            context,
                            builder: (context, close) => const InfoBar(
                              title: Text(
                                'Playing text successfully changed',
                              ),
                              severity: InfoBarSeverity.success,
                            ),
                          );

                          if (rpc?.listeners['onTrackChange'] != null) {
                            rpc?.listeners['onTrackChange']!();
                          }

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
                  child: ComboBox<GatewayPresenceType>(
                    placeholder: const Text('Choose a Presence style'),
                    isExpanded: true,
                    items: GatewayPresenceType.values
                        .map((e) => ComboBoxItem<GatewayPresenceType>(
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

                      String storedPresenceType =
                          box.get('gatewayPresenceType');

                      if (storedPresenceType == changingPresenceType) {
                        setState(() {
                          changing = false;
                        });
                        return;
                      }

                      box.put('gatewayPresenceType', changingPresenceType);

                      if (gateway!.started) {
                        gateway!.stopUpdating();
                      }

                      gateway!.presenceType = presenceType;

                      gateway!.startUpdating();

                      displayInfoBar(
                        context,
                        builder: (context, close) => const InfoBar(
                          title: Text(
                            'Presence style successfully changed',
                          ),
                          severity: InfoBarSeverity.success,
                        ),
                      );

                      setState(() {
                        changing = false;
                      });
                    },
                  ),
                ),
          const SizedBox(
            height: 10,
          ),
          currentGatewayPresenceType == GatewayPresenceType.musicAppInHeader &&
                  box.get('priorUsing') == 'discord'
              ? InfoLabel(
                  label: 'Music app',
                  child: ComboBox<String>(
                    placeholder: const Text('Choose a Presence style'),
                    isExpanded: true,
                    items: musicApps
                        .map(
                          (e) => ComboBoxItem<String>(
                            child: Text(e),
                            value: e,
                          ),
                        )
                        .toList(),
                    value: currentMusicApp,
                    onChanged: (value) {
                      if (changing) {
                        return;
                      }

                      setState(() {
                        changing = true;
                      });

                      if (value != null) {
                        setState(() {
                          currentMusicApp = value;
                        });
                      }

                      String changingMusicApp = value!;

                      String storedMusicApp = box.get('defaultMusicApp');

                      if (storedMusicApp == changingMusicApp) {
                        setState(() {
                          changing = false;
                        });
                        return;
                      }

                      box.put('defaultMusicApp', changingMusicApp);

                      gateway!.defaultMusicApp = changingMusicApp;

                      displayInfoBar(
                        context,
                        builder: (context, close) => const InfoBar(
                          title: Text(
                            'Music app successfully changed',
                          ),
                          severity: InfoBarSeverity.success,
                        ),
                      );

                      setState(() {
                        changing = false;
                      });
                    },
                  ),
                )
              : const SizedBox(),
        ],
      );
    }

    return ScaffoldPage.withPadding(
      header: const PageHeader(
        title: Text('Discord Rich Presence Settings'),
      ),
      content: const Column(
        children: [
          InfoBar(
            title: Text('Set up Last.fm first.'),
            severity: InfoBarSeverity.warning,
          ),
        ],
      ),
    );
  }
}
