import 'package:aspiro_trade/app/app_config.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/auth/auth.dart';

import 'package:aspiro_trade/repositories/tickers/tickers.dart';

class RepositoryContainer {
  RepositoryContainer({
    required this.authRepository,
    required this.tickersRepository,
    required this.assetsRepository,
  });

  final AuthRepositoryI authRepository;
  final TickersRepositoryI tickersRepository;
  final AssetsRepositoryI assetsRepository;

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
        assetsRepository: AssetsRepository(
          config.talker,
          api: config.api,
          realm: config.realm,
        ),
      );
}
