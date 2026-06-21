import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';
import '../services/grpc_service.dart';
import 'journey_history_screen.dart';
import 'settings_screen.dart';
import 'saved_locations_screen.dart';
import 'dart:math' as math;

// Tile layer definitions
class _TileLayer {
  final String name;
  final String url;
  final String? subdomains;
  final IconData icon;

  const _TileLayer({
    required this.name,
    required this.url,
    this.subdomains,
    required this.icon,
  });
}

final _tileLayers = [
  const _TileLayer(
    name: 'Standard',
    url: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    icon: Icons.map,
  ),
  const _TileLayer(
    name: 'Dark',
    url: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
    subdomains: 'abcd',
    icon: Icons.dark_mode,
  ),
  const _TileLayer(
    name: 'Satellite',
    url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    icon: Icons.satellite_alt,
  ),
  const _TileLayer(
    name: 'Terrain',
    url: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
    subdomains: 'abc',
    icon: Icons.terrain,
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  int _currentTileIndex = 0;
  int? _speedLimitKmh;

  @override
  void initState() {
    super.initState();
    _locationService.addListener(_onLocationUpdate);
    _loadSpeedLimit();
  }

  Future<void> _loadSpeedLimit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _speedLimitKmh = prefs.getInt('speed_limit_kmh');
    });
  }

  void _onLocationUpdate() {
    if (_locationService.currentPosition != null) {
      _mapController.move(_locationService.currentPosition!, _mapController.camera.zoom);
    }
    setState(() {});

    // Speed limit check
    if (_speedLimitKmh != null && _locationService.currentSpeed > 0) {
      final speedKmh = _locationService.currentSpeed * 3.6;
      if (speedKmh > _speedLimitKmh!) {
        HapticFeedback.heavyImpact();
      }
    }
  }

  @override
  void dispose() {
    _locationService.removeListener(_onLocationUpdate);
    _locationService.dispose();
    super.dispose();
  }

  Future<void> _toggleTracking() async {
    try {
      if (_locationService.state == TrackingState.tracking) {
        await _locationService.stopTracking();
      } else {
        await _locationService.startTracking(GrpcService().deviceId, label: 'Journey');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _cycleTileLayer() {
    setState(() {
      _currentTileIndex = (_currentTileIndex + 1) % _tileLayers.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTracking = _locationService.state == TrackingState.tracking;
    final tile = _tileLayers[_currentTileIndex];

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(28.6139, 77.209),
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: tile.url,
                subdomains: tile.subdomains != null
                    ? tile.subdomains!.split('')
                    : [],
                userAgentPackageName: 'com.bwhere.app',
              ),
              // Route polyline
              if (_locationService.routePoints.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _locationService.routePoints,
                      color: Theme.of(context).colorScheme.primary,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              // Heading-aware position marker
              if (_locationService.currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _locationService.currentPosition!,
                      width: 48,
                      height: 48,
                      child: Transform.rotate(
                        angle: (_locationService.currentSpeed > 0.5)
                            ? _headingToRadians(_locationService)
                            : 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 3),
                          ),
                          child: Icon(
                            Icons.navigation,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Stats overlay (top)
          if (isTracking)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _stat('Speed', _locationService.speedText),
                          _stat('Distance', _locationService.distanceText),
                          _stat('Points', '${_locationService.pointCount}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade900.withAlpha(60),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'GPS: ${_locationService.currentProfileName}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.green.shade300,
                              ),
                            ),
                          ),
                          if (_speedLimitKmh != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade900.withAlpha(60),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Limit: $_speedLimitKmh km/h',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orange.shade300,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Tile layer switcher (bottom-left)
          Positioned(
            bottom: 80,
            left: 16,
            child: FloatingActionButton.small(
              heroTag: 'tiles',
              onPressed: _cycleTileLayer,
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Icon(tile.icon, color: Theme.of(context).colorScheme.onSurface),
            ),
          ),

          // Top-right buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'settings',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                  child: const Icon(Icons.settings),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'history',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const JourneyHistoryScreen()),
                  ),
                  child: const Icon(Icons.history),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'places',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SavedLocationsScreen()),
                  ),
                  child: const Icon(Icons.place),
                ),
              ],
            ),
          ),
        ],
      ),

      // Start/Stop FAB
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'tracking',
        onPressed: _toggleTracking,
        backgroundColor: isTracking
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        icon: Icon(isTracking ? Icons.stop : Icons.play_arrow),
        label: Text(isTracking ? 'Stop' : 'Start Tracking'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  double _headingToRadians(LocationService svc) {
    // Use last known heading from the gRPC stream
    // For now, derive from route direction
    final points = svc.routePoints;
    if (points.length < 2) return 0;
    final prev = points[points.length - 2];
    final curr = points.last;
    final dy = curr.latitude - prev.latitude;
    final dx = curr.longitude - prev.longitude;
    return math.atan2(dy, dx);
  }

  Widget _stat(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
