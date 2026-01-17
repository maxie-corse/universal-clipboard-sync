import 'dart:async';
import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../data/database/db.dart';
import 'dedup_service.dart';

class ClipboardService {
  static Timer? _timer;
  static String? _lastContent;

  /// Start listening to clipboard changes
  static void start() {
    _timer = Timer.periodic(
      const Duration(milliseconds: 800),
      (_) async {
        await _checkClipboard();
      },
    );
  }

  /// Stop listening (not used yet, but good practice)
  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<void> _checkClipboard() async {
    try {
      final content = await FlutterClipboard.paste();

      if (content.isEmpty) return;

      // If same as last, ignore
      if (content == _lastContent) return;

      _lastContent = content;

      await _saveClipboardEvent(content);
    } catch (_) {
      // Ignore clipboard errors silently
    }
  }

  static Future<void> _saveClipboardEvent(String content) async {
    // 1️⃣ Timestamp
    final int timestamp = DateTime.now().millisecondsSinceEpoch;

    // 2️⃣ Hash content
    final String contentHash =
        sha256.convert(utf8.encode(content)).toString();

    // 3️⃣ Dedup check
    final bool isDup = await DedupService.isDuplicate(
      contentHash: contentHash,
      timestamp: timestamp,
    );

    if (isDup) {
      return;
    }

    // 4️⃣ Event ID
    final String eventId = const Uuid().v4();

    // 5️⃣ Insert into DB
    await AppDatabase.insertClipboardEvent(
      eventId: eventId,
      deviceId: 'local',
      timestamp: timestamp,
      contentHash: contentHash,
      content: content,
      type: 'text',
    );

    // Dev-only log
    // ignore: avoid_print
    print('Clipboard event saved');
  }
}

/// flutter does NOT give real OS clipboard “events”
/// So we do this instead:
/// Poll clipboard every 500–1000 ms
/// Compare with last value
/// If changed → treat as new event
