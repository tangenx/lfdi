import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:lfdi/constants.dart';
import 'package:lfdi/handlers/discord_websocket/gateway_message.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/handler_data.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/handler_factory.dart';
import 'package:web_socket_channel/io.dart';

class DiscordWebSoket {
  final baseUrl = 'wss://gateway.discord.gg/?v=6&encoding=json';
  IOWebSocketChannel? webSocketChannel;

  /// Used for heartbeating
  int? lastSequence;

  /// Stores all handlers
  final GatewayHandlerFactory handlerFactory = GatewayHandlerFactory();

  /// Stores all listeners
  Map<String, Function> listeners = {};

  /// Used for checking timer heartbeat
  bool heartbeatIsConfigured = false;
  Timer? heartbeatTimer;

  /// Initialize websokcet
  void init() {
    log('[DWS: Main] Creating connection');
    webSocketChannel = IOWebSocketChannel.connect(Uri.parse(baseUrl), headers: {
      'User-Agent': userAgent,
    });

    log('[DWS: Main] Starting listen to events');
    webSocketChannel!.stream.listen((message) {
      if (message is Uint8List) {
        log('[DWS: Main] Gateway sent array of bytes.');

        return;
      }
      Map webSocketMessage = jsonDecode(message);
      log('[DWS: Main] New message.');

      // Handle a message
      webSocketMessagesHandler(webSocketMessage);
    }, onDone: () {
      log('[DWS: Main] WebSocket connection was closed.');
      listeners['onClose_Manager']!();

      if (listeners['onClose'] != null) {
        listeners['onClose']!();
      }
    }, onError: (error) {
      log('[DWS: Main] WebSocket error $error.');
    });
  }

  /// Handles all incoming messages from Gateway
  void webSocketMessagesHandler(Map message) {
    // Make a class
    final DiscordGatewayMessage gatewayMessage =
        DiscordGatewayMessage.fromWebSocketMessage(message);
    log('[DWS: WSMessageHandler] Message info: OP Code is ${gatewayMessage.operationCode} (${opToName[gatewayMessage.operationCode]}). ${gatewayMessage.eventName != null ? 'Event name: ${gatewayMessage.eventName}' : ''}');

    // Select a handler from opcode
    final handler =
        handlerFactory.getHandlerByOpcode(gatewayMessage.operationCode);
    log('[DWS: WSMessageHandler] Selected handler: $handler');

    // Set up message to a handler
    handler.setUpMessage(gatewayMessage);

    // All handlers must return data, regardless of whether they are empty
    // Return class is `GatewayHandlerData`
    final GatewayHandlerData dataFromHandler =
        handler.handle(webSocketChannel, getlastSequence);
    log('[DWS: WSMessageHandler] Handler returns data: ${dataFromHandler.toString()}');

    // Set lastSequence
    lastSequence = gatewayMessage.sequence;

    // Check for heartbeat
    if (gatewayMessage.operationCode == 10) {
      if (dataFromHandler.data != null &&
          dataFromHandler.data!['configureHeartbeat'] != null) {
        if (!heartbeatIsConfigured) {
          log('[DWS: WSMessageHandler] Setup heartbeat timer.');
          heartbeatTimer = Timer.periodic(
            Duration(milliseconds: gatewayMessage.data['heartbeat_interval']),
            (timer) {
              final DiscordGatewayMessage messageToSent = DiscordGatewayMessage(
                operationCode: 1,
                data: lastSequence,
                eventName: null,
                sequence: null,
              );
              log('[DWS: Heartbeat Timer] Send heartbeat. Last sequence number is: $lastSequence');
              webSocketChannel!.sink.add(messageToSent.toJsonString());
            },
          );
        }
      }
    }
  }

  /// Returns the last sequence number
  ///
  /// Used for HelloHandler,
  /// that sends last sequence number
  /// once at `heartbeat_interval` milliseconds
  int? getlastSequence() {
    return lastSequence;
  }

  /// Sends the message to Gateway
  void sendMessage(DiscordGatewayMessage messageToSend) {
    String message = messageToSend.toJsonString();
    log('[DWS: Main] Sending message: $message');
    webSocketChannel!.sink.add(message);
  }

  /// Closes the connection
  void closeConnection() {
    log('[DWS: Main] Closing connection');

    webSocketChannel!.sink.close();
  }

  /// Dispose the WebSocket
  void dispose() {
    log('[DWS: Main] Triggered dispose');
    closeConnection();

    heartbeatIsConfigured = false;
    heartbeatTimer?.cancel();

    Future.delayed(const Duration(milliseconds: 200))
        .then((value) => removeAllListeners());
  }

  /// Set up listeners (must before init)
  void setUpListeners(Map<String, Function> listeners) {
    this.listeners = listeners;
  }

  void addListener({
    required String name,
    required Function listener,
  }) {
    listeners[name] = listener;
  }

  void removeListener({required String listenerName}) {
    listeners.remove(listenerName);
  }

  void removeAllListeners() {
    listeners.clear();
  }
}

Map<int, String> opToName = {
  0: 'Dispatch',
  10: 'Hello',
  11: 'Heartbeat ACK',
};
