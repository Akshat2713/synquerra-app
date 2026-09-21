import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../di/injection_container.dart';
import '../services/push_notification_service.dart';

/// Handles all one-time app startup work: Firebase, background handlers,
/// DI, and push notification initialization — kept out of main.dart.
Future<void> bootstrapApp() async {
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await initDependencies();

  await sl<PushNotificationService>().initialize();
}
