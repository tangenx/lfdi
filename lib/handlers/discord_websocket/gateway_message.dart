import 'dart:convert';

class DiscordGatewayMessage {
  /// opcode for the payload
  ///
  /// the `op` in the message
  final int operationCode;

  /// event data
  ///
  /// the `d` in the message
  ///
  /// the type is `dynamic` cuz discord sends int OR object (map)
  final dynamic data;

  /// sequence number, used for resuming sessions and heartbeats
  ///
  /// the `s` in the message
  final int? sequence;

  /// the event name for this payload
  ///
  /// the `t` in the message
  final String? eventName;

  DiscordGatewayMessage({
    required this.operationCode,
    required this.data,
    required this.eventName,
    required this.sequence,
  });

  DiscordGatewayMessage.fromWebSocketMessage(Map<dynamic, dynamic> message)
      : this(
          eventName: message['t'],
          sequence: message['s'],
          operationCode: message['op'],
          data: message['d'],
        );

  Map<dynamic, dynamic> toMap() {
    return {
      'op': operationCode,
      'd': data,
      's': sequence,
      't': eventName,
    };
  }

  String toJsonString() {
    return jsonEncode(toMap());
  }
}
