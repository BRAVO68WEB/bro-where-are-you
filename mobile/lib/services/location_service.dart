import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'grpc_service.dart';
import 'notification_service.dart';
import 'offline_queue.dart';

enum TrackingState { idle, tracking, paused }

// Adaptive GPS intervals based on speed
class _GpsProfile {
  final int intervalMs;
  final double distanceFilter;
  final String name;

  const _GpsProfile({
    required this.intervalMs,
    required this.distanceFilter,
    required this.name,
  });

  // Stationary: not moving
  static const stationary = _GpsProfile(
    intervalMs: 15000,
    distanceFilter: 30,
    name: 'stationary',
  );

  // Walking: 1-6 km/h
  static const walking = _GpsProfile(
    intervalMs: 5000,
    distanceFilter: 10,
    name: 'walking',
  );

  // Running/Cycling: 6-25 km/h
  static const running = _GpsProfile(
    intervalMs: 3000,
    distanceFilter: 8,
    name: 'running',
  );

  // City driving: 25-60 km/h
  static const cityDriving = _GpsProfile(
    intervalMs: 2000,
    distanceFilter: 15,
    name: 'city_driving',
  );

  // Highway: 60+ km/h
  static const highway = _GpsProfile(
    intervalMs: 5000,
    distanceFilter: 50,
    name: 'highway',
  );

  // Low battery mode
  static const lowBattery = _GpsProfile(
    intervalMs: 10000,
    distanceFilter: 30,
    name: 'low_battery',
  );

  // Critical battery mode
  static const criticalBattery = _GpsProfile(
    intervalMs: 30000,
    distanceFilter: 100,
    name: 'critical_battery',
  );

  static _GpsProfile fromSpeed(double speedMps) {
    final speedKmh = speedMps * 3.6;
    if (speedKmh < 1) return stationary;
    if (speedKmh < 6) return walking;
    if (speedKmh < 25) return running;
    if (speedKmh < 60) return cityDriving;
    return highway;
  }
}

class LocationService extends ChangeNotifier {
  TrackingState _state = TrackingState.idle;
  LatLng? _currentPosition;
  double _currentSpeed = 0;
  double _totalDistance = 0;
  int _pointCount = 0;
  String? _activeJourneyId;
  String _deviceId = 'phone-default';
  final List<LatLng> _routePoints = [];
  Timer? _locationTimer;
  final GrpcService _grpc = GrpcService();
  final Battery _battery = Battery();
  final OfflineQueue _offlineQueue = OfflineQueue();

  // Adaptive GPS state
  _GpsProfile _currentProfile = _GpsProfile.walking;
  // ignore: unused_field — reserved for adaptive GPS stationary detection
  int _consecutiveStationary = 0;
  double _minDistance = 5; // configurable via settings
  int _batteryLevel = 100;
  bool _batteryMonitoring = false;

  // Getters
  TrackingState get state => _state;
  LatLng? get currentPosition => _currentPosition;
  double get currentSpeed => _currentSpeed;
  double get totalDistance => _totalDistance;
  int get pointCount => _pointCount;
  String? get activeJourneyId => _activeJourneyId;
  List<LatLng> get routePoints => List.unmodifiable(_routePoints);
  String get currentProfileName => _currentProfile.name;

  String get speedText {
    if (_currentSpeed < 0.5) return '0 km/h';
    return '${(_currentSpeed * 3.6).toStringAsFixed(1)} km/h';
  }

  String get distanceText {
    if (_totalDistance >= 1000) {
      return '${(_totalDistance / 1000).toStringAsFixed(2)} km';
    }
    return '${_totalDistance.toStringAsFixed(0)} m';
  }

  void setDeviceId(String id) {
    _deviceId = id;
  }

  void setMinDistance(double meters) {
    _minDistance = meters.clamp(1, 100);
  }

  Future<void> startTracking(String deviceId, {String label = 'Journey'}) async {
    if (_state == TrackingState.tracking) return;
    _deviceId = deviceId;

    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    // Start battery monitoring
    _startBatteryMonitoring();

    try {
      final journey = await _grpc.startJourney(deviceId, label);
      _activeJourneyId = journey.id;
      debugPrint('[Location] Journey started: ${journey.id}');
      _grpc.startLocationStream();
    } catch (e) {
      debugPrint('[Location] gRPC startJourney failed: $e');
      _activeJourneyId = 'local-${DateTime.now().millisecondsSinceEpoch}';
    }

    // Reset state
    _routePoints.clear();
    _totalDistance = 0;
    _pointCount = 0;
    _currentProfile = _GpsProfile.walking;
    _consecutiveStationary = 0;
    _state = TrackingState.tracking;
    notifyListeners();

    // Start offline queue sync worker
    _offlineQueue.startSync(_grpc);

    // Show tracking notification
    await NotificationService.showTrackingNotification(
      speed: speedText,
      distance: distanceText,
      points: _pointCount,
    );

    // Start adaptive location timer
    _startAdaptiveTimer();

    // Get immediate position
    await _captureLocation();
  }

