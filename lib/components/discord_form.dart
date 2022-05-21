import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lfdi/constants.dart';
import 'package:lfdi/globals.dart';
import 'package:lfdi/handlers/discord_websocket/websocket_manager.dart';
import 'package:lfdi/main.dart';
import 'package:spotify/spotify.dart';
import 'package:url_launcher/url_launcher.dart';

class DiscordForm extends ConsumerStatefulWidget {
  final Function updateState;
  const DiscordForm({
    Key? key,
    required this.updateState,
  }) : super(key: key);

  @override
  ConsumerState<DiscordForm> createState() => _DiscordFormState();
}

class _DiscordFormState extends ConsumerState<DiscordForm> {
  bool processing = false;
  final discordFormKey = GlobalKey<FormState>();
  final discordTokenController = TextEditingController();
  final spotifyApiKeyController = TextEditingController();
  final spotifyApiSecretController = TextEditingController();
  late Box box;

  @override
  void initState() {
    box = Hive.box('lfdi');
    final discordToken = box.get('discordToken');
    final spotifyApiKey = box.get('spotifyApiKey');
    final spotifyApiSecret = box.get('spotifyApiSecret');

    discordTokenController.text = discordToken ?? '';
    spotifyApiKeyController.text = spotifyApiKey ?? '';
    spotifyApiSecretController.text = spotifyApiSecret ?? '';
    super.initState();
  }

  @override
  void dispose() {
    discordTokenController.dispose();
    super.dispose();
  }

