import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grpc/grpc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../generated/location/v1/location.pb.dart';
import '../generated/location/v1/location.pbgrpc.dart';
import 'package:fixnum/fixnum.dart';

class WatchHomeScreen extends StatefulWidget {
  final bool isAmbient;
  const WatchHomeScreen({super.key, required this.isAmbient});

  @override
  State<WatchHomeScreen> createState() => _WatchHomeScreenState();
}

class _WatchHomeScreenState extends State<WatchHomeScreen> {
  bool _isTracking = false;
  double _speed = 0;
  double _distance = 0;
  int _pointCount = 0;
  LatLng? _currentPos;
  DateTime? _trackingStart;
  String? _journeyId;

  // gRPC
  ClientChannel? _channel;
  LocationServiceClient? _stub;
  StreamController<LocationUpdate>? _streamController;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _initGrpc();
  }

  Future<void> _initGrpc() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('server_host') ?? '';
    final port = prefs.getInt('server_port') ?? 50051;
    final jwt = prefs.getString('jwt_token') ?? '';

    if (host.isEmpty) return;

    _channel = ClientChannel(
      host,
      port: port,
      options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        keepAlive: ClientKeepAliveOptions(
          pingInterval: Duration(seconds: 20),
          timeout: Duration(seconds: 10),
          permitWithoutCalls: true,
        ),
      ),
    );

    final metadata = <String, String>{};
    if (jwt.isNotEmpty) {
      metadata['authorization'] = 'Bearer $jwt';
    }

    _stub = LocationServiceClient(
      _channel!,
      options: CallOptions(metadata: metadata),
    );
    debugPrint('[Watch] gRPC initialized: $host:$port (JWT: ${jwt.isNotEmpty})');
  }

  Future<void> _toggleTracking() async {
    if (_isTracking) {
      _stopTracking();
    } else {
      _startTracking();
    }
  }

  Future<void> _startTracking() async {
    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    // Start journey on server
    try {
      // Use saved device ID from auth
      final prefs = await SharedPreferences.getInstance();
      final savedDeviceId = prefs.getString('device_id') ?? 'wear-${DateTime.now().millisecondsSinceEpoch}';

      final req = StartJourneyRequest()
        ..deviceId = savedDeviceId
        ..label = 'Watch Journey';
      final journey = await _stub!.startJourney(req);
      _journeyId = journey.id;
      debugPrint('[Watch] Journey started: ${journey.id}');

      // Start gRPC stream
      _streamController = StreamController<LocationUpdate>();
      _stub!.streamLocations(_streamController!.stream);
    } catch (e) {
      debugPrint('[Watch] gRPC failed: $e');
      _journeyId = 'local-${DateTime.now().millisecondsSinceEpoch}';
    }

    setState(() {
      _isTracking = true;
      _trackingStart = DateTime.now();
      _distance = 0;
      _pointCount = 0;
    });

    // Start location timer
    _locationTimer = Timer.periodic(const Duration(seconds: 3), (_) => _captureLocation());
    await _captureLocation();
  }

  Future<void> _stopTracking() async {
    _locationTimer?.cancel();
    _locationTimer = null;

    _streamController?.close();
    _streamController = null;

    if (_journeyId != null && _stub != null) {
      try {
        final req = EndJourneyRequest()..journeyId = _journeyId!;
        await _stub!.endJourney(req);
        debugPrint('[Watch] Journey ended: $_journeyId');
      } catch (e) {
        debugPrint('[Watch] endJourney failed: $e');
      }
    }

    setState(() {
      _isTracking = false;
      _journeyId = null;
    });
  }

  Future<void> _captureLocation() async {
    if (!_isTracking) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newPos = LatLng(position.latitude, position.longitude);

      if (_currentPos != null) {
        final d = const Distance().as(LengthUnit.Meter, _currentPos!, newPos);
        if (d < 5) return;
        _distance += d;
      }

      setState(() {
        _currentPos = newPos;
        _speed = position.speed;
        _pointCount++;
      });

      // Send to server
      if (_streamController != null && !_streamController!.isClosed && _journeyId != null) {
        final prefs = await SharedPreferences.getInstance();
        final deviceId = prefs.getString('device_id') ?? 'watch';
        _streamController!.add(LocationUpdate()
          ..deviceId = deviceId
          ..journeyId = _journeyId!
          ..latitude = position.latitude
          ..longitude = position.longitude
          ..speed = position.speed
          ..accuracy = position.accuracy
          ..altitude = position.altitude
          ..heading = position.heading
          ..timestampMs = Int64(DateTime.now().millisecondsSinceEpoch)
          ..source = 'wear');
      }

      debugPrint('[Watch] ${position.latitude}, ${position.longitude} speed=${position.speed.toStringAsFixed(1)}');
    } catch (e) {
      debugPrint('[Watch] Location error: $e');
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _streamController?.close();
    _channel?.shutdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAmbient) {
      return _buildAmbientFace();
    }
    return _buildActiveFace();
  }

  Widget _buildAmbientFace() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isTracking ? Icons.gps_fixed : Icons.gps_off,
              color: _isTracking ? Colors.green : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              _isTracking ? 'TRACKING' : 'IDLE',
              style: TextStyle(
                color: _isTracking ? Colors.green : Colors.grey,
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
            if (_isTracking)
              Text(
                _formatSpeed(_speed),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFace() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isTracking ? Colors.green : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isTracking ? 'LIVE' : 'IDLE',
                    style: TextStyle(
                      color: _isTracking ? Colors.green : Colors.grey,
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_trackingStart != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      _formatDuration(DateTime.now().difference(_trackingStart!)),
                      style: const TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ],
              ),

              // Stats
              if (_isTracking)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _watchStat('SPD', _formatSpeed(_speed)),
                    _watchStat('DST', _formatDistance(_distance)),
                    _watchStat('PTS', '$_pointCount'),
                  ],
                )
              else
                const Spacer(),

              // Start/Stop
              GestureDetector(
                onTap: _toggleTracking,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isTracking ? Colors.red.shade700 : Colors.green.shade700,
                  ),
                  child: Icon(
                    _isTracking ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _watchStat(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 1)),
      ],
    );
  }

  String _formatSpeed(double mps) {
    if (mps < 0.3) return '0';
    return '${(mps * 3.6).toStringAsFixed(0)} km/h';
  }

  String _formatDistance(double m) {
    if (m >= 1000) return '${(m / 1000).toStringAsFixed(1)}km';
    return '${m.toStringAsFixed(0)}m';
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds % 60}s';
    return '${d.inSeconds}s';
  }
}
