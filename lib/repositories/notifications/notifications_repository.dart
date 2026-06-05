import 'dart:async';
import 'dart:developer';
import 'package:aspiro_trade/repositories/notifications/notifications.dart';
import 'package:aspiro_trade/services/notification_navigation_service.dart';
import 'package:aspiro_trade/services/widget_service.dart';
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

  /// Guards against re-subscribing onMessage/onMessageOpenedApp on repeated
  /// init() calls — that caused duplicate handling (audit M6).
  bool _initialized = false;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedAppSub;

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
    // Re-entry guard (audit M6): init() can be called more than once (e.g. on
    // re-login); without this we'd stack duplicate onMessage/onMessageOpenedApp
    // listeners and handle every push twice.
    if (_initialized) return;
    _initialized = true;

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
    _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
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

      if (message.data['type'] == 'trading_signal') {
        final entryPrice =
            double.tryParse(message.data['price'] ?? '') ?? 0;
        WidgetService.pushSignal(
          symbol: message.data['symbol'] ?? '',
          direction: message.data['direction'] ?? 'BUY',
          // FCM payload carries entry price as `price`; current is unknown
          // on push, so seed current=entry and let SignalsBloc.Update refresh
          entry: entryPrice,
          price: entryPrice,
          tp: double.tryParse(message.data['TP'] ?? '') ?? 0,
          sl: double.tryParse(message.data['SL'] ?? '') ?? 0,
        );
      }
    });

    // Tap on a notification while the app is backgrounded → route to the
    // relevant screen (audit H1).
    _onOpenedAppSub =
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("Notification opened app: ${message.toMap()}");
      NotificationNavigationService.instance.handleMessage(message);
    });

    // Tap on a notification that cold-started the app.
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      NotificationNavigationService.instance.handleMessage(initialMessage);
    }
  }

  /// Cancels message listeners (best-effort cleanup).
  void dispose() {
    _onMessageSub?.cancel();
    _onOpenedAppSub?.cancel();
    _initialized = false;
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
            icon: '@mipmap/launcher_icon',

          ),
        ));
  }


  void disableNotifications() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('BTCUSDT');
  }

  void enableNotifications() async {
    await FirebaseMessaging.instance.subscribeToTopic('BTCUSDT');
  }

  @override
  StreamSubscription<String> onTokenRefresh(void Function(String) callback) {
    return _firebaseMessaging.onTokenRefresh.listen(callback);
  }
}
