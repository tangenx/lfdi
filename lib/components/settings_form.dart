import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lfdi/api/api.dart';
import 'package:lfdi/main.dart';
import 'package:lfdi/handlers/rpc.dart';
import 'package:url_launcher/url_launcher.dart';

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
  var box = Hive.box('lfdi');

  @override
  void initState() {
    final apiKey = box.get('apiKey');
    final username = box.get('username');

    apiKeyController.text = apiKey ?? '';
    usernameController.text = username ?? '';
    super.initState();
  }

  @override
  void dispose() {
    apiKeyController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /*
      at this point i realized
      that i had to edit the fluent_ui library

      so I changed these files:
      - fluent_ui/lib/src/controls/form/text_box.dart
        - lines 1065-1085
        - if dark:
          - pressing or focusing: Color.fromRGBO(30, 30, 30, 0.7);
          - hovering: Color.fromRGBO(255, 255, 255, 0.1);
          - default: Color.fromRGBO(255, 255, 255, 0.0605);
      
      - fluent_ui/lib/src/controls/inputs/buttons.dart
        - line 42:
          - ButtonState.all(const Color.fromRGBO(255, 255, 255, 0.04))
        - line 64:
          - return theme.brightness.isLight ? Colors.black : Colors.white;
          (without it brokes the button color text)

      - fluent_ui/lib/src/controls/inputs/theme.dart
        - lines 245-267:
          - if light:
            - default: const Color(0xFFF9F9F9);
          - if dark:
            - isPressing: Color.fromRGBO(255, 255, 255, 0.0837);
            - isHovering: Color.fromRGBO(255, 255, 255, 0.0837);
            - default: Color.fromRGBO(255, 255, 255, 0.0605);

      (original colors are commented)
    */

    return Form(
      key: settingsFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 400,
                child: TextFormBox(
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
              ),
              const SizedBox(
                width: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Button(
                  child: const Text('Get'),
                  onPressed: () {
                    launchUrl(
                      Uri.parse('https://www.last.fm/api/account/create'),
                    );
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 400,
                child: TextFormBox(
                  header: 'Last.fm username',
                  placeholder:
                      'Get your username on last.fm/user/your_name_here',
                  controller: usernameController,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Provide an username';
                    }

                    return null;
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Button(
                  child: const Text('Get'),
                  onPressed: () {
                    launchUrl(
                      Uri.parse('https://www.last.fm/settings/account'),
                    );
                  },
                ),
              ),
            ],
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

                final lastfmApiKey = box.get('apiKey');
                final lastfmUsername = box.get('username');

                // Check on change
                if (lastfmUsername == username && lastfmApiKey == apiKey) {
                  showSnackbar(
                    context,
                    const Snackbar(
                      content: Text('This data has already been saved'),
                    ),
                  );

                  setState(() {
                    processing = false;
                  });
                  return;
                }

                final testResponse =
                    API.checkAPI(await API.getRecentTrack(username, apiKey));

                if (testResponse['status'] == 'error') {
                  showSnackbar(
                    context,
                    Snackbar(
                      content: Text(testResponse['message']),
                    ),
                  );

                  setState(() {
                    processing = false;
                  });
                  return;
                }

                if (testResponse['message']['recenttracks'] != null &&
                    testResponse['message']['recenttracks']['track'] != null) {
                  box.putAll({
                    'username': username,
                    'apiKey': apiKey,
                  });

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
