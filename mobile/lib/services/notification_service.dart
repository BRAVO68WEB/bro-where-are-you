import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _trackingChannelId = 'bwhere_tracking';
  static const _trackingNotificationId = 1;

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings: initSettings);
  }

  static Future<void> showTrackingNotification({
    required String speed,
    required String distance,
    required int points,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _trackingChannelId,
      'Journey Tracking',
      channelDescription: 'Shows when journey tracking is active',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: _trackingNotificationId,
      title: 'Tracking Active',
      body: '$speed · $distance · $points pts',
      notificationDetails: details,
    );
  }

  static Future<void> updateTrackingNotification({
    required String speed,
    required String distance,
    required int points,
  }) async {
    await showTrackingNotification(
      speed: speed,
      distance: distance,
      points: points,
    );
  }

  static Future<void> hideTrackingNotification() async {
    await _plugin.cancel(id: _trackingNotificationId);
  }
}
