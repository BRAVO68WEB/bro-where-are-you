import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/grpc_service.dart';
import '../generated/location/v1/location.pb.dart';

class SavedLocationsScreen extends StatefulWidget {
  const SavedLocationsScreen({super.key});

  @override
  State<SavedLocationsScreen> createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  final GrpcService _grpc = GrpcService();
  List<SavedLocation> _locations = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final resp = await _grpc.getSavedLocations(_grpc.deviceId);
      setState(() {
        _locations = resp.locations;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load: $e';
        _loading = false;
      });
    }
  }

  Future<void> _deleteLocation(String id) async {
    try {
      await _grpc.deleteSavedLocation(id);
      await _loadLocations();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _openAddSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AddLocationScreen(grpc: _grpc),
      ),
    ).then((_) => _loadLocations());
  }

  IconData _getIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('home')) return Icons.home;
    if (lower.contains('work') || lower.contains('office')) return Icons.work;
    if (lower.contains('gym')) return Icons.fitness_center;
    if (lower.contains('school') || lower.contains('uni')) return Icons.school;
    return Icons.place;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Locations'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _openAddSheet),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadLocations, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_locations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.place, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No saved locations', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 8),
            const Text('Add Home, Work, or other places'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _openAddSheet,
              icon: const Icon(Icons.add),
              label: const Text('Add Location'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLocations,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _locations.length,
        itemBuilder: (context, index) {
          final loc = _locations[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(_getIcon(loc.name), color: Theme.of(context).colorScheme.primary),
              ),
              title: Text(loc.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                '${loc.latitude.toStringAsFixed(5)}, ${loc.longitude.toStringAsFixed(5)} · ${loc.radiusM.toStringAsFixed(0)}m',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteLocation(loc.id),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// Full-screen Add Location page with proper map
// ============================================================

class AddLocationScreen extends StatefulWidget {
  final GrpcService grpc;
  const AddLocationScreen({super.key, required this.grpc});

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final _nameController = TextEditingController();
  final MapController _mapController = MapController();
  LatLng? _currentPos;
  LatLng? _selectedPoint;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      setState(() {
        _currentPos = LatLng(pos.latitude, pos.longitude);
        _selectedPoint = _currentPos;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _currentPos = const LatLng(28.6139, 77.209);
        _selectedPoint = _currentPos;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty || _selectedPoint == null) return;

    setState(() => _saving = true);
    try {
      await widget.grpc.saveLocation(
        deviceId: widget.grpc.deviceId,
        name: _nameController.text,
        latitude: _selectedPoint!.latitude,
        longitude: _selectedPoint!.longitude,
        radiusM: 100,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e'), backgroundColor: Colors.red),
        );
        setState(() => _saving = false);
      }
    }
  }

  void _centerOnMe() {
    if (_currentPos != null) {
      setState(() => _selectedPoint = _currentPos);
      _mapController.move(_currentPos!, 16);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Location'),
        actions: [
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Name input
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Place Name',
                      hintText: 'Home, Work, Gym...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.place),
                    ),
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                  ),
                ),

                // Instruction
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Tap map to pin location',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _centerOnMe,
                        icon: const Icon(Icons.my_location, size: 16),
                        label: const Text('My Location'),
                      ),
                    ],
                  ),
                ),

                // Map — full remaining height
                Expanded(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentPos!,
                      initialZoom: 16,
                      minZoom: 3,
                      maxZoom: 19,
                      onTap: (tapPosition, point) {
                        setState(() => _selectedPoint = point);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.bwhere.app',
                        maxZoom: 19,
                      ),
                      if (_selectedPoint != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedPoint!,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
