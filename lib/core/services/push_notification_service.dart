import 'package:firebase_messaging/firebase_messaging.dart';

import '../utils/app_logger.dart';
import 'local_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Runs in a separate isolate — no Firebase.initializeApp() call needed
  // here as of firebase_core 4.x on Android; if it errors, add it back.
  AppLogger.d(
    'PushNotificationService',
    'Background message: ${message.messageId}',
  );
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final LocalNotificationService _localNotifications;

  PushNotificationService(this._localNotifications);

  /// Call once at app startup. Requests permission and wires foreground listeners.
  Future<void> initialize() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    AppLogger.d(
      'PushNotificationService',
      'Permission status: ${settings.authorizationStatus}',
    );

    await _localNotifications.initialize();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _localNotifications.show(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        payload: message.data.toString(),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // TODO: deep link via app_router.dart using message.data
    });
  }

  /// Returns the current token, or null if permission wasn't granted.
  Future<String?> getToken() async {
    final settings = await _fcm.getNotificationSettings();
    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      return null;
    }
    return _fcm.getToken();
  }

  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;
}
