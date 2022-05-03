import 'dart:developer';

import 'package:lfdi/handlers/discord_websocket/discord_websocket.dart';
import 'package:lfdi/handlers/discord_websocket/gateway_message.dart';
import 'package:lfdi/handlers/discord_websocket/presence_generator.dart';

class DiscordWebSocketManager {
  String discordToken;
  DiscordWebSocketManager({
    required this.discordToken,
  });

  /// User to check for the use of a websocket
  bool initialized = false;

  final DiscordWebSoket ws = DiscordWebSoket();

  /// Init websockets and setup listeners (listeners not used yet)
  void init() {
    log('[DWS: Manager]: Start init');
    // Add listener to dispose manager after websocket closed state.
    ws.addListener(
      name: 'onClose_Manager',
      listener: () {
        initialized = false;
      },
    );
    ws.init();
    initialized = true;
    log('[DWS: Manager]: Successfully initialized');
  }

  void dispose() {
    log('[DWS: Manager]: Triggered dispose');
    ws.dispose();
  }

  /// Sends message to the websocket
  void sendMessage(DiscordGatewayMessage message) {
    ws.sendMessage(message);
  }

  void addListener({
    required String name,
    required Function listener,
  }) {
    ws.addListener(name: name, listener: listener);
  }

  void removeListener({required String listenerName}) {
    ws.removeListener(listenerName: listenerName);
  }

  void sendIdentify() {
    DiscordGatewayMessage message = DiscordGatewayMessage(
      // OP Code 2 - Identify -	used for client handshake
      operationCode: 2,
      data: {
        'token': discordToken,
        'properties': {
          '\$os': 'windows',
          '\$browser': 'discord.js',
          '\$device': 'discord.js',
          '\$referrer': '',
          '\$referring_domain': '',
        },
        'large_threshold': 250,
        'compress': true,
        // this property is taken from discord.js library
        'version': 6,
      },
      eventName: null,
      sequence: null,
    );

    sendMessage(message);
  }

  void sendPresence({required DiscordPresence presence}) {
    DiscordGatewayMessage message = DiscordGatewayMessage(
      operationCode: 3,
      data: {
        'status': 'offline',
        'game': presence.toMap(),
        'afk': false,
        'since': 0,
      },
      eventName: null,
      sequence: null,
    );

    sendMessage(message);
  }
}
