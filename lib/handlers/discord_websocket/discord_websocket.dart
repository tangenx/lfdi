import 'dart:convert';
import 'dart:developer';

import 'package:lfdi/handlers/discord_websocket/gateway_message.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/handler_data.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/handler_factory.dart';
import 'package:web_socket_channel/io.dart';

class DiscordWebSoket {
  final baseUrl = 'wss://gateway.discord.gg/?v=6&encoding=json';
  IOWebSocketChannel? webSocketChannel;

  // Used for heartbeating
  int? lastSequence;

  // Stores all handlers
  final GatewayHandlerFactory handlerFactory = GatewayHandlerFactory();

  void init() {
    webSocketChannel = IOWebSocketChannel.connect(Uri.parse(baseUrl));

    webSocketChannel!.stream.listen((message) {
      Map webSocketMessage = jsonDecode(message);

      log('[DWS: Main] New message: $webSocketMessage');

      // Handle a message
      webSocketMessagesHandler(webSocketMessage);
    });
  }

  void webSocketMessagesHandler(Map message) {
    // Make a class
    final DiscordGatewayMessage gatewayMessage =
        DiscordGatewayMessage.fromWebSocketMessage(message);
    log('[DWS: WSMessageHandler] Made a DiscordGatewayMessage class');

    // Select a handler from opcode
    final handler =
        handlerFactory.getHandlerByOpcode(gatewayMessage.operationCode);
    log('[DWS: WSMessageHandler] Selected handler: $handler');

    // Set up message to a handler
    handler.setUpMessage(gatewayMessage);

    // All handlers must return data, regardless of whether they are empty
    // Return class is `GatewayHandlerData`
    final GatewayHandlerData dataFromHandler =
        handler.handle(webSocketChannel, lastSequence);
    log('[DWS: WSMessageHandler] Handler returns data: ${dataFromHandler.toString()}');

    // Set lastSequence if handler returns it
    // (as `s` property in `data`)
    if (dataFromHandler.data != null) {
      if (dataFromHandler.data!['s'] != null) {
        lastSequence = dataFromHandler.data!['s'];
      }
    }
  }
}
