import 'dart:async';
import 'package:flutter/services.dart';

/// Phone-side companion: listens for watch commands and pushes journey state.
/// Uses platform channels to communicate with Kotlin CompanionSync.
class CompanionService {
  static const _method = MethodChannel('com.bwhere/companion');
  static const _commandEvent = EventChannel('com.bwhere/companion/commands');

  static final CompanionService _instance = CompanionService._();
  factory CompanionService() => _instance;
  CompanionService._();

  Stream<Map<String, dynamic>>? _commandStream;

  /// Push current journey state to watch
  Future<void> pushState({
    required String journeyId,
    required String deviceId,
    required bool isTracking,
    required String label,
    required DateTime startedAt,
    required double speed,
    required double distance,
    required int pointCount,
  }) async {
    await _method.invokeMethod('pushJourneyState', {
      'journeyId': journeyId,
      'deviceId': deviceId,
      'isTracking': isTracking,
      'label': label,
      'startedAt': startedAt.millisecondsSinceEpoch,
      'speed': speed,
      'distance': distance,
      'pointCount': pointCount,
    });
  }

  /// Stream of commands from watch (start, stop, etc.)
  Stream<Map<String, dynamic>> get commandStream {
    _commandStream ??= _commandEvent
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event as Map));
    return _commandStream!;
  }

  /// Listen for watch commands with typed callback
  StreamSubscription<Map<String, dynamic>> onCommand(
    void Function(String command, Map<String, String> params) callback,
  ) {
    return commandStream.listen((data) {
      callback(
        data['command'] as String,
        Map<String, String>.from(data..remove('command')..remove('timestamp')),
      );
    });
  }
}
