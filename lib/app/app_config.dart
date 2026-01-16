import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';

class AppConfig {
  AppConfig({
    required this.preferences,
    required this.talker,
    required this.apiUrl,
    required this.api,
    required this.realm,
    required this.tokenStorage,
    required this.firebaseMessaging,
    required this.localNotificationsPlugin,
    required this.firebaseAuth
  });

  final SharedPreferences preferences;
  final Talker talker;
  final String apiUrl;
  final AspiroTradeApi api;
  final Realm realm;
  final TokenStorage tokenStorage;
  final FlutterLocalNotificationsPlugin localNotificationsPlugin;
  final FirebaseMessaging firebaseMessaging;
  final FirebaseAuth firebaseAuth;
}
