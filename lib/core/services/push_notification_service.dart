import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../router/app_router.dart';

/// Drives real push notifications: permission, per-device token
/// registration in Firestore (so the `sendNotificationPush` Cloud Function
/// has somewhere to deliver to), and showing a banner while the app is in
/// the foreground. FCM only auto-shows the OS banner when the app is
/// backgrounded or killed — a foreground `onMessage` is delivered silently
/// unless we surface it ourselves via a local notification, so this covers
/// both paths through the same channel/UI.
class PushNotificationService {
  PushNotificationService._();
  static final instance = PushNotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channel = AndroidNotificationChannel(
    'default_channel',
    'Notifications',
    description: 'Money transfers, payments, and account updates.',
    importance: Importance.high,
  );

  /// Sets up local-notification display and message listeners. Safe to
  /// call once at app startup, before anyone is signed in.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await _localNotifications.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: (_) => _openNotifications(),
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      await _messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

      FirebaseMessaging.onMessage.listen(_showForegroundBanner);
      FirebaseMessaging.onMessageOpenedApp.listen((_) => _openNotifications());
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) _openNotifications();
    } catch (e) {
      // Simulators/emulators without Google Play services, or a platform
      // without messaging support, shouldn't take the whole app down.
      debugPrint('Push notification init failed: $e');
    }
  }

  /// Call once a user is signed in — requests permission and saves this
  /// device's FCM token onto their user doc. No-ops quietly if the user
  /// declines the permission prompt.
  Future<void> registerForUser(String uid) async {
    try {
      final settings = await _messaging.requestPermission(alert: true, badge: true, sound: true);
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      final token = await _messaging.getToken();
      if (token != null) await _saveToken(uid, token);
      _messaging.onTokenRefresh.listen((newToken) => _saveToken(uid, newToken));
    } catch (e) {
      debugPrint('Push notification registration failed: $e');
    }
  }

  Future<void> _saveToken(String uid, String token) {
    return FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }

  void _showForegroundBanner(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  void _openNotifications() => AppRouter.router.push('/notifications');
}
