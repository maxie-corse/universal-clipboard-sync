import 'package:flutter/material.dart';

import '../../data/database/db.dart';
import '../../services/clipboard_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, Object?>> _events = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  /// Initialize database + clipboard listener
  Future<void> _init() async {
    try {
      await AppDatabase.instance;
      ClipboardService.start();
      await _loadHistory();

      setState(() {
        _initialized = true;
      });
    } catch (e) {
      debugPrint('HistoryPage init error: $e');
    }
  }

  /// Load clipboard history from local DB
  Future<void> _loadHistory() async {
    final events = await AppDatabase.getClipboardHistory(limit: 100);
    setState(() {
      _events = events;
    });
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Loading state (prevents Flutter logo freeze)
    if (!_initialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clipboard History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _events.isEmpty
          ? const Center(
              child: Text('No clipboard history yet'),
            )
          : ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];

                return ListTile(
                  title: Text(
                    event['content'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'Device: ${event['device_id']} • '
                    'Time: ${_formatTime(event['timestamp'] as int)}',
                  ),
                );
              },
            ),
    );
  }
}
