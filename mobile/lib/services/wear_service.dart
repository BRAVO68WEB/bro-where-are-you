import 'dart:async';
import 'package:flutter/services.dart';

class WearService {
  static const _method = MethodChannel('com.bwhere/wear');
  static const _event = EventChannel('com.bwhere/wear/location');

  static final WearService _instance = WearService._();
  factory WearService() => _instance;
  WearService._();

  Stream<Map<String, dynamic>>? _locationStream;

  /// Start standalone tracking on WearOS watch
  Future<bool> startTracking({
    required String journeyId,
    required String deviceId,
    required String serverHost,
    required int serverPort,
    String? apiKey,
  }) async {
    final result = await _method.invokeMethod<bool>('startTracking', {
      'journeyId': journeyId,
      'deviceId': deviceId,
      'serverHost': serverHost,
      'serverPort': serverPort,
      'apiKey': apiKey,
    });
    return result ?? false;
  }

  /// Stop tracking on WearOS watch
  Future<bool> stopTracking() async {
    final result = await _method.invokeMethod<bool>('stopTracking');
    return result ?? false;
  }

  /// Check if native service is active
  Future<bool> isActive() async {
    final result = await _method.invokeMethod<bool>('isActive');
    return result ?? false;
  }

  /// Stream of location updates from native service
  Stream<Map<String, dynamic>> get locationStream {
    _locationStream ??= _event
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event as Map));
    return _locationStream!;
  }

  /// Convenience: listen to location updates with typed callback
  StreamSubscription<Map<String, dynamic>> onLocationUpdate(
    void Function(double lat, double lng, double speed, int pointCount) callback,
  ) {
    return locationStream.listen((data) {
      callback(
        data['latitude'] as double,
        data['longitude'] as double,
        (data['speed'] as num).toDouble(),
        data['pointCount'] as int,
      );
    });
  }
}
