import 'package:aspiro_trade/api/models/app_config/app_config_dto.dart';
import 'package:aspiro_trade/features/settings/cubit/strategy_mode_cubit.dart';
import 'package:aspiro_trade/features/settings/widgets/strategy_mode_stats.dart';
import 'package:aspiro_trade/repositories/users/users.dart';
import 'package:aspiro_trade/services/config/app_config_cubit.dart';
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
        // Strategies are server-driven: render every enabled strategy from
        // app-config, in order. With crypto-only enabled this is exactly
        // [quality, turnover] with the same numbers as before → identical UI.
        // A flipped-on mode (e.g. "hourly") appears automatically with no
        // release. Known modes keep their localized copy so nothing changes;
        // unknown modes fall back to the server-provided name/description.
        final strategies =
            context.watch<AppConfigCubit>().state.config.enabledStrategies;

        final children = <Widget>[
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
        ];

        for (var i = 0; i < strategies.length; i++) {
          final s = strategies[i];
          if (i > 0) children.add(const SizedBox(height: 8));
          children.add(_ModeOption(
            selected: mode.current == s.id,
            enabled: !state.saving,
            icon: _iconFor(s.id),
            title: _titleFor(s),
            subtitle: _subtitleFor(s),
            onTap: () => context.read<StrategyModeCubit>().setMode(s.id),
          ));
          final stats = StrategyModeStats.fromConfig(
            s,
            explanation: _explanationFor(s),
            color: _colorFor(s.id, i),
          );
          if (stats != null) {
            children.add(StrategyModeStatsPanel(stats: stats));
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
      },
    );
  }
}

// --- per-strategy display mapping ---
// Known modes (quality/turnover) keep their hand-tuned icon/color + localized
// copy so the crypto UI is byte-identical. Unknown / future modes fall back to
// server-provided strings + neutral styling.

IconData _iconFor(String id) {
  switch (id) {
    case StrategyMode.qualityKey:
      return Icons.verified_outlined;
    case StrategyMode.turnoverKey:
      return Icons.bolt_outlined;
    default:
      return Icons.auto_graph_outlined;
  }
}

Color _colorFor(String id, int index) {
  switch (id) {
    case StrategyMode.qualityKey:
      return AppColors.brand;
    case StrategyMode.turnoverKey:
      return AppColors.brandLight;
    default:
      return index.isEven ? AppColors.brand : AppColors.brandLight;
  }
}

String _titleFor(StrategyConfigDto s) {
  switch (s.id) {
    case StrategyMode.qualityKey:
      return AppLocalizations.strategyModeQuality;
    case StrategyMode.turnoverKey:
      return AppLocalizations.strategyModeTurnover;
    default:
      return s.name;
  }
}

String _subtitleFor(StrategyConfigDto s) {
  switch (s.id) {
    case StrategyMode.qualityKey:
      return AppLocalizations.strategyModeQualityDesc;
    case StrategyMode.turnoverKey:
      return AppLocalizations.strategyModeTurnoverDesc;
    default:
      return s.description ?? '';
  }
}

String _explanationFor(StrategyConfigDto s) {
  switch (s.id) {
    case StrategyMode.qualityKey:
      return AppLocalizations.strategyModeQualityExplain;
    case StrategyMode.turnoverKey:
      return AppLocalizations.strategyModeTurnoverExplain;
    default:
      return s.description ?? '';
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
