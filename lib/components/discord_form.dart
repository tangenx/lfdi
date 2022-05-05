import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lfdi/constants.dart';
import 'package:lfdi/handlers/discord_websocket/websocket_manager.dart';
import 'package:lfdi/main.dart';
import 'package:spotify/spotify.dart';

class DiscordForm extends ConsumerStatefulWidget {
  const DiscordForm({Key? key}) : super(key: key);

  @override
  ConsumerState<DiscordForm> createState() => _DiscordFormState();
}

class _DiscordFormState extends ConsumerState<DiscordForm> {
  bool processing = false;
  final discordFormKey = GlobalKey<FormState>();
  final discordTokenController = TextEditingController();
  final spotifyApiKeyController = TextEditingController();
  final spotifyApiSecretController = TextEditingController();
  var box = Hive.box('lfdi');

  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Button(
                child: const Text('Apply'),
                onPressed: () async {
                  if (processing) {
                    return;
                  }

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

                    final token = discordTokenController.text.toString();

                    DiscordWebSocketManager webSocketManager =
                        ref.read(discordGatewayProvider);

                    webSocketManager.lastFmApiKey = lastfmApiKey;
                    webSocketManager.lastFmUsername = lastfmUsername;

                    if (webSocketManager.identifyIsSent) {
                      webSocketManager.reinit();
                    }

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
                    await Future.delayed(const Duration(seconds: 3));

                    if (isWebSocketDead) {
                      webSocketManager.dispose();

                      showSnackbar(
                        context,
                        const Snackbar(
                          content: Text('Invalid user token'),
                        ),
                      );

                      setState(() {
                        processing = false;
                      });

                      return;
                    }

                    box.put('discordToken', token);

                    // Test Spotify
                    final spotifyApiKey = spotifyApiKeyController.text;
                    final spotifyApiSecret = spotifyApiSecretController.text;

                    bool isSpotifyError = false;

                    try {
                      final credentials = SpotifyApiCredentials(
                        spotifyApiKey,
                        spotifyApiSecret,
                      );

                      final spotifyApi = SpotifyApi(credentials);
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
                      log('Caught error while connecting to Spotify: ${error.runtimeType}');
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

                    webSocketManager.spotifyApi = SpotifyApi(
                      SpotifyApiCredentials(spotifyApiKey, spotifyApiSecret),
                    );

                    webSocketManager.presenceType =
                        stringIdToPresenceType[box.get('gatewayPresenceType')];
                    webSocketManager.defaultMusicApp =
                        box.get('defaultMusicApp');

                    if (!webSocketManager.initialized) {
                      webSocketManager.init();

                      final priorUsing = box.get('priorUsing');

                      if (priorUsing == 'discord') {
                        if (!webSocketManager.started) {
                          webSocketManager.startUpdating();
                        }
                      }
                    }
                  }

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

                  showSnackbar(
                    context,
                    const Snackbar(
                      content: Text('Done'),
                    ),
                  );

                  setState(() {
                    processing = false;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
