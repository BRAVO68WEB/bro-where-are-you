import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:latlong2/latlong.dart';
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

  static const stationary = _GpsProfile(intervalMs: 15000, distanceFilter: 30, name: 'stationary');
  static const walking = _GpsProfile(intervalMs: 5000, distanceFilter: 10, name: 'walking');
  static const running = _GpsProfile(intervalMs: 3000, distanceFilter: 8, name: 'running');
  static const cityDriving = _GpsProfile(intervalMs: 2000, distanceFilter: 15, name: 'city_driving');
  static const highway = _GpsProfile(intervalMs: 5000, distanceFilter: 50, name: 'highway');
  static const lowBattery = _GpsProfile(intervalMs: 10000, distanceFilter: 30, name: 'low_battery');
  static const criticalBattery = _GpsProfile(intervalMs: 30000, distanceFilter: 100, name: 'critical_battery');

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
  final GrpcService _grpc = GrpcService();
  final Battery _battery = Battery();
  final OfflineQueue _offlineQueue = OfflineQueue();

  // Adaptive GPS state
  _GpsProfile _currentProfile = _GpsProfile.walking;
  // ignore: unused_field — reserved for adaptive GPS stationary detection
  int _consecutiveStationary = 0;
  double _minDistance = 5;
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

    // Start battery monitoring
    _startBatteryMonitoring();

    // Start journey on server
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

    // Configure and start background geolocation
    await bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      distanceFilter: _minDistance,
      foregroundService: true,
      locationUpdateInterval: _currentProfile.intervalMs,
      fastestLocationUpdateInterval: 1000,
      allowIdenticalLocations: false,
      batchSync: false,
      autoSync: true,
      debug: false,
      logLevel: bg.Config.LOG_LEVEL_WARNING,
      app: bg.AppConfig(
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
        notification: bg.Notification(
          title: 'BWhere',
          text: 'Tracking your journey',
        ),
      ),
    ));

    // Listen to location events
    bg.BackgroundGeolocation.onLocation(_onBgLocation, _onBgLocationError);

    // Listen to motion changes for adaptive profiles
    bg.BackgroundGeolocation.onMotionChange(_onMotionChange);

    await bg.BackgroundGeolocation.start();
    debugPrint('[Location] Background geolocation started');
  }

  Future<void> stopTracking() async {
    if (_state == TrackingState.idle) return;

    await bg.BackgroundGeolocation.stop();
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

  void _onBgLocation(bg.Location location) {
    _processLocation(
      location.coords.latitude,
      location.coords.longitude,
      location.coords.speed,
      location.coords.accuracy,
      location.coords.altitude,
      location.coords.heading,
    );
  }

  void _onBgLocationError(dynamic error) {
    debugPrint('[Location] bg location error: $error');
  }

  void _onMotionChange(bg.Location location) {
    debugPrint('[Location] Motion change: isMoving=${location.isMoving}');
  }

  void _processLocation(double lat, double lng, double speed, double accuracy, double? altitude, double? heading) {
    if (_state != TrackingState.tracking) return;

    final newPos = LatLng(lat, lng);

    // GPS jump rejection
    if (_currentPosition != null) {
      final distance = const Distance().as(LengthUnit.Meter, _currentPosition!, newPos);
      final maxReasonableDistance = max(200.0 / 3.6, speed) * (_currentProfile.intervalMs / 1000) * 1.5;
      if (distance > maxReasonableDistance && distance > 500) {
        debugPrint('[Location] GPS jump rejected: ${distance.toStringAsFixed(0)}m');
        return;
      }
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

    // Send to server
    if (_activeJourneyId != null) {
      _offlineQueue.enqueue(
        journeyId: _activeJourneyId!,
        deviceId: _deviceId,
        latitude: lat,
        longitude: lng,
        speed: speed,
        accuracy: accuracy,
        altitude: altitude ?? 0,
        heading: heading ?? 0,
      );

      _grpc.sendLocationUpdate(
        journeyId: _activeJourneyId!,
        deviceId: _deviceId,
        latitude: lat,
        longitude: lng,
        speed: speed,
        accuracy: accuracy,
        altitude: altitude ?? 0,
        heading: heading ?? 0,
      );
    }

    debugPrint('[Location] $lat, $lng speed=${speed.toStringAsFixed(1)} '
        'profile=${_currentProfile.name} battery=$_batteryLevel%');
  }

  void _adjustGpsProfile(double speedMps) {
    _GpsProfile newProfile;

    if (_batteryLevel <= 10) {
      newProfile = _GpsProfile.criticalBattery;
    } else if (_batteryLevel <= 20) {
      newProfile = _GpsProfile.lowBattery;
    } else {
      newProfile = _GpsProfile.fromSpeed(speedMps);
    }

    if (newProfile.name != _currentProfile.name) {
      _currentProfile = newProfile;
      debugPrint('[Location] GPS profile: ${_currentProfile.name} (${_currentProfile.intervalMs}ms)');

      // Update bg config with new interval
      bg.BackgroundGeolocation.setConfig(bg.Config(
        locationUpdateInterval: _currentProfile.intervalMs,
        distanceFilter: _currentProfile.distanceFilter,
      ));
    }
  }

  void _startBatteryMonitoring() {
    if (_batteryMonitoring) return;
    _batteryMonitoring = true;

    _battery.batteryLevel.then((level) {
      _batteryLevel = level;
    });

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

  @override
  void dispose() {
    bg.BackgroundGeolocation.stop();
    _stopBatteryMonitoring();
    NotificationService.hideTrackingNotification();
    _grpc.close();
    super.dispose();
  }
}
