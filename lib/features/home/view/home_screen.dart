import 'dart:ui';
import 'package:aspiro_trade/features/home/cubit/home_cubit.dart';
import 'package:aspiro_trade/features/profile/cubit/profile_cubit.dart';
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
    // Load the single source of truth for premium gating as soon as the
    // authenticated shell mounts, so every gated tab reflects it immediately.
    context.read<ProfileCubit>().start();
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        TickersRoute(),
        SignalsRoute(),
        DigestRoute(),
        HistoryRoute(),
        SettingsRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          backgroundColor: AppColors.background,
          extendBody: true, // Content scroll goes behind the floating bar
          body: child,
          bottomNavigationBar: Container(
            // Sit the floating bar ABOVE the system navigation. viewPadding.bottom
            // is reported by the OS per nav mode: ~48dp for 3-button navigation
            // (bar rises above the buttons), ~16-24dp for gesture navigation (bar
            // sits just above the pill, not floating). +8 is a small breathing gap.
            margin: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              MediaQuery.of(context).viewPadding.bottom + 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.card.withOpacity(0.72),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
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
                          icon: Icons.auto_awesome_rounded,
                          label: AppLocalizations.analyticsTab,
                          isActive: tabsRouter.activeIndex == 2,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            tabsRouter.setActiveIndex(2);
                          },
                        ),
                        _NavItem(
                          icon: Icons.history_rounded,
                          label: AppLocalizations.history,
                          isActive: tabsRouter.activeIndex == 3,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            tabsRouter.setActiveIndex(3);
                          },
                        ),
                        _NavItem(
                          icon: Icons.person_outline_rounded,
                          label: AppLocalizations.profile,
                          isActive: tabsRouter.activeIndex == 4,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            tabsRouter.setActiveIndex(4);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatefulWidget {
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
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.92 : (widget.isActive ? 1.05 : 1.0),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: widget.isActive ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brand.withOpacity(0.18),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      widget.icon,
                      size: widget.isActive ? 25 : 23,
                      color: widget.isActive ? AppColors.brandLight : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              // Auto-shrinks to fit the item's 1/5 share of width so labels
              // never clip/overflow on narrow (fold) screens.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
                      color: widget.isActive ? AppColors.textPrimary : AppColors.textTertiary,
                      letterSpacing: 0.1,
                    ),
                    child: Text(widget.label, maxLines: 1, softWrap: false),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: widget.isActive ? 12 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: widget.isActive ? AppColors.brand : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: widget.isActive
                      ? [
                          BoxShadow(
                            color: AppColors.brand.withOpacity(0.6),
                            blurRadius: 6,
                            spreadRadius: 0.5,
                          ),
                        ]
                      : [],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
