import 'dart:developer';
import 'package:aspiro_trade/repositories/notifications/notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class NotificationsRepository implements NotificationsRepositoryI {
  NotificationsRepository({
    required FlutterLocalNotificationsPlugin localNotifications,
    required FirebaseMessaging firebaseMessaging,
  })  : _localNotifications = localNotifications,
        _firebaseMessaging = firebaseMessaging;

  final FlutterLocalNotificationsPlugin _localNotifications;
  final FirebaseMessaging _firebaseMessaging;

  static const _defaultChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  @override
  Future<String?> getToken() => _firebaseMessaging.getToken();

  @override
  Future<bool> requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission();
    final isAuthorized =
        settings.authorizationStatus == AuthorizationStatus.authorized;
    if (isAuthorized) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    return isAuthorized;
  }

  @override
  Future<void> init() async {
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_defaultChannel);
    }

    // Получение токена
    _firebaseMessaging.getToken().then((token) {
      log(token ?? 'Нет токена');
    });

    // Обработка входящих сообщений
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        showLocalNotification(
          Notification(
            title: notification.title!,
            message: notification.body!,
          ),
        );
      }
    });

    // Обработка кликов на уведомление
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("Получено сообщение в foreground: ${message.toMap()}");
    });

    

    // Если уведомление открывает закрытое приложение
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      
    });
  }

  @override
  Future<void> showLocalNotification(Notification notification) async {
    await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.message,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _defaultChannel.id,
            _defaultChannel.name,
            channelDescription: _defaultChannel.description,
            importance: Importance.max, 
            priority: Priority.high, 
            icon: '@mipmap/ic_launcher',

          ),
        ));
  }


  void disableNotifications() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('BTCUSDT');
  }

  void enableNotifications() async {
    await FirebaseMessaging.instance.subscribeToTopic('BTCUSDT');
  }
}
