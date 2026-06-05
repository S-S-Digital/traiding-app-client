
import 'dart:async';

import 'package:aspiro_trade/repositories/notifications/notifications.dart';

abstract interface class NotificationsRepositoryI {
  Future<void> init();
  Future<String?> getToken();
  Future<bool> requestPermission();
  Future<void> showLocalNotification(Notification notification);

  /// Subscribes to FCM token-refresh events. Returns the [StreamSubscription]
  /// so the caller can cancel it on dispose (otherwise it leaks and keeps
  /// firing after logout — audit M5).
  StreamSubscription<String> onTokenRefresh(void Function(String) callback);
}
