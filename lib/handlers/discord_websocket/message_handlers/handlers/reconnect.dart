import 'package:lfdi/globals.dart';
import 'package:lfdi/handlers/discord_websocket/discord_websocket.dart';
import 'package:lfdi/handlers/discord_websocket/gateway_message.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/gateway_handler.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/handler_data.dart';

/// Handles the Reconnect operation (OP Code: `7`)
class ReconnectHandler extends GatewayHandler {
  @override
  GatewayHandlerData handle(
    DiscordWebSoket discordWebSoket,
  ) {
    logger.info('Set up reconnect listeners', name: 'DWS: ReconnectHandler');
    discordWebSoket.addListener(
      name: 'on_resume_hadler',
      listener: () {
        discordWebSoket.init();
        // Send Resume message
        final DiscordGatewayMessage gatewayMessage = DiscordGatewayMessage(
          operationCode: 6,
          data: {
            'token': discordWebSoket.sessionToken,
            'session_id': discordWebSoket.sessionId,
            'seq': discordWebSoket.getlastSequence(),
          },
          eventName: null,
          sequence: null,
        );

        discordWebSoket.sendMessage(gatewayMessage);
        discordWebSoket.removeListener(listenerName: 'on_resume_hadler');
      },
    );
    logger.info(
      'Closing connection for reconnect',
      name: 'DWS: ReconnectHandler',
    );
    discordWebSoket.closeConnection();

    return GatewayHandlerData(operationCode: 7, error: null, data: {
      'reconnect': true,
    });
  }
}
