import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging? _fcm;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  NotificationService() : _fcm = Firebase.apps.isNotEmpty ? FirebaseMessaging.instance : null;

  /// Initialize Push & Local notifications listeners
  Future<void> initialize() async {
    try {
      // 1. Request OS permission (FCM & local alerts)
      if (_fcm != null) {
        await _fcm.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
      }

      // 2. Configure Android local channel
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings();

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Local notification clicked: ${details.payload}');
        },
      );

      // 3. Setup foreground messaging listeners
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM Foreground message received: ${message.notification?.title}');
        
        final notification = message.notification;
        
        if (notification != null) {
          showLocalNotification(
            title: notification.title ?? 'Workforce Alert',
            body: notification.body ?? '',
            payload: message.data.toString(),
          );
        }
      });
    } catch (e) {
      debugPrint('FCM/Local Notifications configuration omitted: $e');
    }
  }

  /// Triggers a native system local notification alert on Android/iOS
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'workforce_attendance_channel',
      'Workforce Alerts',
      channelDescription: 'High-priority notifications from company HR/Management',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails darwinPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Fetch the current device FCM target token
  Future<String?> getDeviceToken() async {
    try {
      if (_fcm == null) return 'mock_device_token';
      return await _fcm.getToken();
    } catch (e) {
      return null;
    }
  }
}
