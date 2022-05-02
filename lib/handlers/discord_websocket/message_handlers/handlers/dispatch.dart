import 'package:lfdi/handlers/discord_websocket/message_handlers/gateway_handler.dart';
import 'package:lfdi/handlers/discord_websocket/message_handlers/handler_data.dart';
import 'package:web_socket_channel/io.dart';

/// Handles the Dispatch operation (OP Code: `0`)
class DispatchHandler extends GatewayHandler {
  @override
  GatewayHandlerData handle(
    IOWebSocketChannel channel,
    Function getLastSequence,
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

// So, here is a list of Gateway Event names

/// The client gets when the activity changes from one to the other.
///
/// `d` data is a list of objects,
/// where the first object is the activities that change,
/// and the second is the activities that are set.
///
/// There is also a third object, but it has no activity.
//const String sessionsReplace = 'SESSIONS_REPLACE';

/// Guild changes the state of any voice chat.
//const String voiceStateUpdate = 'VOICE_STATE_UPDATE';

/// Huge list of unread messages in text channels
//const String channelUnreadUpdate = 'CHANNEL_UNREAD_UPDATE';

/// There is a new message somewhere.
/// The data contains the message object.
//const String messageCreate = 'MESSAGE_CREATE';

/// Someone puts a reaction to a message
//const String messageReactionAdd = 'MESSAGE_REACTION_ADD';

/// Someone's Presence changes
//const String presenceUpdate = 'PRESENCE_UPDATE';

// As I was writing these constants,
// I realized that the sequence number is just a counter.
// Huh.
