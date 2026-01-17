import '../network/webrtc_connection.dart';
import '../network/protocol.dart';
import '../data/database/db.dart';

class SyncService {
  final WebRTCConnection connection;
  final String localDeviceId;

  SyncService({
    required this.connection,
    required this.localDeviceId,
  });

  /// Call this AFTER WebRTC DataChannel is open
  void start() {
    connection.onMessage = handleMessage;

    // Send HELLO immediately on connection
    _sendHello();
  }

  /* ===============================
     MESSAGE DISPATCHER
     =============================== */

  void handleMessage(ProtocolMessage message) {
    switch (message.type) {
      case MessageType.hello:
        _handleHello(message);
        break;

      case MessageType.eventList:
        _handleEventList(message);
        break;

      case MessageType.requestEvent:
        _handleRequestEvent(message);
        break;

      case MessageType.sendEvent:
        _handleSendEvent(message);
        break;

      case MessageType.ack:
        _handleAck(message);
        break;
    }
  }

  /* ===============================
     HELLO
     =============================== */

  void _sendHello() {
    connection.sendMessage(
      ProtocolMessage(
        from: localDeviceId,
        type: MessageType.hello,
        payload: {},
      ),
    );
  }

  void _handleHello(ProtocolMessage message) async {
    // On HELLO, send our event ID list
    final eventIds = await AppDatabase.getAllEventIds();

    connection.sendMessage(
      ProtocolMessage(
        from: localDeviceId,
        type: MessageType.eventList,
        payload: {
          'eventIds': eventIds,
        },
      ),
    );
  }

  /* ===============================
     EVENT LIST
     =============================== */

  void _handleEventList(ProtocolMessage message) async {
    final List<dynamic> remoteIds = message.payload['eventIds'] ?? [];

    final localIds = await AppDatabase.getAllEventIds();

    // Find missing events
    final missing = remoteIds
        .where((id) => !localIds.contains(id))
        .cast<String>()
        .toList();

    for (final eventId in missing) {
      connection.sendMessage(
        ProtocolMessage(
          from: localDeviceId,
          type: MessageType.requestEvent,
          payload: {
            'eventId': eventId,
          },
        ),
      );
    }
  }

  /* ===============================
     REQUEST EVENT
     =============================== */

  void _handleRequestEvent(ProtocolMessage message) async {
    final String eventId = message.payload['eventId'];

    final event = await AppDatabase.getClipboardEventById(eventId);
    if (event == null) return;

    connection.sendMessage(
      ProtocolMessage(
        from: localDeviceId,
        type: MessageType.sendEvent,
        payload: event,
      ),
    );
  }

  /* ===============================
     SEND EVENT
     =============================== */

  void _handleSendEvent(ProtocolMessage message) async {
    final data = message.payload;

    await AppDatabase.insertClipboardEvent(
      eventId: data['event_id'],
      deviceId: data['device_id'],
      timestamp: data['timestamp'],
      contentHash: data['content_hash'],
      content: data['content'],
      type: data['type'],
    );

    connection.sendMessage(
      ProtocolMessage(
        from: localDeviceId,
        type: MessageType.ack,
        payload: {
          'eventId': data['event_id'],
        },
      ),
    );
  }

  /* ===============================
     ACK
     =============================== */

  void _handleAck(ProtocolMessage message) async {
    final String eventId = message.payload['eventId'];
    final String target = message.from;

    await AppDatabase.markEventSynced(
      eventId: eventId,
      targetDeviceId: target,
    );
  }
}
