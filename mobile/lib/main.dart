import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'services/grpc_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request critical permissions upfront
  await [
    Permission.location,
    Permission.locationAlways,
    Permission.notification,
  ].request();

  await NotificationService.init();
  runApp(const BWhereApp());
}

class BWhereApp extends StatefulWidget {
  const BWhereApp({super.key});

  @override
  State<BWhereApp> createState() => _BWhereAppState();
}

class _BWhereAppState extends State<BWhereApp> {
  bool? _isAuthenticated;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token') ?? '';
    final host = prefs.getString('server_host') ?? '';

    if (jwt.isNotEmpty && host.isNotEmpty) {
      await GrpcService().init();
      setState(() => _isAuthenticated = true);
    } else {
      setState(() => _isAuthenticated = false);
    }
  }

  void _onAuthenticated() {
    setState(() => _isAuthenticated = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bro Where Are You',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_isAuthenticated == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_isAuthenticated!) {
      return const HomeScreen();
    }
    return AuthScreen(onAuthenticated: _onAuthenticated);
  }
}
