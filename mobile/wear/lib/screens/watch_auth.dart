import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grpc/grpc.dart';
import '../generated/location/v1/location.pbgrpc.dart';

enum _AuthStep { serverUrl, connecting, deviceCode, done }

class WatchAuthScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;
  const WatchAuthScreen({super.key, required this.onAuthenticated});

  @override
  State<WatchAuthScreen> createState() => _WatchAuthScreenState();
}

class _WatchAuthScreenState extends State<WatchAuthScreen> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '50051');
  _AuthStep _step = _AuthStep.serverUrl;
  String? _error;
  String? _deviceCode;
  int _expiresInSeconds = 0;
  Timer? _pollTimer;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    _hostController.text = prefs.getString('server_host') ?? '';
    _portController.text = '${prefs.getInt('server_port') ?? 50051}';
  }

  Future<void> _connect() async {
    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 50051;
    if (host.isEmpty) {
      setState(() => _error = 'Enter server address');
      return;
    }

    setState(() {
      _step = _AuthStep.connecting;
      _error = null;
    });

    try {
      // Health check on HTTP port (8088)
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
      final req = await client.getUrl(Uri.parse('http://$host:8088/health'));
      final resp = await req.close();
      client.close();
      if (resp.statusCode != 200) throw Exception('Server error ${resp.statusCode}');

      // Save
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('server_host', host);
      await prefs.setInt('server_port', port);

      // Request device code
      final channel = ClientChannel(
        host,
        port: port,
        options: ChannelOptions(credentials: ChannelCredentials.insecure()),
      );
      final stub = LocationServiceClient(channel);
      final resp2 = await stub.requestDeviceCode(
        DeviceCodeRequest()
          ..deviceName = 'Galaxy Watch'
          ..platform = 'wearos',
      );

      setState(() {
        _deviceCode = resp2.deviceCode;
        _step = _AuthStep.deviceCode;
        _expiresInSeconds = ((resp2.expiresAt.toInt() - DateTime.now().millisecondsSinceEpoch) / 1000).round();
      });

      // Countdown
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_expiresInSeconds > 0) {
          setState(() => _expiresInSeconds--);
        } else {
          _countdownTimer?.cancel();
          setState(() => _step = _AuthStep.serverUrl);
        }
      });

      // Poll for activation
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
        try {
          final result = await stub.pollDeviceActivation(
            PollActivationRequest()..deviceCode = resp2.deviceCode,
          );
          if (result.activated && result.deviceToken.isNotEmpty) {
            _pollTimer?.cancel();
            _countdownTimer?.cancel();

            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('jwt_token', result.deviceToken);
            await prefs.setString('device_id', result.deviceId);

            setState(() => _step = _AuthStep.done);
            await channel.shutdown();

            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) widget.onAuthenticated();
            });
          }
        } catch (_) {}
      });
    } catch (e) {
      setState(() {
        _step = _AuthStep.serverUrl;
        _error = 'Failed: $e';
      });
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _AuthStep.serverUrl:
        return _buildServerUrl();
      case _AuthStep.connecting:
        return _buildConnecting();
      case _AuthStep.deviceCode:
        return _buildDeviceCode();
      case _AuthStep.done:
        return _buildDone();
    }
  }

  Widget _buildServerUrl() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        const Icon(Icons.location_on, color: Color(0xFFfaff69), size: 28),
        const SizedBox(height: 4),
        const Text('BWhere', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: _hostController,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
            hintText: 'your-server-ip',
            hintStyle: const TextStyle(color: Colors.white30),
            labelText: 'Host',
            labelStyle: const TextStyle(color: Colors.white54, fontSize: 10),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            isDense: true,
          ),
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _portController,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
            hintText: '50051',
            hintStyle: const TextStyle(color: Colors.white30),
            labelText: 'Port',
            labelStyle: const TextStyle(color: Colors.white54, fontSize: 10),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            isDense: true,
          ),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _connect(),
        ),
        if (_error != null) ...[
          const SizedBox(height: 4),
          Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 10)),
        ],
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 36,
          child: ElevatedButton(
            onPressed: _connect,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFfaff69),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 0),
            ),
            child: const Text('Connect', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
      ],
    ),
    );
  }

  Widget _buildConnecting() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 12),
        Text('Connecting...', style: TextStyle(color: Colors.white54, fontSize: 13)),
      ],
    );
  }

  Widget _buildDeviceCode() {
    final m = _expiresInSeconds ~/ 60;
    final s = _expiresInSeconds % 60;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Pair Device', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Enter in web portal:', style: TextStyle(color: Colors.white54, fontSize: 10)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFfaff69), width: 2),
          ),
          child: Column(
            children: [
              Text(
                _deviceCode ?? '------',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                  fontFamily: 'monospace',
                  color: Color(0xFFfaff69),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$m:${s.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 10,
                  color: _expiresInSeconds < 60 ? Colors.red : Colors.white38,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 6),
            Text('Waiting...', style: TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildDone() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, color: Color(0xFF22c55e), size: 40),
        SizedBox(height: 8),
        Text('Paired!', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
