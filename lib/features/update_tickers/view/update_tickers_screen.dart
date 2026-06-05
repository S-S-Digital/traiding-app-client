import 'package:aspiro_trade/features/add_tickers/models/models.dart';
import 'package:aspiro_trade/features/tickers/models/models.dart';
import 'package:aspiro_trade/features/update_tickers/bloc/update_tickers_bloc.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/router/router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aspiro_trade/features/tickers/bloc/bloc.dart' as tickers_bloc;

@RoutePage()
class UpdateTickersScreen extends StatefulWidget {
  const UpdateTickersScreen({super.key, required this.tickers});
  final CombinedTicker tickers;

  @override
  State<UpdateTickersScreen> createState() => _UpdateTickersScreenState();
}

class _UpdateTickersScreenState extends State<UpdateTickersScreen> {
  @override
  void initState() {
    context.read<UpdateTickersBloc>().add(Start(tickers: widget.tickers));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 34),
      child: BlocConsumer<UpdateTickersBloc, UpdateTickersState>(
        listener: (context, state) {
          if (state is UpdateTickersFailure) {
            if (state.error is AppException) {
              final error = state.error as AppException;
              showErrorDialog(context, error.message, 'OK', () {
                if (error is UnauthorizedException) {
                  AutoRouter.of(context).pushAndPopUntil(
                    const LoginRoute(),
                    predicate: (value) => false,
                  );
                } else {
                  Navigator.of(context).pop();
                }
              });
            }
          } else if (state is Close) {
            context.read<tickers_bloc.TickersBloc>().add(tickers_bloc.Start());
            if (context.mounted) Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state is UpdateTickersLoading) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 40),
                PlatformProgressIndicator(),
                SizedBox(height: 12),
                Text(
                  AppLocalizations.loading,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                SizedBox(height: 40),
              ],
            );
          }
          if (state is UpdateTickersLoaded) {
            return _buildContent(context, state);
          }
          return const SizedBox(height: 100);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, UpdateTickersLoaded state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Handle ──
        Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.elevated,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 14),

        Text(
          AppLocalizations.tickerSettings,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),

        // ── Selected asset ──
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: state.isValid
                ? AppColors.brand.withValues(alpha: 0.06)
                : AppColors.elevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: state.isValid
                  ? AppColors.brand.withValues(alpha: 0.15)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.elevated,
                ),
                child: ClipOval(
                  child: Image.network(
                    widget.tickers.assets.logoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        widget.tickers.assets.baseAsset.isNotEmpty
                            ? widget.tickers.assets.baseAsset[0]
                            : '?',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tickers.tickers.symbol,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      widget.tickers.assets.name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ── Timeframe ──
        Text(
          AppLocalizations.timeframe,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: state.timeframes.map((tf) {
            final isSelected = state.selectedTimeframe == tf;
            return GestureDetector(
              onTap: () => context
                  .read<UpdateTickersBloc>()
                  .add(SelectTimeframe(timeframe: tf)),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.brand.withValues(alpha: 0.1)
                      : AppColors.elevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.brand.withValues(alpha: 0.3)
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  tf.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color:
                        isSelected ? AppColors.brand : AppColors.textTertiary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // ── Notifications ──
        Text(
          AppLocalizations.notifications,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  final opt = Options(
                    title: state.selectedOption.title,
                    subtitle: state.selectedOption.subtitle,
                    notifyBuy: !state.selectedOption.notifyBuy,
                    notifySell: state.selectedOption.notifySell,
                  );
                  context.read<UpdateTickersBloc>().add(SelectOption(option: opt));
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: state.selectedOption.notifyBuy
                        ? AppColors.up.withValues(alpha: 0.06)
                        : AppColors.elevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: state.selectedOption.notifyBuy
                          ? AppColors.up.withValues(alpha: 0.12)
                          : AppColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.buySignals,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: state.selectedOption.notifyBuy
                              ? AppColors.up
                              : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.selectedOption.notifyBuy ? AppLocalizations.enabled : AppLocalizations.disabled,
                        style: TextStyle(
                          fontSize: 11,
                          color: state.selectedOption.notifyBuy
                              ? AppColors.up
                              : AppColors.textQuaternary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  final opt = Options(
                    title: state.selectedOption.title,
                    subtitle: state.selectedOption.subtitle,
                    notifyBuy: state.selectedOption.notifyBuy,
                    notifySell: !state.selectedOption.notifySell,
                  );
                  context.read<UpdateTickersBloc>().add(SelectOption(option: opt));
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: state.selectedOption.notifySell
                        ? AppColors.down.withValues(alpha: 0.06)
                        : AppColors.elevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: state.selectedOption.notifySell
                          ? AppColors.down.withValues(alpha: 0.12)
                          : AppColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.sellSignals,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: state.selectedOption.notifySell
                              ? AppColors.down
                              : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.selectedOption.notifySell ? AppLocalizations.enabled : AppLocalizations.disabled,
                        style: TextStyle(
                          fontSize: 11,
                          color: state.selectedOption.notifySell
                              ? AppColors.down
                              : AppColors.textQuaternary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── Submit ──
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: state.isValid
                ? () => context.read<UpdateTickersBloc>().add(
                      UpdateTicker(
                        id: widget.tickers.tickers.id,
                        symbol: widget.tickers.tickers.symbol,
                        timeframe: state.selectedTimeframe.value,
                        notifyBuy: state.selectedOption.notifyBuy,
                        notifySell: state.selectedOption.notifySell,
                      ),
                    )
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  state.isValid ? AppColors.brand : AppColors.elevated,
              foregroundColor: AppColors.background,
              disabledBackgroundColor: AppColors.elevated,
              disabledForegroundColor: AppColors.textQuaternary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              AppLocalizations.save,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
