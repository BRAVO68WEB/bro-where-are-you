import 'package:protobuf/protobuf.dart';

class Journey {
  final String id;
  final String deviceId;
  final String label;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double totalDistanceM;
  final int pointCount;

  Journey({
    required this.id,
    required this.deviceId,
    required this.label,
    required this.startedAt,
    this.endedAt,
    this.totalDistanceM = 0,
    this.pointCount = 0,
  });

  Duration get duration {
    final end = endedAt ?? DateTime.now();
    return end.difference(startedAt);
  }

  String get durationText {
    final d = duration;
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes % 60}m';
    }
    return '${d.inMinutes}m ${d.inSeconds % 60}s';
  }

  String get distanceText {
    if (totalDistanceM >= 1000) {
      return '${(totalDistanceM / 1000).toStringAsFixed(1)} km';
    }
    return '${totalDistanceM.toStringAsFixed(0)} m';
  }

  bool get isActive => endedAt == null;
}
