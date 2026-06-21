import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/grpc_service.dart';
import '../generated/location/v1/location.pb.dart';
import '../widgets/speed_chart.dart';
import '../widgets/elevation_chart.dart';

class JourneyDetailScreen extends StatefulWidget {
  final String journeyId;
  final String label;
  final double distance;
  final int startedAt;
  final int endedAt;

  const JourneyDetailScreen({
    super.key,
    required this.journeyId,
    required this.label,
    required this.distance,
    required this.startedAt,
    required this.endedAt,
  });

  @override
  State<JourneyDetailScreen> createState() => _JourneyDetailScreenState();
}

class _JourneyDetailScreenState extends State<JourneyDetailScreen> {
  final GrpcService _grpc = GrpcService();
  final MapController _mapController = MapController();
  List<LatLng> _points = [];
  bool _loading = true;
  String? _error;
  double _maxSpeed = 0;
  double _avgSpeed = 0;
  double _elevationGain = 0;
  List<double> _speeds = [];
  List<double> _altitudes = [];
  List<DateTime> _timestamps = [];

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final resp = await _grpc.getJourneyPoints(widget.journeyId);
      final points = resp.points
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      // Calculate stats
      double totalSpeed = 0;
      int speedCount = 0;
      double elevGain = 0;
      double? prevAlt;
      final speeds = <double>[];
      final altitudes = <double>[];
      final timestamps = <DateTime>[];

      for (final p in resp.points) {
        if (p.speed > 0) {
          totalSpeed += p.speed;
          speedCount++;
          if (p.speed > _maxSpeed) _maxSpeed = p.speed;
        }
        speeds.add(p.speed);
        altitudes.add(p.altitude);
        timestamps.add(DateTime.fromMillisecondsSinceEpoch(p.recordedAt.toInt()));

        if (prevAlt != null && p.altitude > prevAlt) {
          elevGain += p.altitude - prevAlt;
        }
        prevAlt = p.altitude;
      }

      if (speedCount > 0) _avgSpeed = totalSpeed / speedCount;

      setState(() {
        _points = points;
        _speeds = speeds;
        _altitudes = altitudes;
        _timestamps = timestamps;
        _elevationGain = elevGain;
        _loading = false;
      });

      // Fit map to route bounds after frame renders
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (points.length > 1) {
          final bounds = LatLngBounds.fromPoints(points);
          _mapController.fitCamera(CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(48),
          ));
        } else if (points.length == 1) {
          _mapController.move(points.first, 16);
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load route: $e';
        _loading = false;
      });
    }
  }

  String _formatDuration() {
    if (widget.startedAt == 0) return '—';
    final end = widget.endedAt > 0 ? widget.endedAt : DateTime.now().millisecondsSinceEpoch;
    final d = Duration(milliseconds: end - widget.startedAt);
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m ${d.inSeconds % 60}s';
    if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds % 60}s';
    return '${d.inSeconds}s';
  }

  String _formatSpeed(double mps) => '${(mps * 3.6).toStringAsFixed(1)} km/h';

  String _formatDistance() {
    if (widget.distance >= 1000) return '${(widget.distance / 1000).toStringAsFixed(2)} km';
    return '${widget.distance.toStringAsFixed(0)} m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.label)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: _loadRoute, child: const Text('Retry')),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Stats row
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Theme.of(context).colorScheme.surface,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _stat('Distance', _formatDistance()),
                            _stat('Duration', _formatDuration()),
                            _stat('Avg', _formatSpeed(_avgSpeed)),
                            _stat('Max', _formatSpeed(_maxSpeed)),
                            _stat('Elev+', '${_elevationGain.toStringAsFixed(0)}m'),
                            _stat('Pts', '${_points.length}'),
                          ],
                        ),
                      ),
                      // Map
                      SizedBox(
                        height: 300,
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _points.isNotEmpty ? _points.first : const LatLng(28.6139, 77.209),
                            initialZoom: 14,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.bwhere.app',
                            ),
                            if (_points.length > 1)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: _points,
                                    color: Theme.of(context).colorScheme.primary,
                                    strokeWidth: 4,
                                  ),
                                ],
                              ),
                            MarkerLayer(
                              markers: [
                                if (_points.isNotEmpty)
                                  Marker(
                                    point: _points.first,
                                    width: 24,
                                    height: 24,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                    ),
                                  ),
                                if (_points.length > 1)
                                  Marker(
                                    point: _points.last,
                                    width: 24,
                                    height: 24,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Charts
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            SpeedChart(speeds: _speeds, timestamps: _timestamps),
                            const SizedBox(height: 8),
                            ElevationChart(altitudes: _altitudes, timestamps: _timestamps),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
