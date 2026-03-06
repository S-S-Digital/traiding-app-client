import 'package:aspiro_trade/app/app.dart';

import 'package:aspiro_trade/router/router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:flutter/material.dart';

class AspiroTradeApp extends StatefulWidget {
  const AspiroTradeApp({super.key, required this.config, required this.initialLanguage});

  final AppConfig config;
  final AppLanguage initialLanguage;

  @override
  State<AspiroTradeApp> createState() => _AspiroTradeAppState();
}

class _AspiroTradeAppState extends State<AspiroTradeApp>
    with WidgetsBindingObserver {
  final _appRouter = AppRouter();
  late final LocaleProvider _localeProvider;
  late final RepositoryContainer _repositoryContainer;

  @override
  void initState() {
    super.initState();
    _repositoryContainer = RepositoryContainer.prod(config: widget.config);
    _localeProvider = LocaleProvider(initial: widget.initialLanguage);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _localeProvider.dispose();
    widget.config.realm.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppInitializer(
      config: widget.config,
      repositoryContainer: _repositoryContainer,
      child: _LocaleScope(
        provider: _localeProvider,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Aspiro trade',
          theme: darkTheme,
          routerConfig: _appRouter.config(),
        ),
      ),
    );
  }
}

/// Stateful wrapper that listens to locale changes and triggers rebuild
/// of everything BELOW it (the InheritedWidget and its subtree),
/// but NOT of AppInitializer/BlocProviders above.
class _LocaleScope extends StatefulWidget {
  const _LocaleScope({
    required this.provider,
    required this.child,
  });

  final LocaleProvider provider;
  final Widget child;

  @override
  State<_LocaleScope> createState() => _LocaleScopeState();
}

class _LocaleScopeState extends State<_LocaleScope> {
  @override
  void initState() {
    super.initState();
    widget.provider.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.provider.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _LocaleData(
      provider: widget.provider,
      child: widget.child,
    );
  }
}

class _LocaleData extends InheritedWidget {
  const _LocaleData({
    required this.provider,
    required super.child,
  });

  final LocaleProvider provider;

  static LocaleProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_LocaleData>()!.provider;
  }

  @override
  bool updateShouldNotify(_LocaleData oldWidget) => true;
}

/// Extension for easy access from any widget
extension LocaleProviderExtension on BuildContext {
  LocaleProvider get locale =>
      dependOnInheritedWidgetOfExactType<_LocaleData>()!.provider;
}
