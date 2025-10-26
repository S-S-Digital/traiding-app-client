import 'package:aspiro_trade/app/app.dart';
import 'package:aspiro_trade/repositories/auth/models/models.dart';
import 'package:aspiro_trade/repositories/core/exceptions/app_exception.dart';
import 'package:aspiro_trade/router/router.dart' as router;
import 'package:aspiro_trade/router/router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:flutter/material.dart';



class AspiroTradeApp extends StatefulWidget {
  const AspiroTradeApp({super.key, required this.config});

  final AppConfig config;

  @override
  State<AspiroTradeApp> createState() => _AspiroTradeAppState();
}

class _AspiroTradeAppState extends State<AspiroTradeApp>
    with WidgetsBindingObserver {
  // final _appRouter = AppRouter();
  late final router.AppRouter appRouter;
  

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.config.realm.close();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    appRouter = router.AppRouter();
  try {
    final (_, refreshToken) = await widget.config.tokenStorage.getTokens();
    final result = await widget.config.api.refresh(Refresh(refreshToken: refreshToken ?? ''));
    await widget.config.tokenStorage.clear();
    await widget.config.tokenStorage.saveTokens(result.accessToken, result.refreshToken);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appRouter.replace(const HomeRoute());
    });
  } on UnauthorizedException catch (_) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appRouter.replace(const LoginRoute());
    });
  }
}


  @override
  Widget build(BuildContext context) {
    final repositoryContainer = RepositoryContainer.prod(config: widget.config);
    return AppInitializer(
      config: widget.config,
      repositoryContainer: repositoryContainer,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Aspiro trade',
        theme: darkTheme,
        routerConfig: appRouter.config(),
      ),
    );
  }
}
