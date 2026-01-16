import 'dart:io' show Platform;

import 'package:aspiro_trade/features/asset_details/bloc/asset_details_bloc.dart'
    as assets_details_bloc;
import 'package:aspiro_trade/features/assets/bloc/assets_bloc.dart'
    as assets_bloc;
import 'package:aspiro_trade/features/history/bloc/history_bloc.dart'
    as history_bloc;
import 'package:aspiro_trade/features/home/cubit/home_cubit.dart';
import 'package:aspiro_trade/features/signals/bloc/signals_bloc.dart'
    as signals_bloc;
import 'package:aspiro_trade/features/tickers/bloc/tickers_bloc.dart';

import 'package:aspiro_trade/router/router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    context.read<HomeCubit>().init();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    context.read<TickersBloc>().add(StopTimer());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      context.read<TickersBloc>().add(StopTimer());
      context.read<assets_bloc.AssetsBloc>().add(assets_bloc.StopTimer());
      context.read<assets_details_bloc.AssetDetailsBloc>().add(
        assets_details_bloc.StopTimer(),
      );
      context.read<signals_bloc.SignalsBloc>().add(signals_bloc.StopTimer());
      context.read<history_bloc.HistoryBloc>().add(history_bloc.StopTimer());
    }

    if (state == AppLifecycleState.resumed) {
      context.read<TickersBloc>().add(StopTimer());
      context.read<assets_bloc.AssetsBloc>().add(assets_bloc.StopTimer());
      context.read<assets_details_bloc.AssetDetailsBloc>().add(
        assets_details_bloc.StopTimer(),
      );
      context.read<signals_bloc.SignalsBloc>().add(signals_bloc.StopTimer());
      context.read<history_bloc.HistoryBloc>().add(history_bloc.StopTimer());
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData getAdaptiveIcon({
      required IconData mIcon,
      required IconData cIcon,
    }) {
      return Platform.isIOS ? cIcon : mIcon;
    }

    return AutoTabsRouter(
      routes: const [
        TickersRoute(),
        SignalsRoute(),
        HistoryRoute(),
        SettingsRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: tabsRouter.activeIndex,
            onTap: tabsRouter.setActiveIndex,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  getAdaptiveIcon(
                    mIcon: Icons.analytics_outlined,
                    cIcon: CupertinoIcons.chart_bar_fill,
                  ),
                ),
                label: 'Активы',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  getAdaptiveIcon(
                    mIcon: Icons.cell_tower, // Сигналы (базовая станция)
                    cIcon: CupertinoIcons
                        .waveform_path_ecg, // Сигналы (пульс/график)
                  ),
                ),
                label: 'Сигналы',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  getAdaptiveIcon(
                    mIcon: Icons.history,
                    cIcon: CupertinoIcons.clock_fill,
                  ),
                ),
                label: 'История',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  getAdaptiveIcon(
                    mIcon: Icons.settings_outlined,
                    cIcon: CupertinoIcons.settings,
                  ),
                ),
                label: 'Настройки',
              ),
            ],
          ),
        );
      },
    );
  }
}
