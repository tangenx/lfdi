import 'package:lfdi/globals.dart';
import 'package:lfdi/handlers/discord_websocket/discord_websocket.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/gateway_handler.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/handler_data.dart';

/// Handles the Dispatch operation (OP Code: `0`)
class DispatchHandler extends GatewayHandler {
  @override
  GatewayHandlerData handle(
    DiscordWebSoket? discordWebSoket,
  ) {
    if (message?.eventName == 'READY') {
      logger.info(
        'Session ID: ${message?.data['session_id']}',
        name: 'DWS: DispatchHandler',
      );

      discordWebSoket!.sessionId = message!.data['session_id'];
    }

    // This data is of no interest to us,
    // so we simply do not give any data to the websocket message handler
    return GatewayHandlerData(
      operationCode: 0,
      error: null,
      data: null,
    );
  }
}
