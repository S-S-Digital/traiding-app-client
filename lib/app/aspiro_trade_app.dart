import 'package:aspiro_trade/app/app.dart';
import 'package:aspiro_trade/features/profile/cubit/profile_cubit.dart';
import 'package:aspiro_trade/router/router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AspiroTradeApp extends StatefulWidget {
  const AspiroTradeApp({
    super.key,
    required this.config,
    required this.initialLanguage,
    this.appRouter,
  });

  final AppConfig config;
  final AppLanguage initialLanguage;

  /// Shared router instance (from main) so force-logout can navigate to Login.
  /// Falls back to a local instance when not provided (e.g. tests).
  final AppRouter? appRouter;

  @override
  State<AspiroTradeApp> createState() => _AspiroTradeAppState();
}

class _AspiroTradeAppState extends State<AspiroTradeApp>
    with WidgetsBindingObserver {
  late final AppRouter _appRouter;
  late final LocaleProvider _localeProvider;
  late final RepositoryContainer _repositoryContainer;

  @override
  void initState() {
    super.initState();
    _appRouter = widget.appRouter ?? AppRouter();
    _repositoryContainer = RepositoryContainer.prod(config: widget.config);
    _localeProvider = LocaleProvider(initial: widget.initialLanguage);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _localeProvider.dispose();
    // Close the WS broadcast controllers + socket (audit H2) — they previously
    // leaked across app teardown / hot-restart.
    widget.config.webSocketService.dispose();
    widget.config.realm.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh profile data (isPremium, limits, etc.) when app is reopened
      try {
        final profileCubit = context.read<ProfileCubit>();
        profileCubit.start();
      } catch (_) {
        // ProfileCubit may not be available yet
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppInitializer(
      config: widget.config,
      repositoryContainer: _repositoryContainer,
      child: _LocaleScope(
        provider: _localeProvider,
        builder: (context) => MaterialApp.router(
          key: ValueKey(_localeProvider.language),
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
    required this.builder,
  });

  final LocaleProvider provider;
  final WidgetBuilder builder;

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
      child: Builder(
        builder: widget.builder,
      ),
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
