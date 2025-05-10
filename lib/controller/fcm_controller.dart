import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FcmController {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  @pragma('vm:entry-point')
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          handleNotificationPayload(jsonDecode(response.payload!));
        }
      },
    );
  }

  @pragma('vm:entry-point')
  static Future<void> handleNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'smartfeed_channel',
      'SmartFeed Notifications',
      channelDescription: 'This channel is used for SmartFeed notifications.',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final String? title = message.notification?.title;
    final String? body = message.notification?.body;

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      platformDetails,
      payload: jsonEncode(message.data),
    );
  }

  @pragma('vm:entry-point')
  static Future<void> handleNotificationPayload(
      Map<String, dynamic> data) async {}

  static Future<void> requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) debugPrint('User granted permission');

      if (Platform.isIOS) {
        await _retryGetApnsToken();
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) debugPrint('User granted provisional permission');
    } else {
      if (kDebugMode) {
        debugPrint('User declined or has not accepted permission');
      }
    }
  }

  static Future<void> _retryGetApnsToken(
      {int retries = 2, Duration delay = const Duration(seconds: 2)}) async {
    for (int i = 0; i < retries; i++) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) {
        if (kDebugMode) debugPrint('APNs token: $apnsToken');
        return;
      } else {
        if (kDebugMode) debugPrint('APNs token not available, retrying...');
        await Future.delayed(delay);
      }
      delay *= 2;
    }

    if (kDebugMode) {
      debugPrint('Failed to retrieve APNs token after multiple retries.');
    }
  }
}
