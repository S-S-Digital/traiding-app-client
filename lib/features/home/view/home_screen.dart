import 'package:aspiro_trade/features/home/cubit/home_cubit.dart';
import 'package:aspiro_trade/router/app_router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
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
          backgroundColor: AppColors.background,
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: KeyedSubtree(
              key: ValueKey(tabsRouter.activeIndex),
              child: child,
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              border: const Border(
                top: BorderSide(color: AppColors.border, width: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.show_chart_rounded,
                      label: AppLocalizations.market,
                      isActive: tabsRouter.activeIndex == 0,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        tabsRouter.setActiveIndex(0);
                      },
                    ),
                    _NavItem(
                      icon: Icons.cell_tower_rounded,
                      label: AppLocalizations.signals,
                      isActive: tabsRouter.activeIndex == 1,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        tabsRouter.setActiveIndex(1);
                      },
                    ),
                    _NavItem(
                      icon: Icons.history_rounded,
                      label: AppLocalizations.history,
                      isActive: tabsRouter.activeIndex == 2,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        tabsRouter.setActiveIndex(2);
                      },
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      label: AppLocalizations.profile,
                      isActive: tabsRouter.activeIndex == 3,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        tabsRouter.setActiveIndex(3);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(4),
              child: Icon(
                icon,
                size: isActive ? 26 : 24,
                color: isActive ? AppColors.brand : AppColors.textQuaternary,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.brand : AppColors.textQuaternary,
              ),
              child: Text(label),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: BoxDecoration(
                color: AppColors.brand,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
