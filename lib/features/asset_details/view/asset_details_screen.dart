import 'dart:io' show Platform;
import 'package:aspiro_trade/features/add_tickers/add_tickers.dart';
import 'package:aspiro_trade/features/asset_details/bloc/asset_details_bloc.dart';
import 'package:aspiro_trade/features/assets/bloc/assets_bloc.dart'
    as assets_bloc;
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class AssetDetailsScreen extends StatefulWidget {
  const AssetDetailsScreen({super.key, required this.assets});
  final Assets assets;

  @override
  State<AssetDetailsScreen> createState() => _AssetDetailsScreenState();
}

class _AssetDetailsScreenState extends State<AssetDetailsScreen> {
  final List<Timeframes> timeframes = [
    Timeframes(title: '1 мин', value: '1m'),
    Timeframes(title: '3 мин', value: '3m'),
    Timeframes(title: '5 мин', value: '5m'),
    Timeframes(title: '15 мин', value: '15m'),
    Timeframes(title: '1 час', value: '1h'),
    Timeframes(title: '4 часа', value: '4h'),
    Timeframes(title: '1 день', value: '1d'),
  ];
  String activeFilter = '1 мин';

  @override
  void initState() {
    context.read<AssetDetailsBloc>().add(
      Start(symbol: widget.assets.symbol.toString()),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(widget.assets.baseAsset),
            pinned: true,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () {
                context.read<AssetDetailsBloc>().add(StopTimer());
                context.read<assets_bloc.AssetsBloc>().add(assets_bloc.Start());
                AutoRouter.of(context).back();
              },
              icon: Icon(
                Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocConsumer<AssetDetailsBloc, AssetDetailsState>(
                    listener: (context, state) {
                      if (state.status == Status.failure) {
                        if (state.error is AppException) {
                          final error = state.error as AppException;
                          context.handleException(error, context);
                        }
                      }
                    },
                    buildWhen: (previous, current) =>
                        current.status.isBuildable,
                    builder: (context, state) {
                      if (state.status == Status.loading) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              PlatformProgressIndicator(),
                              Text('загрузка...'),
                            ],
                          ),
                        );
                      }
                      if (state.status != Status.initial) {
                        return Column(
                          children: [
                            CryptoListTile(
                              imagePath: state.assets.logoUrl,
                              title: state.assets.baseAsset,
                              subtitle: state.assets.name.toUpperCase(),
                              size: CryptoListTileSize.large,
                            ),

                            Row(
                              children: [
                                Text(
                                  state.assets.price.isEmpty
                                      ? 'Нет данных'
                                      : '\$${state.assets.formatPriceLogic(state.assets.price)}',
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(
                                        color: theme.colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  state.assets.price.isEmpty
                                      ? ''
                                      : '(${state.assets.formatPriceLogic(state.assets.priceChangePercent)}%)',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: state.assets.change24h[0] == '-'
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),
                            Divider(color: theme.dividerColor),
                            const SizedBox(height: 10),

                            PriceTable(assets: state.assets),
                          ],
                        );
                      }
                      return const SizedBox();
                    },
                  ),

                  const SizedBox(height: 10),
                  Divider(color: theme.dividerColor),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 70,
                    child: BlocBuilder<AssetDetailsBloc, AssetDetailsState>(
                      builder: (context, state) {
                        if (state.status == Status.loading) {
                          return const SizedBox.shrink();
                        }
                        if (state.status != Status.initial) {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,

                            itemCount: timeframes.length,
                            itemBuilder: (context, index) {
                              final tf = timeframes[index];
                              final isSelected = state.selectedTimeframe == tf;
                              return AssetTimeframe(
                                tf: tf,
                                isSelected: isSelected,
                                symbol: widget.assets.symbol,
                              );
                            },
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),

                  BlocConsumer<AssetDetailsBloc, AssetDetailsState>(
                    listener: (context, state) {
                      if (state.status == Status.failure) {
                        if (state.error is AppException) {
                          final error = state.error as AppException;
                          context.handleException(error, context);
                        }
                      }
                    },
                    builder: (context, state) {
                      return BlocBuilder<AssetDetailsBloc, AssetDetailsState>(
                        builder: (context, state) {
                          if (state.status == Status.loading) {
                            return const SizedBox.shrink();
                          }

                          if (state.status != Status.initial) {
                            if (state.candles.isEmpty) {
                              return const SizedBox();
                            } else {
                              return SignalChart(
                                height: size.height * 0.3,
                                candles: state.candles,
                              );
                            }
                          }
                          return const Center(
                            child: PlatformProgressIndicator(),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 50),

                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) =>
                            AddTickersScreen(assets: widget.assets),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        theme.primaryColor,
                      ),
                      minimumSize: WidgetStatePropertyAll(
                        Size(size.width, size.height * 0.07),
                      ),
                    ),
                    child: Text(
                      'Добавить тикер',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AssetTimeframe extends StatelessWidget {
  const AssetTimeframe({
    super.key,

    required this.tf,
    required this.isSelected,
    required this.symbol,
  });

  final Timeframes tf;
  final bool isSelected;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        backgroundColor: theme.cardColor,
        label: Text(
          tf.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        showCheckmark: false,
        selected: isSelected,

        onSelected: (_) {
          talker.error(tf);
          context.read<AssetDetailsBloc>().add(
            SelectTimeframe(timeframe: tf, symbol: symbol),
          );
        },
        selectedColor: theme.primaryColor,
      ),
    );
  }
}

class PriceTable extends StatelessWidget {
  const PriceTable({super.key, required this.assets});
  final Assets assets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(0.8),
        1: FlexColumnWidth(0.8),
        2: FlexColumnWidth(0.8),
      },

      children: [
        TableRow(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  '24ч Макс',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  '24ч Мин',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  'Объём',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),

        TableRow(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  '\$${assets.formatPriceLogic(assets.high24h)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  '\$${assets.formatPriceLogic(assets.low24h)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  '\$${assets.formatPriceLogic(assets.volume24h)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SignalChart extends StatelessWidget {
  const SignalChart({super.key, required this.height, required this.candles});

  final double height;
  final List<Candles> candles;

  @override
  Widget build(BuildContext context) {
    if (candles.isEmpty) {
      return Container(
        height: height,
        alignment: Alignment.center,
        child: const Text('Нет данных', style: TextStyle(color: Colors.grey)),
      );
    }

    final candleData = candles
        .map((c) {
          return Candle(
            date: DateTime.fromMillisecondsSinceEpoch(c.openTime),
            high: double.parse(c.high),
            low: double.parse(c.low),
            open: double.parse(c.open),
            close: double.parse(c.close),
            volume: double.parse(c.volume),
          );
        })
        .toList()
        .reversed
        .toList();

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Candlesticks(candles: candleData),
    );
  }
}
