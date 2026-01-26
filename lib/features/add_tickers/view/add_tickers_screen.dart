import 'package:aspiro_trade/features/add_tickers/bloc/add_tickers_bloc.dart';
import 'package:aspiro_trade/features/add_tickers/models/models.dart';
import 'package:aspiro_trade/features/tickers/bloc/bloc.dart' as tickers_bloc;

import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/router/router.dart';
import 'package:aspiro_trade/ui/ui.dart';
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
  final List<Options> options = [
    Options(
      title: 'Покупка и продажа',
      subtitle: 'уведомления о всех типах сигналов',
      notifyBuy: true,
      notifySell: true,
    ),
    Options(
      title: 'Только покупка',
      subtitle: 'Уведомления только о сигналах покупки',
      notifyBuy: true,
      notifySell: false,
    ),
    Options(
      title: 'Только продажа',
      subtitle: 'Уведомления только о сигналах продажи',
      notifyBuy: false,
      notifySell: true,
    ),
  ];
  final List<Timeframes> timeframeOptions = [
    Timeframes(title: '15 минут', value: '15m'),
    Timeframes(title: '1 час', value: '1h'),
    Timeframes(title: '1 день', value: '1d'),
    Timeframes(title: '1 неделя', value: '1w'),
    Timeframes(title: '1 месяц', value: '1M'),
  ];

  @override
  void initState() {
    context.read<AddTickersBloc>().add(Start(symbol: widget.assets.symbol));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: BlocConsumer<AddTickersBloc, AddTickersState>(
        listener: (context, state) {
          if (state.status == Status.failure) {
            if (state.error is AppException) {
              final error = state.error as AppException;
              if (error is ConflictException) {
                showErrorDialog(
                  context,
                  'Видимо вы уже добавили этот тикер с таким таймфреймом',
                  'ok',
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
                  'Чтобы добавить новый тикер, вам необходимо оформить подписку или расширить лимиты текущего тарифного плана.',
                  'ok',
                  () {
                    if (context.mounted) {
                      // Navigator.of(context).pop();
                      AutoRouter.of(context).pushAndPopUntil(
                        const HomeRoute(),
                        predicate: (value) => false,
                      );
                    }
                  },
                );
              } else {
                showErrorDialog(context, error.message, 'ok', () {
                  if (error is UnauthorizedException) {
                    if (context.mounted) {
                      AutoRouter.of(context).pushAndPopUntil(
                        const LoginRoute(),
                        predicate: (value) => false,
                      );
                    }
                  } else {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                });
              }
            }
          } else if (state.status == Status.success) {
            if (context.mounted) {
              context.read<tickers_bloc.TickersBloc>().add(
                tickers_bloc.Start(),
              );

              AutoRouter.of(context).pop(const HomeRoute());
            }
          }
        },
        buildWhen: (previous, current) => current.status.isBuildable,
        builder: (context, state) {
          if (state.status == Status.loading) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PlatformProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Загрузка...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }
          if (state.status != Status.initial) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CryptoListTile(
                  imagePath: widget.assets.logoUrl,
                  title: widget.assets.baseAsset,
                  subtitle: widget.assets.name.toUpperCase(),
                  size: CryptoListTileSize.large,
                ),

                const SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: state.status == Status.submit
                        ? theme.colorScheme.secondary.withValues(alpha: 0.3)
                        : theme.colorScheme.error.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                    border: Border.all(
                      color: state.status == Status.submit
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.error,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      state.status == Status.submit
                          ? 'Тикер найден на бирже'
                          : 'Тикер не найден на бирже',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: state.status == Status.submit
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // TickerStatus(isValid: state.isValid),
                const SizedBox(height: 10),

                const Divider(),
                const SizedBox(height: 10),

                Text(
                  'Выберите таймфрейм'.toUpperCase(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: timeframeOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final tf = timeframeOptions[index];
                      final isSelected = state.selectedTimeframe == tf;
                      return ChoiceChip(
                        label: Text(tf.title),
                        selected: isSelected,
                        onSelected: (_) {
                          context.read<AddTickersBloc>().add(
                            SelectTimeframe(timeframe: tf),
                          );
                        },
                        showCheckmark: false,
                        selectedColor: theme.colorScheme.primary,
                        backgroundColor: theme.cardColor,
                        labelStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Уведомления о сигналах'.toUpperCase(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),

                const SizedBox(height: 16),

                ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = state.selectedOption == option;
                    return GestureDetector(
                      onTap: () => context.read<AddTickersBloc>().add(
                        SelectOption(option: option),
                      ),
                      child: Card(
                        color: theme.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(16),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.canvasColor,
                            width: 2,
                          ),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Radio<String>(
                                value: option.title,
                                groupValue: state.selectedOption?.title,
                                onChanged: (value) => context
                                    .read<AddTickersBloc>()
                                    .add(SelectOption(option: option)),
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.title,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),

                                  Text(
                                    option.subtitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w700,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                    softWrap: true,
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                ElevatedButton(
                  style: ButtonStyle(
                    minimumSize: WidgetStatePropertyAll(
                      Size(size.width, size.height * 0.07),
                    ),
                    backgroundColor: WidgetStatePropertyAll(
                      state.status == Status.submit &&
                              state.selectedOption != null &&
                              state.selectedTimeframe != null
                          ? theme.colorScheme.primary
                          : theme.cardColor,
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(20),
                      ),
                    ),
                  ),
                  onPressed: () {
                    state.status == Status.submit &&
                            state.selectedOption != null &&
                            state.selectedTimeframe != null
                        ? context.read<AddTickersBloc>().add(
                            AddNewTicker(
                              symbol: widget.assets.symbol,
                              timeframe: state.selectedTimeframe!.value,
                              notifyBuy: state.selectedOption!.notifyBuy,
                              notifySell: state.selectedOption!.notifySell,
                            ),
                          )
                        : null;
                  },
                  child: const Text('Добавить тикер'),
                ),
                const SizedBox(height: 20),
              ],
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Не удалось загрузить данные',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Попробуйте еще раз!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(
                    Size(size.width, size.height * 0.06),
                  ),
                  backgroundColor: WidgetStatePropertyAll(
                    theme.colorScheme.primary,
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(20),
                    ),
                  ),
                ),
                onPressed: () => context.read<AddTickersBloc>().add(
                  Start(symbol: widget.assets.symbol),
                ),
                child: const Text('Попробовать еще раз'),
              ),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}



class TickerStatus extends StatefulWidget {
  final bool isValid;
  const TickerStatus({super.key, required this.isValid});

  @override
  State<TickerStatus> createState() => _TickerStatusState();
}

class _TickerStatusState extends State<TickerStatus>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.4,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.isValid
              ? theme.colorScheme.secondary.withValues(alpha: 0.3)
              : theme.colorScheme.error.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isValid
                ? theme.colorScheme.secondary
                : theme.colorScheme.error,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            widget.isValid
                ? 'Тикер найден на бирже'
                : 'Тикер не найден на бирже',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: widget.isValid
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
