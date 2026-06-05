import 'package:aspiro_trade/features/settings/cubit/strategy_mode_cubit.dart';
import 'package:aspiro_trade/features/settings/widgets/strategy_mode_stats.dart';
import 'package:aspiro_trade/repositories/users/users.dart';
import 'package:aspiro_trade/ui/localization/app_localizations.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Account-level strategy mode selector (backend Task #4). Self-contained:
/// provides its own [StrategyModeCubit] and wires the get/set API.
class StrategyModeSelector extends StatelessWidget {
  const StrategyModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StrategyModeCubit(
        usersRepository: context.read<UsersRepositoryI>(),
      )..load(),
      child: const _StrategyModeBody(),
    );
  }
}

class _StrategyModeBody extends StatelessWidget {
  const _StrategyModeBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StrategyModeCubit, StrategyModeState>(
      listenWhen: (prev, curr) => curr is StrategyModeFailure ||
          (curr is StrategyModeLoaded && curr.justSaved),
      listener: (context, state) {
        if (state is StrategyModeLoaded && state.justSaved) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(AppLocalizations.strategyModeSaved),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.brand,
              duration: const Duration(seconds: 2),
            ));
        }
      },
      buildWhen: (prev, curr) => curr.isBuildable,
      builder: (context, state) {
        // Hidden until we know the mode (no flash of default); failure is silent
        // here (snackbar via listener) to avoid pushing a broken card.
        if (state is! StrategyModeLoaded) {
          return const SizedBox.shrink();
        }
        final mode = state.mode;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
              child: Text(
                AppLocalizations.strategyModeTitle.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            _ModeOption(
              selected: mode.isQuality,
              enabled: !state.saving,
              icon: Icons.verified_outlined,
              title: AppLocalizations.strategyModeQuality,
              subtitle: AppLocalizations.strategyModeQualityDesc,
              onTap: () => context
                  .read<StrategyModeCubit>()
                  .setMode(StrategyMode.qualityKey),
            ),
            StrategyModeStatsPanel(stats: StrategyModeStats.quality),
            const SizedBox(height: 8),
            _ModeOption(
              selected: mode.isTurnover,
              enabled: !state.saving,
              icon: Icons.bolt_outlined,
              title: AppLocalizations.strategyModeTurnover,
              subtitle: AppLocalizations.strategyModeTurnoverDesc,
              onTap: () => context
                  .read<StrategyModeCubit>()
                  .setMode(StrategyMode.turnoverKey),
            ),
            StrategyModeStatsPanel(stats: StrategyModeStats.turnover),
          ],
        );
      },
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.selected,
    required this.enabled,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final bool enabled;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.brand.withValues(alpha: 0.08)
                : AppColors.card.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.brand.withValues(alpha: 0.5)
                  : AppColors.border.withValues(alpha: 0.5),
              width: selected ? 1.2 : 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: selected ? AppColors.brand : AppColors.textTertiary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 20,
                color: selected ? AppColors.brand : AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
