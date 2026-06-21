import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchSettingsScreen extends StatefulWidget {
  final VoidCallback onSaved;
  const WatchSettingsScreen({super.key, required this.onSaved});

  @override
  State<WatchSettingsScreen> createState() => _WatchSettingsScreenState();
}

class _WatchSettingsScreenState extends State<WatchSettingsScreen> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '50051');
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _hostController.text = prefs.getString('server_host') ?? '';
    _portController.text = '${prefs.getInt('server_port') ?? 50051}';
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text) ?? 50051;
    if (host.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_host', host);
    await prefs.setInt('server_port', port);

    if (mounted) widget.onSaved();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Server',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _hostController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'your-server-ip',
                  hintStyle: TextStyle(color: Colors.white30),
                  labelText: 'Host',
                  labelStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _portController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: '50051',
                  hintStyle: TextStyle(color: Colors.white30),
                  labelText: 'Port',
                  labelStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Connect'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
