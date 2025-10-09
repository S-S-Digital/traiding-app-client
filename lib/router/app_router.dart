import 'package:aspiro_trade/features/home/home.dart';
import 'package:aspiro_trade/features/portfolio/portfolio.dart';
import 'package:auto_route/auto_route.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: HomeRoute.page,
      initial: true,
      children: [
      AutoRoute(page: PortfolioRoute.page)
    ])
  ];
}