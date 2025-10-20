import 'package:aspiro_trade/features/history/history.dart';
import 'package:aspiro_trade/features/home/home.dart';
import 'package:aspiro_trade/features/login/login.dart';
import 'package:aspiro_trade/features/portfolio/portfolio.dart';
import 'package:aspiro_trade/features/register/register.dart';
import 'package:aspiro_trade/features/settings/settings.dart';
import 'package:aspiro_trade/features/signals/signals.dart';
import 'package:auto_route/auto_route.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoginRoute.page, initial: true),
    AutoRoute(page: RegisterRoute.page),
    AutoRoute(
      page: HomeRoute.page,
      initial: false,
      children: [
      AutoRoute(page: PortfolioRoute.page),
      AutoRoute(page: SignalsRoute.page),
      AutoRoute(page: HistoryRoute.page,),
      AutoRoute(page: SettingsRoute.page)
    ])
  ];
}