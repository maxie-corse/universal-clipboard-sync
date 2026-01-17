import 'package:uuid/uuid.dart';

enum MessageType {
  hello,
  eventList,
  requestEvent,
  sendEvent,
  ack,
}

class ProtocolMessage {
  final String version;
  final String messageId;
  final String from;
  final MessageType type;
  final Map<String, dynamic> payload;

  ProtocolMessage({
    this.version = '1.0',
    String? messageId,
    required this.from,
    required this.type,
    required this.payload,
  }) : messageId = messageId ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'version': version,
        'messageId': messageId,
        'from': from,
        'type': type.name,
        'payload': payload,
      };

  static ProtocolMessage fromJson(Map<String, dynamic> json) {
    return ProtocolMessage(
      version: json['version'] ?? '1.0',
      messageId: json['messageId'],
      from: json['from'],
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      payload: Map<String, dynamic>.from(json['payload'] ?? {}),
    );
  }
}
