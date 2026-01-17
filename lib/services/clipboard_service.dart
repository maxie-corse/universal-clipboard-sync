import 'dart:async';
import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../data/database/db.dart';

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
      final String? content =
          await FlutterClipboard.paste();

      if (content == null || content.isEmpty) return;

      // If same as last, ignore
      if (content == _lastContent) return;

      _lastContent = content;

      await _saveClipboardEvent(content);
    } catch (e) {
      // Ignore clipboard errors silently for now
    }
  }

  static Future<void> _saveClipboardEvent(String content) async {
    final String eventId = const Uuid().v4();
    final int timestamp = DateTime.now().millisecondsSinceEpoch;

    // SHA-256 hash
    final String contentHash =
        sha256.convert(utf8.encode(content)).toString();

    await AppDatabase.insertClipboardEvent(
      eventId: eventId,
      deviceId: 'local', // placeholder for now
      timestamp: timestamp,
      contentHash: contentHash,
      content: content,
      type: 'text',
    );

    print('Clipboard event saved');
  }
}

/// lutter does NOT give real OS clipboard “events”
/// So we do this instead:
/// Poll clipboard every 500–1000 ms
/// Compare with last value
/// If changed → treat as new event 
