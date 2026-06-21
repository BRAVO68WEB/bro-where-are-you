import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/grpc_service.dart';

enum AuthStep { serverUrl, connecting, deviceCode, polling, done }

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;
  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '50051');
  AuthStep _step = AuthStep.serverUrl;
  String? _error;
  String? _deviceCode;
  int _expiresInSeconds = 0;
  Timer? _pollTimer;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _loadSavedServer();
  }

  Future<void> _loadSavedServer() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('server_host') ?? '';
    final port = prefs.getInt('server_port') ?? 50051;
    if (host.isNotEmpty) {
      _hostController.text = host;
      _portController.text = '$port';
    }
  }

  Future<void> _connectToServer() async {
    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 50051;

    if (host.isEmpty) {
      setState(() => _error = 'Enter server address');
      return;
    }

    setState(() {
      _step = AuthStep.connecting;
      _error = null;
    });

    try {
      // Health check via HTTP (skip for gRPC-only port 443)
      if (port != 443) {
        final uri = Uri.parse('http://$host:$port/health');
        final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
        final request = await client.getUrl(uri);
        final response = await request.close();
        client.close();

        if (response.statusCode != 200) {
          throw Exception('Server returned ${response.statusCode}');
        }
      }

      // Save server config
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('server_host', host);
      await prefs.setInt('server_port', port);

      // Initialize gRPC
      await GrpcService().init();

      // Request device code
      await _requestDeviceCode();
    } catch (e) {
      setState(() {
        _step = AuthStep.serverUrl;
        _error = 'Cannot reach server: $e';
      });
    }
  }

  Future<void> _requestDeviceCode() async {
    try {
      final resp = await GrpcService().requestDeviceCode(
        deviceName: await _getDeviceName(),
        platform: Platform.isAndroid ? 'android' : 'ios',
      );

      setState(() {
        _deviceCode = resp.deviceCode;
        _step = AuthStep.deviceCode;
        _expiresInSeconds = ((resp.expiresAt.toInt() - DateTime.now().millisecondsSinceEpoch) / 1000).round();
      });

      // Start countdown
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_expiresInSeconds > 0) {
          setState(() => _expiresInSeconds--);
        } else {
          _countdownTimer?.cancel();
          setState(() => _step = AuthStep.serverUrl);
        }
      });

      // Start polling
      _startPolling(resp.deviceCode);
    } catch (e) {
      setState(() {
        _step = AuthStep.serverUrl;
        _error = 'Failed to get device code: $e';
      });
    }
  }

  void _startPolling(String deviceCode) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final result = await GrpcService().pollDeviceActivation(deviceCode);
        if (result.activated && result.deviceToken.isNotEmpty) {
          _pollTimer?.cancel();
          _countdownTimer?.cancel();

          // Save JWT and device info
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', result.deviceToken);
          await prefs.setString('device_id', result.deviceId);
          await prefs.setString('device_name', result.deviceName);

          // Reinitialize gRPC with JWT
          await GrpcService().init();

          setState(() => _step = AuthStep.done);

          // Navigate to home after brief delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) widget.onAuthenticated();
          });
        }
      } catch (_) {
        // Poll failed — keep retrying
      }
    });
  }

  Future<String> _getDeviceName() async {
    try {
      final info = Platform.version;
      return info.length > 30 ? '${info.substring(0, 30)}...' : info;
    } catch (_) {
      return 'Flutter Device';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / Title
              const Icon(Icons.location_on, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              const Text('Bro Where Are You',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Commute & Journey Tracker',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 48),

              // Step content
              ..._buildStepContent(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStepContent() {
    switch (_step) {
      case AuthStep.serverUrl:
        return _buildServerUrlStep();
      case AuthStep.connecting:
        return _buildConnectingStep();
      case AuthStep.deviceCode:
        return _buildDeviceCodeStep();
      case AuthStep.polling:
        return _buildPollingStep();
      case AuthStep.done:
        return _buildDoneStep();
    }
  }

  List<Widget> _buildServerUrlStep() {
    return [
      const Text('Connect to Server',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 24),
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
          labelText: 'Port',
          hintText: '443 for HTTPS, 50051 for local',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.numbers),
        ),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _connectToServer(),
      ),
      if (_error != null) ...[
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade900.withAlpha(40),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade700),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red))),
            ],
          ),
        ),
      ],
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton.icon(
          onPressed: _connectToServer,
          icon: const Icon(Icons.wifi),
          label: const Text('Connect'),
        ),
      ),
    ];
  }

  List<Widget> _buildConnectingStep() {
    return [
      const CircularProgressIndicator(),
      const SizedBox(height: 24),
      const Text('Connecting to server...',
          style: TextStyle(fontSize: 16)),
      const SizedBox(height: 8),
      Text('${_hostController.text}:${_portController.text}',
          style: const TextStyle(color: Colors.grey)),
    ];
  }

  List<Widget> _buildDeviceCodeStep() {
    final minutes = _expiresInSeconds ~/ 60;
    final seconds = _expiresInSeconds % 60;
    return [
      const Text('Pair Your Device',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 16),
      const Text('Enter this code in the web portal:',
          style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 24),
      // Device code display
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.green.shade900.withAlpha(40),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Column(
          children: [
            Text(_deviceCode ?? '------',
                style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                    fontFamily: 'monospace')),
            const SizedBox(height: 8),
            Text('Expires in $minutes:${seconds.toString().padLeft(2, '0')}',
                style: TextStyle(
                    color: _expiresInSeconds < 60 ? Colors.red : Colors.grey)),
          ],
        ),
      ),
      const SizedBox(height: 16),
      // Copy button
      TextButton.icon(
        onPressed: () {
          if (_deviceCode != null) {
            Clipboard.setData(ClipboardData(text: _deviceCode!));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Code copied')),
            );
          }
        },
        icon: const Icon(Icons.copy, size: 16),
        label: const Text('Copy Code'),
      ),
      const SizedBox(height: 24),
      // Polling indicator
      const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 8),
          Text('Waiting for activation...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    ];
  }

  List<Widget> _buildPollingStep() {
    return [
      const CircularProgressIndicator(),
      const SizedBox(height: 24),
      const Text('Activating...', style: TextStyle(fontSize: 16)),
    ];
  }

  List<Widget> _buildDoneStep() {
    return [
      const Icon(Icons.check_circle, size: 64, color: Colors.green),
      const SizedBox(height: 24),
      const Text('Device Paired!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      const Text('Redirecting...', style: TextStyle(color: Colors.grey)),
    ];
  }
}
