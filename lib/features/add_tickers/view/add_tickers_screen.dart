import 'package:aspiro_trade/features/add_tickers/bloc/add_tickers_bloc.dart';
import 'package:aspiro_trade/features/add_tickers/models/models.dart';
import 'package:aspiro_trade/features/tickers/bloc/bloc.dart' as tickersBloc;


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
    Timeframes(title: '1 час', value: '1h'),
    Timeframes(title: '2 часа', value: '2h'),
    Timeframes(title: '4 часа', value: '4h'),
    Timeframes(title: '1 день', value: '1d'),
    Timeframes(title: '2 дня', value: '2d'),
  ];
  

  @override
  void initState() {
    context.read<AddTickersBloc>().add(Start(symbol: widget.assets.symbol));
    super.initState();
  }
  

  @override
  void dispose() {
    context.read<AddTickersBloc>().close();
    super.dispose();
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
          if (state is AddTickersFailure) {
            if (state.error is AppException) {
              final currentState = state as AppException;

              showErrorDialog(context, 'Ok', currentState.message, () {
                if (currentState is UnauthorizedException) {
                  AutoRouter.of(
                    context,
                  ).pushAndPopUntil(LoginRoute(), predicate: (value) => false);
                } else {
                  Navigator.of(context).pop();
                }
              });
            }
          } else if (state is Close) {
            AutoRouter.of(context).pop(HomeRoute());
            context.read<tickersBloc.TickersBloc>().add(tickersBloc.Start());
          }
        },
        builder: (context, state) {
          if (state is AddTickersLoading) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PlatformProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Загрузка...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16),
              ],
            );
          }
          if (state is AddTickersLoaded) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CryptoListTile(
                  imagePath: 'assets/pictures/bitcoin.png',
                  title: widget.assets.baseAsset,
                  subtitle: widget.assets.name.toUpperCase(),
                  size: CryptoListTileSize.large,
                ),

                const SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: state.isValid
                        ? theme.colorScheme.secondary.withValues(alpha: 0.3)
                        : theme.colorScheme.error.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: state.isValid
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.error,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      state.isValid
                          ? 'Тикер найден на бирже'
                          : 'Тикер не найден на бирже',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: state.isValid
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Divider(),
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
                      state.isValid &&
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
                    state.isValid &&
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
                  child: Text('Добавить тикер'),
                ),
                SizedBox(height: 20),
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
              SizedBox(height: 16),
              Text(
                'Не удалось загрузить данные',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Попробуйте еще раз!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 20),
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
                child: Text('Попробовать еще раз'),
              ),

              SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
