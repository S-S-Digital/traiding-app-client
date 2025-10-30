import 'package:aspiro_trade/ui/ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

@RoutePage()
class AssetDetailsScreen extends StatefulWidget {
  const AssetDetailsScreen({super.key});

  @override
  State<AssetDetailsScreen> createState() => _AssetDetailsScreenState();
}

class _AssetDetailsScreenState extends State<AssetDetailsScreen> {
  final candles = [
    CandleData(
      open: 112898.44,
      high: 113643.73,
      low: 109200.00,
      close: 110021.29,
    ),
    CandleData(
      open: 110021.30,
      high: 111592.00,
      low: 106716.71,
      close: 106967.78,
    ),
  ];
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('BTC'),
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
                    title: 'Bitcoin',
                    subtitle: 'btc'.toUpperCase(),
                    size: CryptoListTileSize.large,
                  ),

                  Text(
                    '\$68,452.23',
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
                        '(+2.35%)',
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

                  SignalChart(
                    height: 300,
                    color: theme.colorScheme.onSecondary,
                    candles: candles,
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
                        onPressed: () {},
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

class CandleData {
  final double open;
  final double close;
  final double high;
  final double low;

  CandleData({
    required this.open,
    required this.close,
    required this.high,
    required this.low,
  });
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
  final List<CandleData> candles;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          barGroups: _buildBars(),
          maxY: candles.map((e) => e.high).reduce((a, b) => a > b ? a : b),
          minY: candles.map((e) => e.low).reduce((a, b) => a < b ? a : b),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBars() {
    return List.generate(candles.length, (i) {
      final c = candles[i];
      final isGrow = c.close >= c.open;
      final bodyTop = isGrow ? c.close : c.open;
      final bodyBottom = isGrow ? c.open : c.close;

      return BarChartGroupData(
        x: i,
        barRods: [
          // Основная тень (high–low)
          BarChartRodData(
            toY: c.high,
            fromY: c.low,
            width: 1.5,
            color: Colors.grey.shade400,
          ),
          // Тело свечи (open–close)
          BarChartRodData(
            toY: bodyTop,
            fromY: bodyBottom,
            width: 10,
            color: isGrow ? Colors.green : Colors.red,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    });
  }
}
