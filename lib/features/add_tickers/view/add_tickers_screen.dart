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
  final List<Timeframes> timeframeOptions = [
    Timeframes(title: '15m', value: '15m'),
    Timeframes(title: '1H', value: '1h'),
    Timeframes(title: '1D', value: '1d'),
    Timeframes(title: '1W', value: '1w'),
    Timeframes(title: '1M', value: '1M'),
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
                  'Этот тикер с таким таймфреймом уже добавлен',
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
                  'Необходимо оформить подписку для добавления тикеров',
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
        buildWhen: (previous, current) => current.status.isBuildable,
        builder: (context, state) {
          if (state.status == Status.loading) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 40),
                PlatformProgressIndicator(),
                SizedBox(height: 12),
                Text(
                  'Загрузка...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 40),
              ],
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
    final canSubmit = isValid &&
        state.selectedOption != null &&
        state.selectedTimeframe != null;

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

        // ── Title ──
        const Text(
          'Добавить тикер',
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
            color: isValid
                ? AppColors.brand.withValues(alpha: 0.06)
                : AppColors.elevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isValid
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
                    widget.assets.logoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        widget.assets.baseAsset.isNotEmpty
                            ? widget.assets.baseAsset[0]
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
                      widget.assets.symbol,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      widget.assets.name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isValid)
                const Text(
                  'Найден',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brand,
                  ),
                )
              else
                const Text(
                  'Не найден',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.down,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ── Timeframe ──
        const Text(
          'ТАЙМФРЕЙМ',
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
          children: timeframeOptions.map((tf) {
            final isSelected = state.selectedTimeframe == tf;
            return GestureDetector(
              onTap: () => context
                  .read<AddTickersBloc>()
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
                    color: isSelected
                        ? AppColors.brand
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // ── Notifications ──
        const Text(
          'УВЕДОМЛЕНИЯ',
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
                    title: 'Покупка и продажа',
                    subtitle: '',
                    notifyBuy: !(state.selectedOption?.notifyBuy ?? false),
                    notifySell: state.selectedOption?.notifySell ?? true,
                  );
                  context.read<AddTickersBloc>().add(SelectOption(option: opt));
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (state.selectedOption?.notifyBuy ?? false)
                        ? AppColors.up.withValues(alpha: 0.06)
                        : AppColors.elevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (state.selectedOption?.notifyBuy ?? false)
                          ? AppColors.up.withValues(alpha: 0.12)
                          : AppColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Buy Signals',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: (state.selectedOption?.notifyBuy ?? false)
                              ? AppColors.up
                              : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (state.selectedOption?.notifyBuy ?? false)
                            ? 'Enabled'
                            : 'Disabled',
                        style: TextStyle(
                          fontSize: 11,
                          color: (state.selectedOption?.notifyBuy ?? false)
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
                    title: 'Покупка и продажа',
                    subtitle: '',
                    notifyBuy: state.selectedOption?.notifyBuy ?? true,
                    notifySell: !(state.selectedOption?.notifySell ?? false),
                  );
                  context.read<AddTickersBloc>().add(SelectOption(option: opt));
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (state.selectedOption?.notifySell ?? false)
                        ? AppColors.down.withValues(alpha: 0.06)
                        : AppColors.elevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (state.selectedOption?.notifySell ?? false)
                          ? AppColors.down.withValues(alpha: 0.12)
                          : AppColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Sell Signals',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: (state.selectedOption?.notifySell ?? false)
                              ? AppColors.down
                              : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (state.selectedOption?.notifySell ?? false)
                            ? 'Enabled'
                            : 'Disabled',
                        style: TextStyle(
                          fontSize: 11,
                          color: (state.selectedOption?.notifySell ?? false)
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
            onPressed: canSubmit
                ? () => context.read<AddTickersBloc>().add(
                      AddNewTicker(
                        symbol: widget.assets.symbol,
                        timeframe: state.selectedTimeframe!.value,
                        notifyBuy: state.selectedOption!.notifyBuy,
                        notifySell: state.selectedOption!.notifySell,
                      ),
                    )
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  canSubmit ? AppColors.brand : AppColors.elevated,
              foregroundColor: AppColors.background,
              disabledBackgroundColor: AppColors.elevated,
              disabledForegroundColor: AppColors.textQuaternary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              'Добавить ${widget.assets.symbol}${state.selectedTimeframe != null ? " · ${state.selectedTimeframe!.title}" : ""}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
        const Text(
          'Не удалось загрузить',
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
            child: const Text('Попробовать снова'),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
