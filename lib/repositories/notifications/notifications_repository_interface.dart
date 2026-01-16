

import 'package:aspiro_trade/repositories/notifications/notifications.dart';

abstract interface class NotificationsRepositoryI {
  Future<void> init();
  Future<String?> getToken();
  Future<bool> requestPermission();
  Future<void> showLocalNotification(Notification notification);
}
