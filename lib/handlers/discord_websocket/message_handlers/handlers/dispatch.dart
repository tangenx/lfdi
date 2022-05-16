import 'package:lfdi/handlers/discord_websocket/discord_websocket.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/gateway_handler.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/handler_data.dart';

/// Handles the Dispatch operation (OP Code: `0`)
class DispatchHandler extends GatewayHandler {
  @override
  GatewayHandlerData handle(
    DiscordWebSoket? discordWebSoket,
  ) {
    // This data is of no interest to us,
    // so we simply do not give any data to the websocket message handler
    return GatewayHandlerData(
      operationCode: 0,
      error: null,
      data: null,
    );
  }
}
