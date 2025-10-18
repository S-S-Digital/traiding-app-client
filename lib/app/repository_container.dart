import 'package:aspiro_trade/app/app_config.dart';
import 'package:aspiro_trade/repositories/auth/auth.dart';

import 'package:aspiro_trade/repositories/tickers/tickers.dart';

class RepositoryContainer {
  RepositoryContainer({
    required this.authRepository,
    required this.tickersRepository,
  });

  final AuthRepositoryI authRepository;
  final TickersRepositoryI tickersRepository;

  factory RepositoryContainer.prod({required AppConfig config}) =>
      RepositoryContainer(
        authRepository: AuthRepository(
          config.talker,
          api: config.api,
          realm: config.realm,
          tokenStorage: config.tokenStorage,
        ),
        tickersRepository: TickersRepository(
          config.talker,
          api: config.api,
          realm: config.realm,
        ),
      );
}
