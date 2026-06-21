import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _deviceIdController = TextEditingController();
  double _minDistance = 5;
  int? _speedLimitKmh;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _hostController.text = prefs.getString('server_host') ?? '';
    _portController.text = '${prefs.getInt('server_port') ?? 50051}';
    _apiKeyController.text = prefs.getString('api_key') ?? '';
    _deviceIdController.text = prefs.getString('device_id') ?? 'phone-default';
    setState(() {
      _minDistance = prefs.getDouble('min_distance') ?? 5;
      _speedLimitKmh = prefs.getInt('speed_limit_kmh');
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_host', _hostController.text.trim());
    await prefs.setInt('server_port', int.tryParse(_portController.text) ?? 50051);
    await prefs.setString('api_key', _apiKeyController.text.trim());
    await prefs.setString('device_id', _deviceIdController.text.trim());
    await prefs.setDouble('min_distance', _minDistance);
    if (_speedLimitKmh != null) {
      await prefs.setInt('speed_limit_kmh', _speedLimitKmh!);
    } else {
      await prefs.remove('speed_limit_kmh');
    }

    // Update location service
    LocationService().setMinDistance(_minDistance);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _apiKeyController.dispose();
    _deviceIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Server section
          const Text('Server Connection',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          TextField(
            controller: _hostController,
            decoration: const InputDecoration(
              labelText: 'Server Host',
              hintText: 'your-server-ip',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.dns),
            ),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _portController,
            decoration: const InputDecoration(
              labelText: 'gRPC Port',
              hintText: '50051',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.numbers),
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _apiKeyController,
            decoration: const InputDecoration(
              labelText: 'API Key',
              hintText: 'your-secret-key',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.key),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _deviceIdController,
            decoration: const InputDecoration(
              labelText: 'Device ID',
              hintText: 'phone-default',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone_android),
            ),
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // GPS section
          const Text('GPS Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'Minimum distance between recorded points. Lower = more precise, higher = less battery.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(Icons.straighten, size: 20, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Slider(
                  value: _minDistance,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  label: '${_minDistance.toStringAsFixed(0)} m',
                  onChanged: (v) => setState(() => _minDistance = v),
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  '${_minDistance.toStringAsFixed(0)} m',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Adaptive GPS Profiles',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                _profileRow('Stationary', '15s interval, 30m filter', Colors.grey),
                _profileRow('Walking', '5s interval, 10m filter', Colors.green),
                _profileRow('Running/Cycling', '3s interval, 8m filter', Colors.blue),
                _profileRow('City Driving', '2s interval, 15m filter', Colors.orange),
                _profileRow('Highway', '5s interval, 50m filter', Colors.red),
                const Divider(height: 16),
                _profileRow('Low Battery (<20%)', '10s interval, 30m filter', Colors.amber),
                _profileRow('Critical Battery (<10%)', '30s interval, 100m filter', Colors.red.shade900),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // Speed limit section
          const Text('Speed Alert',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'Vibrate when exceeding speed limit. Set to 0 to disable.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(Icons.speed, size: 20, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Slider(
                  value: (_speedLimitKmh ?? 0).toDouble(),
                  min: 0,
                  max: 200,
                  divisions: 40,
                  label: _speedLimitKmh != null && _speedLimitKmh! > 0
                      ? '$_speedLimitKmh km/h'
                      : 'Disabled',
                  onChanged: (v) => setState(() {
                    _speedLimitKmh = v > 0 ? v.round() : null;
                  }),
                ),
              ),
              SizedBox(
                width: 70,
                child: Text(
                  _speedLimitKmh != null && _speedLimitKmh! > 0
                      ? '$_speedLimitKmh km/h'
                      : 'Off',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          FilledButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            label: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }

  Widget _profileRow(String name, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Text(desc, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
