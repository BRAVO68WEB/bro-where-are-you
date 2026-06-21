import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'grpc_service.dart';
import '../generated/location/v1/location.pb.dart';
import 'package:fixnum/fixnum.dart';

class PendingPoint {
  final int? id;
  final String journeyId;
  final String deviceId;
  final double latitude;
  final double longitude;
  final double speed;
  final double accuracy;
  final double altitude;
  final double heading;
  final int timestampMs;
  final bool synced;

  PendingPoint({
    this.id,
    required this.journeyId,
    required this.deviceId,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.accuracy,
    required this.altitude,
    required this.heading,
    required this.timestampMs,
    this.synced = false,
  });

  Map<String, dynamic> toMap() => {
    'journey_id': journeyId,
    'device_id': deviceId,
    'latitude': latitude,
    'longitude': longitude,
    'speed': speed,
    'accuracy': accuracy,
    'altitude': altitude,
    'heading': heading,
    'timestamp_ms': timestampMs,
    'synced': synced ? 1 : 0,
  };

  factory PendingPoint.fromMap(Map<String, dynamic> m) => PendingPoint(
    id: m['id'] as int?,
    journeyId: m['journey_id'] as String,
    deviceId: m['device_id'] as String,
    latitude: m['latitude'] as double,
    longitude: m['longitude'] as double,
    speed: m['speed'] as double,
    accuracy: m['accuracy'] as double,
    altitude: m['altitude'] as double,
    heading: m['heading'] as double,
    timestampMs: m['timestamp_ms'] as int,
    synced: m['synced'] == 1,
  );
}

class OfflineQueue {
  static final OfflineQueue _instance = OfflineQueue._();
  factory OfflineQueue() => _instance;
  OfflineQueue._();

  Database? _db;
  Timer? _syncTimer;
  bool _syncing = false;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'bwhere_offline.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pending_points (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            journey_id TEXT NOT NULL,
            device_id TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            speed REAL DEFAULT 0,
            accuracy REAL DEFAULT 0,
            altitude REAL DEFAULT 0,
            heading REAL DEFAULT 0,
            timestamp_ms INTEGER NOT NULL,
            synced INTEGER DEFAULT 0,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');
        await db.execute('CREATE INDEX idx_pending_synced ON pending_points(synced)');
        await db.execute('CREATE INDEX idx_pending_journey ON pending_points(journey_id)');
      },
    );
    return _db!;
  }

  /// Enqueue a location point to the local SQLite database.
  Future<void> enqueue({
    required String journeyId,
    required String deviceId,
    required double latitude,
    required double longitude,
    required double speed,
    required double accuracy,
    double altitude = 0,
    double heading = 0,
  }) async {
    final db = await database;
    await db.insert('pending_points', PendingPoint(
      journeyId: journeyId,
      deviceId: deviceId,
      latitude: latitude,
      longitude: longitude,
      speed: speed,
      accuracy: accuracy,
      altitude: altitude,
      heading: heading,
      timestampMs: DateTime.now().millisecondsSinceEpoch,
    ).toMap());
    debugPrint('[OfflineQueue] Enqueued point for journey $journeyId');
  }

  /// Start periodic sync worker.
  void startSync(GrpcService grpc) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) => sync(grpc));
    // Also try immediate sync
    sync(grpc);
    debugPrint('[OfflineQueue] Sync worker started');
  }

  /// Stop sync worker.
  void stopSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Sync all pending points to the server.
  Future<void> sync(GrpcService grpc) async {
    if (_syncing) return;
    _syncing = true;

    try {
      final db = await database;
      final rows = await db.query(
        'pending_points',
        where: 'synced = 0',
        orderBy: 'timestamp_ms ASC',
        limit: 500,
      );

      if (rows.isEmpty) {
        _syncing = false;
        return;
      }

      final points = rows.map((r) => PendingPoint.fromMap(r)).toList();
      debugPrint('[OfflineQueue] Syncing ${points.length} pending points');

      // Send each point via gRPC stream
      // For now, mark as synced if sent successfully
      // In production, use a proper batch send
      int synced = 0;
      for (final point in points) {
        try {
          grpc.sendLocationUpdate(
            journeyId: point.journeyId,
            deviceId: point.deviceId,
            latitude: point.latitude,
            longitude: point.longitude,
            speed: point.speed,
            accuracy: point.accuracy,
            altitude: point.altitude,
            heading: point.heading,
          );
          synced++;
        } catch (e) {
          debugPrint('[OfflineQueue] Failed to sync point: $e');
          break; // Stop on first failure
        }
      }

      // Mark synced points
      if (synced > 0) {
        final ids = points.take(synced).map((p) => p.id).whereType<int>().toList();
        if (ids.isNotEmpty) {
          await db.update(
            'pending_points',
            {'synced': 1},
            where: 'id IN (${ids.join(',')})',
          );
          debugPrint('[OfflineQueue] Synced $synced points');
        }
      }
    } catch (e) {
      debugPrint('[OfflineQueue] Sync error: $e');
    } finally {
      _syncing = false;
    }
  }

  /// Get count of pending points.
  Future<int> pendingCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM pending_points WHERE synced = 0');
    return result.first['cnt'] as int? ?? 0;
  }

  /// Clear all synced points.
  Future<void> clearSynced() async {
    final db = await database;
    await db.delete('pending_points', where: 'synced = 1');
  }
}