  Widget buildInfoBar(String text) {
    return Column(
      children: [
        InfoBar(
          title: Text(text),
          severity: InfoBarSeverity.warning,
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: discordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (box.get('apiKey') == null && box.get('username') == null) ||
                  (box.get('apiKey').isEmpty && box.get('username').isEmpty)
              ? buildInfoBar('Set up Last.fm first.')
              : const SizedBox(),
          TextFormBox(
            header: 'Discord User token',
            placeholder: 'Yes, your token. Not bot.',
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: discordTokenController,
            validator: (text) {
              if (text == null || text.isEmpty) {
                return 'Provide a token';
              }

              return null;
            },
            suffix: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Button(
                style: ButtonStyle(
                  padding: ButtonState.all<EdgeInsets>(
                    const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                  ),
                ),
                child: const Text('Get'),
                onPressed: () {
                  launchUrl(
                    Uri.parse(
                      'https://github.com/tangenx/lfdi/blob/lord/docs/en/gateway/configure.md#getting-a-discord-token',
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormBox(
            header: 'Spotify App Client ID',
            placeholder:
                'Get your Client ID at developer.spotify.com/dashboard/applications',
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: spotifyApiKeyController,
            validator: (text) {
              if (text == null || text.isEmpty) {
                return 'Provide a Client ID';
              }

              if (text.length != 32) {
                return 'Client ID is invalid';
              }

              return null;
            },
            suffix: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Button(
                style: ButtonStyle(
                  padding: ButtonState.all<EdgeInsets>(
                    const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                  ),
                ),
                child: const Text('Get'),
                onPressed: () {
                  launchUrl(
                    Uri.parse(
                      'https://github.com/tangenx/lfdi/blob/lord/docs/en/gateway/configure.md#getting-the-spotify-client-id-and-client-secret',
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormBox(
            header: 'Spotify App Client Secret',
            placeholder:
                'Get your Client Secret at developer.spotify.com/dashboard/applications',
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: spotifyApiSecretController,
            validator: (text) {
              if (text == null || text.isEmpty) {
                return 'Provide a Client Secret';
              }

              if (text.length != 32) {
                return 'Client Secret is invalid';
              }

              return null;
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Button(
                child: const Text('Apply'),
                onPressed: () async {
                  if (processing) {
                    return;
                  }

                  final token = discordTokenController.text;
                  final spotifyApiKey = spotifyApiKeyController.text;
                  final spotifyApiSecret = spotifyApiSecretController.text;

                  if (token == box.get('discordToken') &&
                      spotifyApiKey == box.get('spotifyApiKey') &&
                      spotifyApiSecret == box.get('spotifyApiSecret')) {
                    setState(() {
                      processing = false;
                    });

                    showSnackbar(
                      context,
                      const Snackbar(
                        content: Text(
                          'Nothing to change.',
                        ),
                      ),
                    );

                    return;
                  }

                  DiscordWebSocketManager webSocketManagerInstance =
                      ref.read(discordGatewayProvider);
                  webSocketManagerInstance.dispose();

                  // Check lastfm
                  final lastfmApiKey = box.get('apiKey');
                  final lastfmUsername = box.get('username');

                  if (lastfmUsername == null ||
                      lastfmApiKey == null ||
                      lastfmUsername.isEmpty ||
                      lastfmApiKey.isEmpty) {
                    setState(() {
                      processing = false;
                    });

                    showSnackbar(
                      context,
                      const Snackbar(
                        content: Text(
                          'Set up Last.fm firstly.',
                        ),
                      ),
                    );
                  }

                  if (discordFormKey.currentState!.validate()) {
                    setState(() {
                      processing = true;
                    });
                    // Test Discord

                    DiscordWebSocketManager webSocketTestManager =
                        DiscordWebSocketManager(discordToken: token);

                    webSocketTestManager.lastFmApiKey = lastfmApiKey;
                    webSocketTestManager.lastFmUsername = lastfmUsername;

                    webSocketTestManager.discordToken = token;

                    bool isWebSocketDead = false;
                    webSocketTestManager.addListener(
                      name: 'onClose',
                      listener: () {
                        isWebSocketDead = true;
                      },
                    );
                    webSocketTestManager.init();

                    await Future.delayed(const Duration(seconds: 1));
                    webSocketTestManager.sendIdentify();
                    await Future.delayed(const Duration(seconds: 3));
                    webSocketTestManager.dispose();

                    if (isWebSocketDead) {
                      showSnackbar(
                        context,
                        const Snackbar(
                          content: Text(
                            'Invalid user token (if you\'re sure it\'s not, try again)',
                          ),
                        ),
                      );

                      setState(() {
                        processing = false;
                      });

                      return;
                    }

                    box.put('discordToken', token);

                    // Test Spotify
                    bool isSpotifyError = false;

                    try {
                      final credentials = SpotifyApiCredentials(
                        spotifyApiKey,
                        spotifyApiSecret,
                      );

                      // Thanks to github.com/evaqum
                      final spotifyApi =
                          await SpotifyApi.asyncFromCredentials(credentials);
                      await spotifyApi.search.get('metallica').first(2);

                      // If it ever stops working, I have a way
                      // around the spotify library (I spent 6 hours on it):

                      // await oauth2.clientCredentialsGrant(
                      //   Uri.parse('https://accounts.spotify.com/api/token'),
                      //   spotifyApiKey,
                      //   spotifyApiSecret,
                      //   httpClient: null,
                      // );
                    } catch (error) {
                      logger.error(
                          'Caught error while connecting to Spotify: ${error.runtimeType}');
                      isSpotifyError = true;
                    }

                    if (isSpotifyError) {
                      showSnackbar(
                        context,
                        const Snackbar(
                          content: Text(
                            'Spotify Client ID or Client Secret is invalid.',
                          ),
                        ),
                      );

                      setState(() {
                        processing = false;
                      });

                      return;
                    }

                    box.put('spotifyApiKey', spotifyApiKey);
                    box.put('spotifyApiSecret', spotifyApiSecret);

                    // Set up main instance
                    webSocketManagerInstance.discordToken = token;
                    webSocketManagerInstance.lastFmApiKey = lastfmApiKey;
                    webSocketManagerInstance.lastFmUsername = lastfmUsername;
                    webSocketManagerInstance.spotifyApi = SpotifyApi(
                      SpotifyApiCredentials(spotifyApiKey, spotifyApiSecret),
                    );
                    webSocketManagerInstance.presenceType =
                        stringIdToPresenceType[box.get('gatewayPresenceType')];
                    webSocketManagerInstance.defaultMusicApp =
                        box.get('defaultMusicApp');

                    webSocketManagerInstance.init();

                    final priorUsing = box.get('priorUsing');

                    if (priorUsing == 'discord') {
                      if (!webSocketManagerInstance.started) {
                        webSocketManagerInstance.startUpdating();
                      }
                    }
                  }

                  widget.updateState();

                  showSnackbar(
                    context,
                    const Snackbar(
                      content: Text(
                        'Gateway successfully configured.',
                      ),
                    ),
                  );

                  setState(() {
                    processing = false;
                  });
                },
              ),
              const SizedBox(
                width: 10,
              ),
              Row(
                children: [
                  Button(
                    child: const Text('Clear'),
                    onPressed: () {
                      if (processing) {
                        return;
                      }
                      setState(() {
                        processing = true;
                      });

                      discordTokenController.text = '';

                      box.put('discordToken', '');

                      DiscordWebSocketManager webSocketManager =
                          ref.read(discordGatewayProvider);

                      if (webSocketManager.initialized) {
                        webSocketManager.dispose();
                      }

                      spotifyApiKeyController.text = '';
                      spotifyApiSecretController.text = '';

                      box.put('spotifyApiKey', '');
                      box.put('spotifyApiSecret', '');
                      box.put('priorUsing', 'lastfm');

                      final rpc = ref.read(rpcProvider);
                      rpc.start();

                      showSnackbar(
                        context,
                        const Snackbar(
                          content: Text('Successfully cleared.'),
                        ),
                      );

                      setState(() {
                        processing = false;
                      });
                    },
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
