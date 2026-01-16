import 'package:aspiro_trade/features/tickers/models/models.dart';
import 'package:aspiro_trade/features/update_tickers/bloc/update_tickers_bloc.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/router/router.dart';
import 'package:aspiro_trade/ui/ui.dart';
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
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16)
        ),
      ),
      child: BlocConsumer<UpdateTickersBloc, UpdateTickersState>(
        listener: (context, state) {
          if (state is UpdateTickersFailure) {
            if (state.error is AppException) {
              final error = state.error as AppException;
              showErrorDialog(context, error.message, 'ok', () {
                if (error is UnauthorizedException) {
                  AutoRouter.of(
                    context,
                  ).pushAndPopUntil(const LoginRoute(), predicate: (value) => false);
                } else {
                  Navigator.of(context).pop();
                }
              });
            } 
          }
          else if (state is Close) {
              context.read<tickers_bloc.TickersBloc>().add(
                tickers_bloc.Start(),
              );
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }
        },
        builder: (context, state) {
          if (state is UpdateTickersLoading) {
            return SizedBox(
              height: size.height * 0.8,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [PlatformProgressIndicator(), Text('Загрузка...')],
                ),
              ),
            );
          }
          if (state is UpdateTickersLoaded) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CryptoListTile(
                  imagePath: widget.tickers.assets.logoUrl,
                  title: widget.tickers.assets.baseAsset,
                  subtitle: widget.tickers.assets.name.toUpperCase(),
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
                    itemCount: state.timeframes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final tf = state.timeframes[index];
                      final isSelected = state.selectedTimeframe == tf;
                      return ChoiceChip(
                        label: Text(tf.title),
                        selected: isSelected,
                        onSelected: (_) {
                          context.read<UpdateTickersBloc>().add(
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
                  itemCount: state.options.length,
                  itemBuilder: (context, index) {
                    final option = state.options[index];
                    final isSelected = state.selectedOption == option;
                    return GestureDetector(
                      onTap: () => context.read<UpdateTickersBloc>().add(
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
                                groupValue: state.selectedOption.title,
                                onChanged: (value) {},
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
                      state.isValid
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
                    state.isValid
                        ? context.read<UpdateTickersBloc>().add(
                            UpdateTicker(
                              id: widget.tickers.tickers.id,
                              symbol: widget.tickers.tickers.symbol,
                              timeframe: state.selectedTimeframe.value,
                              notifyBuy: state.selectedOption.notifyBuy,
                              notifySell: state.selectedOption.notifySell,
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
          return const SizedBox(height: 100);
        },
      ),
    );
  }
}
