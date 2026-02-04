import 'package:aspiro_trade/app/app.dart';
import 'package:aspiro_trade/features/add_tickers/bloc/add_tickers_bloc.dart';
import 'package:aspiro_trade/features/asset_details/bloc/asset_details_bloc.dart';
import 'package:aspiro_trade/features/assets/bloc/assets_bloc.dart';
import 'package:aspiro_trade/features/history/bloc/history_bloc.dart';
import 'package:aspiro_trade/features/home/cubit/home_cubit.dart';
import 'package:aspiro_trade/features/login/bloc/login_bloc.dart';
import 'package:aspiro_trade/features/profile/cubit/profile_cubit.dart';
import 'package:aspiro_trade/features/register/bloc/register_bloc.dart';
import 'package:aspiro_trade/features/settings/bloc/settings_bloc.dart';
import 'package:aspiro_trade/features/signals/bloc/signals_bloc.dart';
import 'package:aspiro_trade/features/splash/cubit/splash_cubit.dart';
import 'package:aspiro_trade/features/subscription/bloc/subscription_bloc.dart';
import 'package:aspiro_trade/features/tickers/bloc/tickers_bloc.dart';
import 'package:aspiro_trade/features/update_tickers/bloc/update_tickers_bloc.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:aspiro_trade/repositories/notifications/notifications.dart';
import 'package:aspiro_trade/repositories/payments/payments.dart';
import 'package:aspiro_trade/repositories/signals/signals.dart';
import 'package:aspiro_trade/repositories/tickers/tickers.dart';
import 'package:aspiro_trade/repositories/users/users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppInitializer extends StatelessWidget {
  const AppInitializer({
    super.key,
    required this.child,
    required this.config,
    required this.repositoryContainer,
  });

  final Widget child;
  final AppConfig config;
  final RepositoryContainer repositoryContainer;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => repositoryContainer.authRepository,
        ),
        RepositoryProvider(
          create: (context) => repositoryContainer.tickersRepository,
        ),
        RepositoryProvider(
          create: (context) => repositoryContainer.assetsRepository,
        ),
        RepositoryProvider(
          create: (context) => repositoryContainer.notificationsRepository,
        ),
        RepositoryProvider(
          create: (context) => repositoryContainer.paymentsRepository,
        ),

        RepositoryProvider(
          create: (context) => repositoryContainer.signalsRepository,
        ),

        RepositoryProvider(
          create: (context) => repositoryContainer.usersRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SplashCubit(storage: config.tokenStorage),
          ),
          BlocProvider(
            create: (context) =>
                LoginBloc(authRepository: context.read<AuthRepositoryI>()),
          ),
          BlocProvider(
            create: (context) =>
                RegisterBloc(authRepository: context.read<AuthRepositoryI>()),
          ),

          BlocProvider(
            create: (context) => HomeCubit(
              authRepository: context.read<AuthRepositoryI>(),
              notificationsRepository: context.read<NotificationsRepositoryI>(),
            ),
          ),

          BlocProvider(
            create: (context) => TickersBloc(
              tickersRepository: context.read<TickersRepositoryI>(),
              assetsRepository: context.read<AssetsRepositoryI>(),
              signalsRepository: context.read<SignalsRepositoryI>(),
            ),
          ),

          BlocProvider(
            create: (context) =>
                AssetsBloc(assetsRepository: context.read<AssetsRepositoryI>()),
          ),

          BlocProvider(
            create: (context) => AssetDetailsBloc(
              assetsRepository: context.read<AssetsRepositoryI>(),
            ),
          ),

          BlocProvider(
            create: (context) => AddTickersBloc(
              tickersRepository: context.read<TickersRepositoryI>(),
              assetsRepository: context.read<AssetsRepositoryI>(),
              notificationsRepository: context.read<NotificationsRepositoryI>(),
            ),
          ),

          BlocProvider(
            create: (context) => SettingsBloc(
              authRepository: context.read<AuthRepositoryI>(),
              usersRepository: context.read<UsersRepositoryI>(),
            ),
          ),

          BlocProvider(
            create: (context) => SubscriptionBloc(
              paymentsRepository: context.read<PaymentsRepositoryI>(),
              notificationsRepository: context.read<NotificationsRepositoryI>(),
            ),
          ),

          BlocProvider(
            create: (context) => UpdateTickersBloc(
              assetsRepository: context.read<AssetsRepositoryI>(),
              tickersRepository: context.read<TickersRepositoryI>(),
            ),
          ),

          BlocProvider(
            create: (context) => SignalsBloc(
              signalsRepository: context.read<SignalsRepositoryI>(),
              assetsRepository: context.read<AssetsRepositoryI>(),
            ),
          ),

          BlocProvider(
            create: (context) => HistoryBloc(
              signalsRepository: context.read<SignalsRepositoryI>(),
              assetsRepository: context.read<AssetsRepositoryI>(),
            ),
          ),
          BlocProvider(
            create: (context) =>
                ProfileCubit(usersRepository: context.read<UsersRepositoryI>()),
          ),
        ],
        child: child,
      ),
    );
  }
}
