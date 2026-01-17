import 'package:flutter/material.dart';
import '../../data/database/db.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  List<Map<String, dynamic>> _devices = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final devices = await AppDatabase.getAllDevices();
    setState(() {
      _devices = devices;
    });
  }

  bool _isOnline(int lastSeen) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - lastSeen) < 15000;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDevices),
        ],
      ),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          final d = _devices[index];
          final online = _isOnline(d['last_seen']);

          return ListTile(
            leading: Icon(
              Icons.devices,
              color: online ? Colors.green : Colors.grey,
            ),
            title: Text(d['name'] ?? d['device_id']),
            subtitle: Text(
              online ? 'Online' : 'Last seen ${_formatTime(d['last_seen'])}',
            ),
            onLongPress: () {
              _confirmRemoveDevice(context, d['device_id']);
            },
          );
        },
      ),
    );
  }

  String _formatTime(int ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmRemoveDevice(
    BuildContext context,
    String deviceId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove device'),
        content: const Text(
          'This device will be unpaired and sync data will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AppDatabase.deleteDevice(deviceId);
      await _loadDevices();
    }
  }
}
