import 'package:lfdi/handlers/discord_websocket/message_handlers/handlers/dispatch.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/handlers/heartbeat_ack.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/handlers/hello.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/handlers/invalid_session.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/handlers/reconnect.dart';

class GatewayHandlerFactory {
  GatewayHandlerFactory();

  final Map<String, Object Function()> instances = {
    // OP Code 0
    'DispatchHandler': () => DispatchHandler(),
    // OP Code 7
    'ReconnectHandler': () => ReconnectHandler(),
    // OP Code 9
    'InvalidSessionHandler': () => InvalidSessionHandler(),
    // OP Code 10
    'HelloHandler': () => HelloHandler(),
    // OP Code 11
    'HeartbeatACKHandler': () => HeartbeatACKHandler(),
  };

  dynamic getHandlerByOpcode(int operationCode) {
    if (operationCode == 0) {
      return instances['DispatchHandler']!();
    }

    if (operationCode == 7) {
      return instances['ReconnectHandler']!();
    }

    if (operationCode == 9) {
      return instances['InvalidSessionHandler']!();
    }

    if (operationCode == 10) {
      return instances['HelloHandler']!();
    }

    if (operationCode == 11) {
      return instances['HeartbeatACKHandler']!();
    }

    return null;
  }
}
