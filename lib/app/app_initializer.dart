import 'package:aspiro_trade/app/app.dart';
import 'package:aspiro_trade/features/add_tickers/bloc/add_tickers_bloc.dart';
import 'package:aspiro_trade/features/asset_details/bloc/asset_details_bloc.dart';
import 'package:aspiro_trade/features/assets/bloc/assets_bloc.dart';
import 'package:aspiro_trade/features/login/bloc/login_bloc.dart';
import 'package:aspiro_trade/features/register/bloc/register_bloc.dart';
import 'package:aspiro_trade/features/tickers/bloc/tickers_bloc.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:aspiro_trade/repositories/tickers/tickers.dart';
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
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                LoginBloc(authRepository: context.read<AuthRepositoryI>()),
          ),
          BlocProvider(
            create: (context) =>
                RegisterBloc(authRepository: context.read<AuthRepositoryI>()),
          ),

          BlocProvider(
            create: (context) => TickersBloc(
              tickersRepository: context.read<TickersRepositoryI>(),
              assetsRepository: context.read<AssetsRepositoryI>(),
            ),
          ),

          BlocProvider(
            create: (context) =>
                AssetsBloc(assetsRepository: context.read<AssetsRepositoryI>()),
          ),

          BlocProvider(
            create: (context) => AssetDetailsBloc(
              assetsRepository: context.read<AssetsRepositoryI>(),
              tickersRepository: context.read<TickersRepositoryI>(),
            ),
          ),

          BlocProvider(
            create: (context) => AddTickersBloc(
              tickersRepository: context.read<TickersRepositoryI>(),
              assetsRepository: context.read<AssetsRepositoryI>(),
            ),
          ),
        ],
        child: child,
      ),
    );
  }
}
