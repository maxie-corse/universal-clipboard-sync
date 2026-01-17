class ClipboardEvent {
  final String eventId;
  final String deviceId;
  final int timestamp;
  final String contentHash;
  final String content;
  final String type;

  ClipboardEvent({
    required this.eventId,
    required this.deviceId,
    required this.timestamp,
    required this.contentHash,
    required this.content,
    required this.type,
  });

  Map<String, Object?> toMap() => {
        'event_id': eventId,
        'device_id': deviceId,
        'timestamp': timestamp,
        'content_hash': contentHash,
        'content': content,
        'type': type,
      };
}
