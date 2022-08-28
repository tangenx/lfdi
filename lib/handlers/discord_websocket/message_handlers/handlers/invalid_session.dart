import 'package:lfdi/globals.dart';
import 'package:lfdi/handlers/discord_websocket/discord_websocket.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/gateway_handler.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/handler_data.dart';

/// Handles the Invalid Session operation (OP Code: `9`)
class InvalidSessionHandler extends GatewayHandler {
  @override
  GatewayHandlerData handle(
    DiscordWebSoket discordWebSoket,
  ) {
    logger.info(
      'Send resendIdentify flag to WebSocket',
      name: 'DWS: InvalidSessionHandler',
    );

    return GatewayHandlerData(
      operationCode: 9,
      error: null,
      data: {
        'resendIdentify': true,
      },
    );
  }
}
