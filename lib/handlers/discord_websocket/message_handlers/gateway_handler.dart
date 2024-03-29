// Default Handler class, used for extending other Handlers
import 'package:lfdi/handlers/discord_websocket/discord_websocket.dart';
import 'package:lfdi/handlers/discord_websocket/gateway_message.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/handler_data.dart';

abstract class GatewayHandler {
  DiscordGatewayMessage? message;

  /// Sets up gateway message to Handler
  void setUpMessage(DiscordGatewayMessage gatewayMessage) {
    message = gatewayMessage;
  }

  /// All handlers must return data, regardless of whether they are empty
  ///
  /// All handlers resieves their `messages`,
  /// so they can manipulate them
  /// (or just return they in GatewayHandlerData, why not?)
  GatewayHandlerData handle(
    DiscordWebSoket discordWebSoket,
  ) {
    return GatewayHandlerData(
      operationCode: 999,
      data: null,
      error: null,
    );
  }
}
