class Tables {
  static const devices = '''
    CREATE TABLE IF NOT EXISTS devices (
      device_id TEXT PRIMARY KEY,
      name TEXT,
      public_key TEXT,
      last_seen INTEGER,
      is_online INTEGER
    );
  ''';

  static const clipboardEvents = '''
    CREATE TABLE IF NOT EXISTS clipboard_events (
      event_id TEXT PRIMARY KEY,
      device_id TEXT,
      timestamp INTEGER,
      content_hash TEXT,
      content TEXT,
      type TEXT
    );
  ''';

  static const syncState = '''
    CREATE TABLE IF NOT EXISTS sync_state (
      event_id TEXT,
      target_device_id TEXT,
      synced INTEGER,
      PRIMARY KEY (event_id, target_device_id)
    );
  ''';

  static const settings = ''' 
    CREATE TABLE IF NOT EXISTS settings (
      key TEXT PRIMARY KEY,
      value TEXT
    );
  ''';
}
