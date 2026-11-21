import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    return;
  }
}

class PushNotificationService {
  PushNotificationService(this._api);

  final ApiService _api;
  late FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (kIsWeb) return; // Skip for now on web to avoid configuration errors

    try {
      await Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await _localNotifications.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      await _syncToken();
      _messaging.onTokenRefresh.listen((token) => _registerToken(token));

      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;
        if (notification == null) return;
        // Lock-screen privacy (audit §3.1 C & §5.5): never expose counselling,
        // journal, or mental-health details on a locked screen. Use neutral
        // copy and Android NotificationVisibility.private.
        final isSensitive = message.data['sensitive'] != 'false';
        final safeTitle = isSensitive
            ? 'Sisonke'
            : (notification.title ?? 'Sisonke');
        final safeBody = isSensitive
            ? 'You have a new update. Open the app to view.'
            : (notification.body ?? 'Open Sisonke to view.');

        _localNotifications.show(
          id: notification.hashCode,
          title: safeTitle,
          body: safeBody,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'sisonke_updates',
              'Sisonke updates',
              channelDescription: 'App updates and reminders',
              importance: Importance.high,
              priority: Priority.high,
              visibility: NotificationVisibility.private,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Push notifications setup skipped: $e');
      return;
    }
  }

  Future<void> _syncToken() async {
    final token = await _messaging.getToken();
    if (token != null) await _registerToken(token);
  }

  Future<void> _registerToken(String token) async {
    await _api.registerPushToken(
      token: token,
      platform: defaultTargetPlatform.name,
    );
  }
}
