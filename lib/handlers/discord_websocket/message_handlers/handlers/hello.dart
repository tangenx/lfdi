import 'dart:async';
import 'dart:developer';

import 'package:lfdi/constants.dart';
import 'package:lfdi/handlers/discord_websocket/gateway_message.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/gateway_handler.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/handler_data.dart';
import 'package:web_socket_channel/io.dart';

/// Handles the Hello operation (OP Code: `10`)
class HelloHandler extends GatewayHandler {
  bool helloAlreadyRecieved = false;
  late Timer heartbeatTimer;

  /// Sets ping timer
  ///
  /// The timer sends a `heartbeat` (OP Code: 1) once every `heartbeat_inerval` milliseconds
  @override
  GatewayHandlerData handle(IOWebSocketChannel channel, int? lastSequence) {
    if (helloAlreadyRecieved) {
      return GatewayHandlerData(
        operationCode: 10,
        data: null,
        error: helloAlreadyRecievedError,
      );
    }

    helloAlreadyRecieved = true;

    heartbeatTimer = Timer.periodic(
      Duration(milliseconds: message?.data['heartbeat_interval']),
      (timer) {
        final DiscordGatewayMessage messageToSent = DiscordGatewayMessage(
          operationCode: 1,
          data: lastSequence,
          eventName: null,
          sequence: null,
        );
        log('[DWS: HelloHandler] Send heartbeat.');
        channel.sink.add(messageToSent.toJsonString());
      },
    );

    return GatewayHandlerData(
      operationCode: 10,
      data: {
        'success': true,
      },
      error: null,
    );
  }

  void disposeHeartbeat() {
    helloAlreadyRecieved = false;
    heartbeatTimer.cancel();
  }
}
