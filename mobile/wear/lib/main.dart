import 'package:flutter/material.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/watch_home.dart';
import 'screens/watch_auth.dart';

void main() {
  runApp(const BWhereWearApp());
}

class BWhereWearApp extends StatefulWidget {
  const BWhereWearApp({super.key});

  @override
  State<BWhereWearApp> createState() => _BWhereWearAppState();
}

class _BWhereWearAppState extends State<BWhereWearApp> {
  bool? _authenticated;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token') ?? '';
    final host = prefs.getString('server_host') ?? '';
    setState(() => _authenticated = jwt.isNotEmpty && host.isNotEmpty);
  }

  void _onAuthenticated() {
    setState(() => _authenticated = true);
  }

  @override
  Widget build(BuildContext context) {
    return AmbientMode(
      builder: (context, mode, child) {
        if (_authenticated == null) {
          return const MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (!_authenticated!) {
          return MaterialApp(
            theme: ThemeData.dark(),
            home: WatchAuthScreen(onAuthenticated: _onAuthenticated),
          );
        }

        return MaterialApp(
          title: 'BWhere',
          theme: ThemeData.dark(),
          home: WatchHomeScreen(isAmbient: mode == WearMode.ambient),
        );
      },
    );
  }
}
