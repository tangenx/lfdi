import 'package:lfdi/handlers/discord_websocket/message_handlers/gateway_handler.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/handler_data.dart';
import 'package:web_socket_channel/io.dart';

/// Handles the Heartbeat ACK operation (OP Code: `11`)
class HeartbeatACKHandler extends GatewayHandler {
  @override
  GatewayHandlerData handle(
    IOWebSocketChannel channel,
    Function getLastSequence,
  ) {
    return GatewayHandlerData(
      operationCode: 11,
      error: null,
      data: message!.toMap(),
    );
  }
}
