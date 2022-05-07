import 'package:lfdi/constants.dart';
import 'package:lfdi/globals.dart';
import 'package:lfdi/handlers/discord_websocket/discord_websocket.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/gateway_handler.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/handler_data.dart';

/// Handles the Hello operation (OP Code: `10`)
class HelloHandler extends GatewayHandler {
  bool helloAlreadyRecieved = false;

  /// Sets ping timer
  ///
  /// The timer sends a `heartbeat` (OP Code: 1) once every `heartbeat_inerval` milliseconds
  @override
  GatewayHandlerData handle(
    DiscordWebSoket discordWebSoket,
  ) {
    if (helloAlreadyRecieved) {
      return GatewayHandlerData(
        operationCode: 10,
        data: null,
        error: helloAlreadyRecievedError,
      );
    }

    helloAlreadyRecieved = true;

    logger.i('[DWS: HelloHandler] Received timer setup command.');
    return GatewayHandlerData(
      operationCode: 10,
      data: {
        'success': true,
        'configureHeartbeat': true,
      },
      error: null,
    );
  }

  void disposeHeartbeat() {
    logger.i('[DWS: HelloHandler] Triggered dispose');
    helloAlreadyRecieved = false;
  }
}
