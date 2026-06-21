import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../generated/location/v1/location.pbgrpc.dart';

class GrpcService {
  late ClientChannel _channel;
  late LocationServiceClient _stub;
  String _host = '';
  int _port = 50051;
  String _jwtToken = '';
  String _deviceId = 'phone-default';
  bool _connected = false;

  // Active streaming session
  StreamController<LocationUpdate>? _streamController;
  ResponseFuture<LocationAck>? _streamResponse;

  static final GrpcService _instance = GrpcService._();
  factory GrpcService() => _instance;
  GrpcService._();

  bool get isConnected => _connected;
  String get deviceId => _deviceId;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('server_host') ?? '';
    _port = prefs.getInt('server_port') ?? 50051;
    _jwtToken = prefs.getString('jwt_token') ?? '';
    _deviceId = prefs.getString('device_id') ?? 'phone-default';

    _channel = ClientChannel(
      _host,
      port: _port,
      options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        keepAlive: ClientKeepAliveOptions(
          pingInterval: Duration(seconds: 20),
          timeout: Duration(seconds: 10),
          permitWithoutCalls: true,
        ),
      ),
    );

    _stub = LocationServiceClient(_channel, options: CallOptions(metadata: _metadata));

    debugPrint('[gRPC] Initialized: $_host:$_port (JWT: ${_jwtToken.isNotEmpty})');
  }

  Map<String, String> get _metadata {
    final md = <String, String>{};
    if (_jwtToken.isNotEmpty) {
      md['authorization'] = 'Bearer $_jwtToken';
    }
    return md;
  }

  /// Test TCP connectivity to the gRPC server
  Future<bool> testConnection() async {
    try {
      debugPrint('[gRPC] Testing connection to $_host:$_port...');
      final socket = await Socket.connect(_host, _port,
          timeout: Duration(seconds: 5));
      socket.destroy();
      _connected = true;
      debugPrint('[gRPC] Connection OK');
      return true;
    } catch (e) {
      _connected = false;
      debugPrint('[gRPC] Connection FAILED: $e');
      return false;
    }
  }

  /// HTTP health check
  Future<bool> healthCheck() async {
    try {
      final client = HttpClient()..connectionTimeout = Duration(seconds: 5);
      final request = await client.getUrl(Uri.parse('http://$_host:$_port/health'));
      final response = await request.close();
      client.close();
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[gRPC] Health check failed: $e');
      return false;
    }
  }

  // ============================================================
  // Auth RPCs
  // ============================================================

  Future<DeviceCodeResponse> requestDeviceCode({
    required String deviceName,
    required String platform,
  }) async {
    debugPrint('[gRPC] requestDeviceCode — name=$deviceName platform=$platform');
    final req = DeviceCodeRequest()
      ..deviceName = deviceName
      ..platform = platform;
    return await _stub.requestDeviceCode(req);
  }

  Future<DeviceActivationResponse> pollDeviceActivation(String deviceCode) async {
    final req = PollActivationRequest()..deviceCode = deviceCode;
    return await _stub.pollDeviceActivation(req);
  }

  // ============================================================
  // Journey RPCs
  // ============================================================

  Future<Journey> startJourney(String deviceId, String label) async {
    debugPrint('[gRPC] startJourney — device=$deviceId label=$label');

    final req = StartJourneyRequest()
      ..deviceId = deviceId
      ..label = label;

    final journey = await _stub.startJourney(req);
    debugPrint('[gRPC] startJourney OK — id=${journey.id}');
    _connected = true;
    return journey;
  }

  Future<Journey> endJourney(String journeyId) async {
    debugPrint('[gRPC] endJourney — id=$journeyId');

    // Close any active stream
    _streamController?.close();
    _streamController = null;

    final req = EndJourneyRequest()..journeyId = journeyId;
    final journey = await _stub.endJourney(req);
    debugPrint('[gRPC] endJourney OK — distance=${journey.totalDistanceM}m points=${journey.pointCount}');
    return journey;
  }

  Future<GetJourneysResponse> getJourneys(String deviceId, {int limit = 20, int offset = 0}) async {
    debugPrint('[gRPC] getJourneys — device=$deviceId');

    final req = GetJourneysRequest()
      ..deviceId = deviceId
      ..limit = limit
      ..offset = offset;

    return await _stub.getJourneys(req);
  }

  Future<GetJourneyPointsResponse> getJourneyPoints(String journeyId) async {
    final req = GetJourneyPointsRequest()..journeyId = journeyId;
    return await _stub.getJourneyPoints(req);
  }

  // ============================================================
  // Location Streaming
  // ============================================================

  StreamController<LocationUpdate> startLocationStream() {
    if (_streamController != null) return _streamController!;

    _streamController = StreamController<LocationUpdate>();

    _streamResponse = _stub.streamLocations(_streamController!.stream);

    _streamResponse!.then((ack) {
      debugPrint('[gRPC] streamLocations complete — received=${ack.pointsReceived}');
      _connected = true;
    }).catchError((e) {
      debugPrint('[gRPC] streamLocations error: $e');
      _connected = false;
    });

    debugPrint('[gRPC] streamLocations started');
    return _streamController!;
  }

  void sendLocationUpdate({
    required String journeyId,
    required String deviceId,
    required double latitude,
    required double longitude,
    required double speed,
    required double accuracy,
    double altitude = 0,
    double heading = 0,
  }) {
    if (_streamController == null || _streamController!.isClosed) return;

    _streamController!.add(LocationUpdate()
      ..deviceId = deviceId
      ..journeyId = journeyId
      ..latitude = latitude
      ..longitude = longitude
      ..speed = speed
      ..accuracy = accuracy
      ..altitude = altitude
      ..heading = heading
      ..timestampMs = Int64(DateTime.now().millisecondsSinceEpoch)
      ..source = 'phone');
  }

  // ============================================================
  // Stats
  // ============================================================

  Future<JourneyStats> getJourneyStats(String deviceId, {String period = 'day', int limit = 30}) async {
    final req = GetJourneyStatsRequest()
      ..deviceId = deviceId
      ..period = period
      ..limit = limit;
    return await _stub.getJourneyStats(req);
  }

  // ============================================================
  // Saved Locations
  // ============================================================

  Future<SavedLocation> saveLocation({
    required String deviceId,
    required String name,
    required double latitude,
    required double longitude,
    required double radiusM,
  }) async {
    final req = SaveLocationRequest()
      ..deviceId = deviceId
      ..name = name
      ..latitude = latitude
      ..longitude = longitude
      ..radiusM = radiusM;
    return await _stub.saveLocation(req);
  }

  Future<GetSavedLocationsResponse> getSavedLocations(String deviceId) async {
    final req = GetSavedLocationsRequest()..deviceId = deviceId;
    return await _stub.getSavedLocations(req);
  }

  Future<void> deleteSavedLocation(String locationId) async {
    final req = DeleteSavedLocationRequest()..locationId = locationId;
    await _stub.deleteSavedLocation(req);
  }

  // ============================================================
  // Cleanup
  // ============================================================

  Future<void> close() async {
    _streamController?.close();
    _streamController = null;
    await _channel.shutdown();
  }
}
