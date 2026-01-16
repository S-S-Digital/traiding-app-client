import 'package:aspiro_trade/app/app.dart';

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
  final _appRouter = AppRouter();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.config.realm.close();
    super.dispose();
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
        routerConfig: _appRouter.config(),
      ),
    );
  }
}
