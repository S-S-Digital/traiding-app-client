import 'package:aspiro_trade/features/add_tickers/bloc/add_tickers_bloc.dart';
import 'package:aspiro_trade/features/add_tickers/models/models.dart';
import 'package:aspiro_trade/features/tickers/bloc/bloc.dart' as tickers_bloc;
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/router/router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class AddTickersScreen extends StatefulWidget {
  const AddTickersScreen({super.key, required this.assets});
  final Assets assets;

  @override
  State<AddTickersScreen> createState() => _AddTickersScreenState();
}

class _AddTickersScreenState extends State<AddTickersScreen> {
  List<Timeframes> get timeframeOptions => [
    Timeframes(title: AppLocalizations.tf15m, value: '15m'),
    Timeframes(title: AppLocalizations.tf1h, value: '1h'),
  ];

  @override
  void initState() {
    context.read<AddTickersBloc>().add(Start(symbol: widget.assets.symbol));
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
      child: BlocConsumer<AddTickersBloc, AddTickersState>(
        listener: (context, state) {
          if (state.status == Status.failure) {
            if (state.error is AppException) {
              final error = state.error as AppException;
              if (error is ConflictException) {
                showErrorDialog(
                  context,
                  AppLocalizations.tickerAlreadyAdded,
                  'OK',
                  () {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      context.read<AddTickersBloc>().add(
                        Start(symbol: widget.assets.symbol),
                      );
                    }
                  },
                );
              } else if (error is FordibenException) {
                showErrorDialog(
                  context,
                  AppLocalizations.subscriptionRequired,
                  'OK',
                  () {
                    if (context.mounted) {
                      AutoRouter.of(context).pushAndPopUntil(
                        const HomeRoute(),
                        predicate: (value) => false,
                      );
                    }
                  },
                );
              } else {
                showErrorDialog(context, error.message, 'OK', () {
                  if (error is UnauthorizedException) {
                    if (context.mounted) {
                      AutoRouter.of(context).pushAndPopUntil(
                        const LoginRoute(),
                        predicate: (value) => false,
                      );
                    }
                  } else {
                    if (context.mounted) Navigator.of(context).pop();
                  }
                });
              }
            }
          } else if (state.status == Status.success) {
            if (context.mounted) {
              context.read<tickers_bloc.TickersBloc>().add(tickers_bloc.Start());
              AutoRouter.of(context).pop(const HomeRoute());
            }
          }
        },
        builder: (context, state) {
          if (state.status == Status.loading) {
            return Container(
              width: double.infinity,
              height: 240,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.brand),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.loading,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            );
          }
          if (state.status == Status.submit || state.status == Status.loaded) {
            return _buildContent(context, state);
          }
          return _buildError(context);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AddTickersState state) {
    final isValid = state.status == Status.submit;
    final canSubmit = isValid && state.selectedTimeframe != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Handle ──
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Title ──
        Text(
          AppLocalizations.addTicker,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 14),

        // ── Selected asset ──
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isValid ? AppColors.brand.withOpacity(0.3) : AppColors.border.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: isValid
                ? [
                    BoxShadow(
                      color: AppColors.brand.withOpacity(0.04),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.elevated,
                  border: Border.all(
                    color: AppColors.border.withOpacity(0.6),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    widget.assets.logoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        widget.assets.baseAsset.isNotEmpty
                            ? widget.assets.baseAsset[0]
                            : '?',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.assets.symbol,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.assets.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Timeframe ──
        Text(
          AppLocalizations.timeframe,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textTertiary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: timeframeOptions.map((tf) {
            final isSelected = state.selectedTimeframe == tf;
            return GestureDetector(
              onTap: () => context
                  .read<AddTickersBloc>()
                  .add(SelectTimeframe(timeframe: tf)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.brand.withOpacity(0.12)
                      : AppColors.elevated.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.brand : AppColors.border.withOpacity(0.5),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.brand.withOpacity(0.08),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  tf.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppColors.brand : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // ── Submit ──
        Container(
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: canSubmit
                ? const LinearGradient(
                    colors: [AppColors.brand, AppColors.brandLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: canSubmit ? null : AppColors.elevated.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            boxShadow: canSubmit
                ? [
                    BoxShadow(
                      color: AppColors.brand.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: canSubmit
                ? () => context.read<AddTickersBloc>().add(
                      AddNewTicker(
                        symbol: widget.assets.symbol,
                        timeframe: state.selectedTimeframe!.value,
                        notifyBuy: true,
                        notifySell: true,
                      ),
                    )
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              AppLocalizations.addSymbol(widget.assets.symbol, state.selectedTimeframe?.title),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: canSubmit ? Colors.white : AppColors.textQuaternary,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        const SizedBox(height: 40),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.down.withValues(alpha: 0.1),
          ),
          child: const Icon(Icons.error_outline, size: 32, color: AppColors.down),
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.failedToLoad,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => context.read<AddTickersBloc>().add(
              Start(symbol: widget.assets.symbol),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(AppLocalizations.tryAgain),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
