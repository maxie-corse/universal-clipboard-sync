class Device {
  final String deviceId;
  final String name;
  final String publicKey;
  final int lastSeen;
  final bool isOnline;

  Device({
    required this.deviceId,
    required this.name,
    required this.publicKey,
    required this.lastSeen,
    required this.isOnline,
  });

  Map<String, Object?> toMap() => {
        'device_id': deviceId,
        'name': name,
        'public_key': publicKey,
        'last_seen': lastSeen,
        'is_online': isOnline ? 1 : 0,
      };
}
