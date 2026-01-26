import 'package:aspiro_trade/features/add_tickers/add_tickers.dart';
import 'package:aspiro_trade/features/asset_details/asset_details.dart';
import 'package:aspiro_trade/features/assets/assets.dart';
import 'package:aspiro_trade/features/history/history.dart';
import 'package:aspiro_trade/features/home/home.dart';
import 'package:aspiro_trade/features/login/login.dart';
import 'package:aspiro_trade/features/privacy_policy/privacy_policy.dart';
import 'package:aspiro_trade/features/profile/profile.dart';
import 'package:aspiro_trade/features/splash/splash.dart';
import 'package:aspiro_trade/features/subscription/subscription.dart';
import 'package:aspiro_trade/features/terms_of_use/terms_of_use.dart';
import 'package:aspiro_trade/features/tickers/models/models.dart';
import 'package:aspiro_trade/features/tickers/tickers.dart';
import 'package:aspiro_trade/features/register/register.dart';
import 'package:aspiro_trade/features/settings/settings.dart';
import 'package:aspiro_trade/features/signals/signals.dart';
import 'package:aspiro_trade/features/update_tickers/update_tickers.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: RegisterRoute.page),
    AutoRoute(page: AssetsRoute.page),
    AutoRoute(page: AssetDetailsRoute.page),
    AutoRoute(page: AddTickersRoute.page),
    AutoRoute(page: SubscriptionRoute.page),
    AutoRoute(page: ProfileRoute.page),
    AutoRoute(page: PrivacyPolicyRoute.page),
    AutoRoute(page: TermsOfUseRoute.page),
    AutoRoute(
      page: HomeRoute.page,
      children: [
        AutoRoute(page: TickersRoute.page),
        AutoRoute(page: SignalsRoute.page),
        AutoRoute(page: HistoryRoute.page),
        AutoRoute(page: SettingsRoute.page),
      ],
    ),
  ];
}
