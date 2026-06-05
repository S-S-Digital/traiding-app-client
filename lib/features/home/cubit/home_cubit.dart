import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:aspiro_trade/repositories/notifications/notifications.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required AuthRepositoryI authRepository,
    required NotificationsRepositoryI notificationsRepository,
  }) : _authRepository = authRepository,
       _notificationsRepository = notificationsRepository,
       super(HomeInitial());

  final AuthRepositoryI _authRepository;
  final NotificationsRepositoryI _notificationsRepository;

  /// FCM token-refresh subscription — cancelled in [close] so it stops firing
  /// after logout/teardown (audit M5). Also guards against double-subscription
  /// if init() runs more than once.
  StreamSubscription<String>? _tokenRefreshSub;

  Future<void> init() async {
    try {
      await _notificationsRepository.init();
      await _notificationsRepository.requestPermission();

      final token = await _notificationsRepository.getToken() ?? '';
      log('FCM token: $token');

      final platform = Platform.isIOS ? 'ios' : 'android';

      await _authRepository.registerFcmToken(
        FirebaseToken(fcmToken: token, platform: platform),
      );
      log('FCM token sent to server successfully');

      // Re-send token when Firebase rotates it. Cancel any prior subscription
      // first so repeated init() never stacks listeners.
      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub =
          _notificationsRepository.onTokenRefresh((newToken) async {
        try {
          log('FCM token refreshed: $newToken');
          await _authRepository.registerFcmToken(
            FirebaseToken(fcmToken: newToken, platform: platform),
          );
          log('Refreshed FCM token sent to server');
        } catch (e) {
          log('Failed to send refreshed FCM token: $e');
        }
      });
    } catch (e) {
      log('FCM init error: $e');
    }
  }

  @override
  Future<void> close() {
    _tokenRefreshSub?.cancel();
    return super.close();
  }
}
