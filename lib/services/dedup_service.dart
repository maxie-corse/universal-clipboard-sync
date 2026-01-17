import '../data/database/db.dart';

class DedupService {
  static const int windowMs = 5000; // 5 seconds

  /// Returns true if this event is a duplicate
  static Future<bool> isDuplicate({
    required String contentHash,
    required int timestamp,
  }) async {
    final recent = await AppDatabase.getRecentEventsByHash(
      contentHash,
      since: timestamp - windowMs,
    );

    if (recent.isEmpty) return false;

    // If any event is within the time window, it's a duplicate
    for (final event in recent) {
      final int existingTs = event['timestamp'];
      if ((existingTs - timestamp).abs() < windowMs) {
        return true;
      }
    }

    return false;
  }
}
