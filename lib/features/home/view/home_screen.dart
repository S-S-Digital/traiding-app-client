import 'package:aspiro_trade/router/app_router.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          body: child,
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppColors.card,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.show_chart_rounded,
                      label: 'Market',
                      isActive: tabsRouter.activeIndex == 0,
                      onTap: () => tabsRouter.setActiveIndex(0),
                    ),
                    _NavItem(
                      icon: Icons.cell_tower_rounded,
                      label: 'Signals',
                      isActive: tabsRouter.activeIndex == 1,
                      onTap: () => tabsRouter.setActiveIndex(1),
                    ),
                    _NavItem(
                      icon: Icons.history_rounded,
                      label: 'History',
                      isActive: tabsRouter.activeIndex == 2,
                      onTap: () => tabsRouter.setActiveIndex(2),
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Profile',
                      isActive: tabsRouter.activeIndex == 3,
                      onTap: () => tabsRouter.setActiveIndex(3),
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
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.brand : AppColors.textQuaternary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.brand : AppColors.textQuaternary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
