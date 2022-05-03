import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lfdi/handlers/discord_websocket/websocket_manager.dart';
import 'package:lfdi/main.dart';

class DiscordForm extends ConsumerStatefulWidget {
  const DiscordForm({Key? key}) : super(key: key);

  @override
  ConsumerState<DiscordForm> createState() => _DiscordFormState();
}

class _DiscordFormState extends ConsumerState<DiscordForm> {
  bool processing = false;
  final discordFormKey = GlobalKey<FormState>();
  final discordTokenController = TextEditingController();

  @override
  void dispose() {
    discordTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var box = Hive.box('lfdi');

    final discordToken = box.get('discordToken');

    discordTokenController.text = discordToken ?? '';

    return Form(
      key: discordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormBox(
            header: 'Discord User token',
            placeholder: 'Yes, your token. Not bot.',
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: discordTokenController,
            validator: (text) {
              if (text == null || text.isEmpty) {
                return 'Provide a token';
              }

              if (text.length != 59) {
                return 'Token is invalid';
              }

              return null;
            },
          ),
          Button(
            child: const Text('Apply'),
            onPressed: () async {
              if (processing) {
                return;
              }

              if (discordFormKey.currentState!.validate()) {
                setState(() {
                  processing = true;
                });

                final token = discordTokenController.text.toString();

                DiscordWebSocketManager webSocketManager =
                    ref.read(discordGatewayProvider);
                webSocketManager.discordToken = token;

                bool isWebSocketDead = false;
                webSocketManager.addListener(
                  name: 'onClose',
                  listener: () {
                    isWebSocketDead = true;
                  },
                );
                webSocketManager.init();

                await Future.delayed(const Duration(seconds: 1));
                webSocketManager.sendIdentify();
                await Future.delayed(const Duration(seconds: 1));

                if (isWebSocketDead) {
                  webSocketManager.removeListener(listenerName: 'onClose');

                  showSnackbar(
                    context,
                    const Snackbar(
                      content: Text('Invalid user token'),
                    ),
                  );

                  setState(() {
                    processing = true;
                  });

                  return;
                }

                box.put('discordToken', token);

                showSnackbar(
                  context,
                  const Snackbar(
                    content: Text('Discord Gateway successfully configured'),
                  ),
                );
              }

              setState(() {
                processing = false;
              });
            },
          ),
        ],
      ),
    );
  }
}
