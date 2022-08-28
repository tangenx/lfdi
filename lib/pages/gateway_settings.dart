import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lfdi/components/discord_form.dart';
import 'package:lfdi/handlers/discord_websocket/websocket_manager.dart';
import 'package:lfdi/handlers/rpc.dart';
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
  String? priorUse;
  DiscordWebSocketManager? gateway;
  RPC? rpc;

  @override
  void initState() {
    rpc = ref.read(rpcProvider);
    gateway = ref.read(discordGatewayProvider);
    priorUse = box.get('priorUsing');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final typography = FluentTheme.of(context).typography;

    return ScaffoldPage.scrollable(
      header: const PageHeader(
        title: Text('Discord Gateway Settings'),
      ),
      children: [
        rpc!.initialized && gateway!.initialized
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Use Gateway to update status:',
                    style: typography.bodyLarge,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ToggleSwitch(
                    checked: priorUse != null && priorUse == 'discord',
                    content: Text(priorUse != null
                        ? priorUse == 'discord'
                            ? 'On'
                            : 'Off'
                        : 'Off'),
                    onChanged: (v) {
                      if (v) {
                        // Use Gateway (aka Discord method)
                        rpc!.stop();

                        box.put('priorUsing', 'discord');

                        gateway!.startUpdating();
                        setState(() {
                          priorUse = 'discord';
                        });
                      } else {
                        // Use lastfm (aka RPC method)
                        gateway!.stopUpdating();

                        box.put('priorUsing', 'lastfm');

                        rpc!.start();
                        setState(() {
                          priorUse = 'lastfm';
                        });
                      }
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              )
            : const SizedBox(),
        Align(
          alignment: Alignment.centerLeft,
          child: DiscordForm(
            updateState: () => setState(() {
              rpc = ref.read(rpcProvider);
              gateway = ref.read(discordGatewayProvider);
            }),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
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
                launchUrl(
                  Uri.parse(
                    'https://github.com/tangenx/lfdi/blob/lord/docs/en/why%20the%20gateway%20seems%20illegal.md',
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
