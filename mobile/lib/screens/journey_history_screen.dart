import 'dart:async';
import 'package:flutter/material.dart';
import '../services/grpc_service.dart';
import '../generated/location/v1/location.pb.dart' hide LocationPoint;
import 'journey_detail_screen.dart';

class JourneyHistoryScreen extends StatefulWidget {
  const JourneyHistoryScreen({super.key});

  @override
  State<JourneyHistoryScreen> createState() => _JourneyHistoryScreenState();
}

class _JourneyHistoryScreenState extends State<JourneyHistoryScreen> {
  final GrpcService _grpc = GrpcService();
  List<Journey> _journeys = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadJourneys();
  }

  Future<void> _loadJourneys() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final resp = await _grpc.getJourneys(_grpc.deviceId);
      setState(() {
        _journeys = resp.journeys;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load journeys: $e';
        _loading = false;
      });
    }
  }

  String _formatDate(int ms) {
    if (ms == 0) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.toStringAsFixed(0)} m';
  }

  String _formatDuration(int startMs, int endMs) {
    if (startMs == 0) return '';
    final end = endMs > 0 ? endMs : DateTime.now().millisecondsSinceEpoch;
    final d = Duration(milliseconds: end - startMs);
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inMinutes}m ${d.inSeconds % 60}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journey History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadJourneys,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadJourneys, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_journeys.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.route, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No journeys yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Start tracking to record your first journey'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJourneys,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _journeys.length,
        itemBuilder: (context, index) {
          final j = _journeys[index];
          final isActive = j.endedAt.toInt() == 0;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isActive ? Colors.green : Colors.grey.shade700,
                child: Icon(
                  isActive ? Icons.play_arrow : Icons.stop,
                  color: Colors.white,
                ),
              ),
              title: Text(
                j.label.isEmpty ? 'Untitled Journey' : j.label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${_formatDate(j.startedAt.toInt())} · ${_formatDistance(j.totalDistanceM)} · '
                '${_formatDuration(j.startedAt.toInt(), j.endedAt.toInt())}',
              ),
              trailing: isActive
                  ? const Badge(label: Text('LIVE'))
                  : const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JourneyDetailScreen(
                      journeyId: j.id,
                      label: j.label.isEmpty ? 'Untitled Journey' : j.label,
                      distance: j.totalDistanceM,
                      startedAt: j.startedAt.toInt(),
                      endedAt: j.endedAt.toInt(),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