  Future<void> stopTracking() async {
    if (_state == TrackingState.idle) return;

    _locationTimer?.cancel();
    _locationTimer = null;
    _stopBatteryMonitoring();
    _offlineQueue.stopSync();

    if (_activeJourneyId != null) {
      try {
        final journey = await _grpc.endJourney(_activeJourneyId!);
        debugPrint('[Location] Journey ended: ${journey.id} '
            'distance=${journey.totalDistanceM}m points=${journey.pointCount}');
      } catch (e) {
        debugPrint('[Location] gRPC endJourney failed: $e');
      }
    }

    _state = TrackingState.idle;
    _activeJourneyId = null;
    notifyListeners();

    await NotificationService.hideTrackingNotification();
  }

  void _startAdaptiveTimer() {
    _locationTimer?.cancel();
    final interval = Duration(milliseconds: _currentProfile.intervalMs);
    debugPrint('[Location] GPS profile: ${_currentProfile.name} (${_currentProfile.intervalMs}ms)');
    _locationTimer = Timer.periodic(interval, (_) => _captureLocation());
  }

  void _adjustGpsProfile(double speedMps) {
    // Battery override
    if (_batteryLevel <= 10) {
      if (_currentProfile.name != 'critical_battery') {
        _currentProfile = _GpsProfile.criticalBattery;
        _startAdaptiveTimer();
      }
      return;
    }
    if (_batteryLevel <= 20) {
      if (_currentProfile.name != 'low_battery') {
        _currentProfile = _GpsProfile.lowBattery;
        _startAdaptiveTimer();
      }
      return;
    }

    // Speed-based profile
    final newProfile = _GpsProfile.fromSpeed(speedMps);
    if (newProfile.name != _currentProfile.name) {
      _currentProfile = newProfile;
      _startAdaptiveTimer();
    }
  }

  void _startBatteryMonitoring() {
    if (_batteryMonitoring) return;
    _batteryMonitoring = true;

    // Initial battery level
    _battery.batteryLevel.then((level) {
      _batteryLevel = level;
    });

    // Listen for battery changes
    _battery.onBatteryStateChanged.listen((BatteryState state) {
      _battery.batteryLevel.then((level) {
        _batteryLevel = level;
        debugPrint('[Battery] Level: $_batteryLevel%');
      });
    });
  }

  void _stopBatteryMonitoring() {
    _batteryMonitoring = false;
  }

  Future<void> _captureLocation() async {
    if (_state != TrackingState.tracking) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final newPos = LatLng(position.latitude, position.longitude);
      final speed = position.speed;

      // GPS jump rejection: reject if moved impossibly fast
      if (_currentPosition != null) {
        final distance = const Distance().as(
          LengthUnit.Meter,
          _currentPosition!,
          newPos,
        );

        // Sanity check: at 200 km/h max, in our interval, max distance = speed * time
        final maxReasonableDistance = max(200.0 / 3.6, speed) *
            (_currentProfile.intervalMs / 1000) * 1.5;
        if (distance > maxReasonableDistance && distance > 500) {
          debugPrint('[Location] GPS jump rejected: ${distance.toStringAsFixed(0)}m '
              '(max: ${maxReasonableDistance.toStringAsFixed(0)}m)');
          return;
        }

        // Minimum distance filter
        if (distance < _minDistance) return;

        _totalDistance += distance;
      }

      // Detect stationary state
      if (speed < 0.5) {
        _consecutiveStationary++;
      } else {
        _consecutiveStationary = 0;
      }

      _currentPosition = newPos;
      _currentSpeed = speed;
      _routePoints.add(newPos);
      _pointCount++;
      notifyListeners();

      // Adjust GPS profile based on speed and battery
      _adjustGpsProfile(speed);

      // Update notification
      await NotificationService.updateTrackingNotification(
        speed: speedText,
        distance: distanceText,
        points: _pointCount,
      );

      // Send to server — write to offline queue first, then gRPC
      if (_activeJourneyId != null) {
        // Always write to offline queue first
        await _offlineQueue.enqueue(
          journeyId: _activeJourneyId!,
          deviceId: _deviceId,
          latitude: position.latitude,
          longitude: position.longitude,
          speed: speed,
          accuracy: position.accuracy,
          altitude: position.altitude,
          heading: position.heading,
        );

        // Also send via gRPC stream (if connected)
        _grpc.sendLocationUpdate(
          journeyId: _activeJourneyId!,
          deviceId: _deviceId,
          latitude: position.latitude,
          longitude: position.longitude,
          speed: speed,
          accuracy: position.accuracy,
          altitude: position.altitude,
          heading: position.heading,
        );
      }

      debugPrint('[Location] ${position.latitude}, ${position.longitude} '
          'speed=${speed.toStringAsFixed(1)} '
          'profile=${_currentProfile.name} '
          'battery=$_batteryLevel%');
    } catch (e) {
      debugPrint('[Location] capture error: $e');
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _stopBatteryMonitoring();
    NotificationService.hideTrackingNotification();
    _grpc.close();
    super.dispose();
  }
}
