import 'package:aspiro_trade/app/app_config.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:aspiro_trade/repositories/notifications/notifications.dart';
import 'package:aspiro_trade/repositories/payments/payments.dart';
import 'package:aspiro_trade/repositories/signals/signals.dart';

import 'package:aspiro_trade/repositories/tickers/tickers.dart';
import 'package:aspiro_trade/repositories/users/users.dart';

class RepositoryContainer {
  RepositoryContainer({
    required this.authRepository,
    required this.tickersRepository,
    required this.assetsRepository,
    required this.notificationsRepository,
    required this.paymentsRepository,
    required this.signalsRepository,
    required this.usersRepository,
  });

  final AuthRepositoryI authRepository;
  final TickersRepositoryI tickersRepository;
  final AssetsRepositoryI assetsRepository;
  final NotificationsRepositoryI notificationsRepository;
  final PaymentsRepositoryI paymentsRepository;
  final SignalsRepositoryI signalsRepository;
  final UsersRepositoryI usersRepository;

  factory RepositoryContainer.prod({required AppConfig config}) =>
      RepositoryContainer(
        authRepository: AuthRepository(
          config.talker,
          api: config.api,
          realm: config.realm,
          tokenStorage: config.tokenStorage, firebaseAuth: config.firebaseAuth,
        ),
        tickersRepository: TickersRepository(
          config.talker,
          api: config.api,
          realm: config.realm,
        ),
        assetsRepository: AssetsRepository(
          config.talker,
          api: config.api,
          realm: config.realm,
        ),
        notificationsRepository: NotificationsRepository(
          localNotifications: config.localNotificationsPlugin,
          firebaseMessaging: config.firebaseMessaging,
        ),
        paymentsRepository: PaymentsRepository(
          config.talker,
          api: config.api,
          realm: config.realm,
        ),
        signalsRepository: SignalsRepository(
          config.talker,
          api: config.api,
          realm: config.realm,
        ),
        usersRepository: UsersRepository(config.talker, api: config.api),
      );
}
