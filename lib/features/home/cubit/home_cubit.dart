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
  Future<void> init() async {
    try {
      await _notificationsRepository.init();
      
      await _notificationsRepository.requestPermission();
      final token = await _notificationsRepository.getToken() ?? '';
      // await _notificationsRepository.showLocalNotification(Notification(title: 'Уведомления работают', message: 'точно работает?'));
      await _authRepository.registerFcmToken(FirebaseToken(fcmToken: token));
      
      
    } catch (_) {

    }
  }
}
