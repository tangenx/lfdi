import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lfdi/api/api.dart';
import 'package:lfdi/main.dart';
import 'package:lfdi/handlers/rpc.dart';

class SettingsForm extends ConsumerStatefulWidget {
  const SettingsForm({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<SettingsForm> {
  bool processing = false;

  final settingsFormKey = GlobalKey<FormState>();
  final apiKeyController = TextEditingController();
  final usernameController = TextEditingController();

  @override
  void dispose() {
    apiKeyController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(prefsProvider).value;

    final apiKey = prefs?.getString('apiKey');
    final username = prefs?.getString('username');

    apiKeyController.text = apiKey ?? '';
    usernameController.text = username ?? '';

    return Form(
      key: settingsFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormBox(
            header: 'API key',
            placeholder: 'Get your key on last.fm/api/account/create',
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: apiKeyController,
            validator: (text) {
              if (text == null || text.isEmpty) {
                return 'Provide an API key';
              }

              if (text.length != 32) {
                return 'API key is invalid';
              }

              return null;
            },
          ),
          TextFormBox(
            header: 'Last.fm username',
            placeholder: 'Get your username on last.fm/user/your_name_here',
            controller: usernameController,
            validator: (text) {
              if (text == null || text.isEmpty) {
                return 'Provide an username';
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

              if (settingsFormKey.currentState!.validate()) {
                setState(() {
                  processing = true;
                });

                final username = usernameController.text;
                final apiKey = apiKeyController.text;
                final testResponse =
                    API.checkAPI(await API.getRecentTrack(username, apiKey));

                if (testResponse['status'] == 'error') {
                  showSnackbar(
                    context,
                    Snackbar(
                      content: Text(testResponse['message']),
                    ),
                  );
                  return;
                }

                if (testResponse['message']['recenttracks'] != null &&
                    testResponse['message']['recenttracks']['track'] != null) {
                  await prefs?.setString('username', username);
                  await prefs?.setString('apiKey', apiKey);

                  showSnackbar(
                    context,
                    const Snackbar(
                      content: Text('Last.fm successfully configured'),
                    ),
                  );

                  RPC rpc = ref.read(rpcProvider);
                  rpc.initialize(apiKey: apiKey, username: username);
                  rpc.start();

                  setState(() {
                    processing = false;
                  });
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
