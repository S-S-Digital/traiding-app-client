import 'package:aspiro_trade/features/add_tickers/add_tickers.dart';
import 'package:aspiro_trade/features/asset_details/bloc/asset_details_bloc.dart';

import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:aspiro_trade/ui/ui.dart';

import 'package:auto_route/auto_route.dart';

import 'package:fl_chart/fl_chart.dart';
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
  final filters = [
    '1 мин',
    '3 мин',
    '5 мин',
    '15 мин',
    '1 час',
    '4 часа',
    '1 день',
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
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CryptoListTile(
                    imagePath: 'assets/pictures/bitcoin.png',
                    title: widget.assets.baseAsset,
                    subtitle: widget.assets.name.toUpperCase(),
                    size: CryptoListTileSize.large,
                  ),

                  Text(
                    '\$${widget.assets.price}',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Text(
                        '+\$1,605.78',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '(${widget.assets.change24h}%)',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Divider(color: theme.dividerColor),
                  SizedBox(height: 10),

                  Table(
                    // border: TableBorder.symmetric(
                    //   inside: BorderSide(width: 0.2, color: Colors.grey),
                    // ),
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
                              padding: EdgeInsets.symmetric(vertical: 3),
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
                              padding: EdgeInsets.symmetric(vertical: 3),
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
                              padding: EdgeInsets.symmetric(vertical: 3),
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
                              padding: EdgeInsets.symmetric(vertical: 3),
                              child: Text(
                                '\$69,123',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 3),
                              child: Text(
                                '\$66,892',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 3),
                              child: Text(
                                '\$28.5B',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 10),
                  Divider(color: theme.dividerColor),
                  SizedBox(height: 10),

                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,

                      itemCount: filters.length,
                      itemBuilder: (context, index) {
                        final filter = filters[index];
                        final isActive = filter == activeFilter;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            backgroundColor: theme.cardColor,
                            label: Text(
                              filter,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            showCheckmark: false,
                            selected: isActive,

                            onSelected: (_) {
                              setState(() => activeFilter = filter);
                            },
                            selectedColor: theme.primaryColor,
                          ),
                        );
                      },
                    ),
                  ),

                  BlocConsumer<AssetDetailsBloc, AssetDetailsState>(
                    listener: (context, state) {
                      if (state is AssetDetailsFailure) {}
                    },
                    builder: (context, state) {
                      return BlocBuilder<AssetDetailsBloc, AssetDetailsState>(
                        builder: (context, state) {
                          if (state is AssetDetailsLoaded) {
                            return SignalChart(
                              height: size.height * 0.3,
                              color: theme.colorScheme.onSecondary,
                              candles: state.candles,
                            );
                          }
                          return Center(child: PlatformProgressIndicator());
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            theme.cardColor,
                          ),
                        ),
                        child: Text(
                          'Отслеживать',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

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
                        ),
                        child: Text(
                          'В портфель',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SignalChart extends StatelessWidget {
  const SignalChart({
    super.key,
    required this.height,
    required this.color,
    required this.candles,
  });

  final double height;
  final Color color;
  final List<Candles> candles;

  @override
  Widget build(BuildContext context) {
    final maxY = candles
        .map((e) => double.parse(e.high))
        .reduce((a, b) => a > b ? a : b);
    final minY = candles
        .map((e) => double.parse(e.low))
        .reduce((a, b) => a < b ? a : b);

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          barTouchData: BarTouchData(enabled: true),
          maxY: maxY * 1.001,
          minY: minY * 0.999,
          barGroups: _buildBars(),
        ),
        swapAnimationDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  List<BarChartGroupData> _buildBars() {
    return List.generate(candles.length, (i) {
      final c = candles[i];
      final open = double.parse(c.open);
      final close = double.parse(c.close);
      final high = double.parse(c.high);
      final low = double.parse(c.low);

      final isGrow = close >= open;
      final bodyTop = isGrow ? close : open;
      final bodyBottom = isGrow ? open : close;

      return BarChartGroupData(
        x: i,
        barsSpace: 0,
        barRods: [
          // тень (high–low)
          BarChartRodData(
            toY: high,
            fromY: low,
            width: 1.5,
            color: Colors.grey.shade500,
            borderRadius: BorderRadius.zero,
          ),
          // тело свечи
          BarChartRodData(
            toY: bodyTop,
            fromY: bodyBottom,
            width: 6,
            color: isGrow ? AppColors.darkAccentGreen : AppColors.darkAccentRed,
            borderRadius: BorderRadius.circular(1),
          ),
        ],
      );
    });
  }
}
