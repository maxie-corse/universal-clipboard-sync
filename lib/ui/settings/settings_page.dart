import 'package:flutter/material.dart';
import '../../data/database/db.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _syncEnabled = true;
  int _maxSize = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final sync =
        await AppDatabase.getSetting('sync_enabled') ?? 'true';
    final size =
        await AppDatabase.getSetting('max_clipboard_size') ?? '0';

    setState(() {
      _syncEnabled = sync == 'true';
      _maxSize = int.tryParse(size) ?? 0;
    });
  }

  Future<void> _saveSync(bool value) async {
    await AppDatabase.setSetting(
      'sync_enabled',
      value.toString(),
    );
    setState(() => _syncEnabled = value);
  }

  Future<void> _saveMaxSize(int value) async {
    await AppDatabase.setSetting(
      'max_clipboard_size',
      value.toString(),
    );
    setState(() => _maxSize = value);
  }

  Future<void> _clearHistory() async {
    await AppDatabase.clearHistory();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('History cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Sync'),
            value: _syncEnabled,
            onChanged: _saveSync,
          ),
          ListTile(
            title: const Text('Max Clipboard Size'),
            subtitle: Text(
              _maxSize == 0 ? 'Unlimited' : '$_maxSize characters',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _changeMaxSize,
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text(
              'Clear History',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _clearHistory,
          ),
        ],
      ),
    );
  }

  Future<void> _changeMaxSize() async {
    final controller =
        TextEditingController(text: _maxSize.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Max Clipboard Size'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: '0 = unlimited',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              int.tryParse(controller.text) ?? 0,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _saveMaxSize(result);
    }
  }
}
