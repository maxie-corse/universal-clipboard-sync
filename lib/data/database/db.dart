import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'tables.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String dbPath = p.join(dir.path, 'clipboard_sync.db');

    final db = sqlite3.open(dbPath);

    db.execute(Tables.devices);
    db.execute(Tables.clipboardEvents);
    db.execute(Tables.syncState);

    return db;
  }

  /* ===============================
     CLIPBOARD EVENTS
     =============================== */

  static Future<void> insertClipboardEvent({
    required String eventId,
    required String deviceId,
    required int timestamp,
    required String contentHash,
    required String content,
    required String type,
  }) async {
    final db = await instance;

    final stmt = db.prepare('''
      INSERT OR IGNORE INTO clipboard_events
      (event_id, device_id, timestamp, content_hash, content, type)
      VALUES (?, ?, ?, ?, ?, ?)
    ''');

    stmt.execute([eventId, deviceId, timestamp, contentHash, content, type]);

    stmt.dispose();
  }

  static Future<List<Map<String, Object?>>> getClipboardHistory({
    int limit = 50,
  }) async {
    final db = await instance;

    final ResultSet result = db.select(
      '''
      SELECT *
      FROM clipboard_events
      ORDER BY timestamp DESC
      LIMIT ?
    ''',
      [limit],
    );

    return result.map((row) => row).toList();
  }

  static Future<bool> eventExists(String contentHash) async {
    final db = await instance;

    final result = db.select(
      'SELECT 1 FROM clipboard_events WHERE content_hash = ? LIMIT 1',
      [contentHash],
    );

    return result.isNotEmpty;
  }

  /* ===============================
     SYNC STATE
     =============================== */

  static Future<void> markEventPendingSync({
    required String eventId,
    required String targetDeviceId,
  }) async {
    final db = await instance;

    final stmt = db.prepare('''
      INSERT OR IGNORE INTO sync_state
      (event_id, target_device_id, synced)
      VALUES (?, ?, 0)
    ''');

    stmt.execute([eventId, targetDeviceId]);
    stmt.dispose();
  }

  static Future<void> markEventSynced({
    required String eventId,
    required String targetDeviceId,
  }) async {
    final db = await instance;

    db.execute(
      '''
      UPDATE sync_state
      SET synced = 1
      WHERE event_id = ? AND target_device_id = ?
    ''',
      [eventId, targetDeviceId],
    );
  }

  static Future<List<Map<String, Object?>>> getPendingSyncEvents() async {
    final db = await instance;

    final result = db.select('''
      SELECT ce.*
      FROM clipboard_events ce
      JOIN sync_state ss
      ON ce.event_id = ss.event_id
      WHERE ss.synced = 0
    ''');

    return result.map((row) => row).toList();
  }
}
