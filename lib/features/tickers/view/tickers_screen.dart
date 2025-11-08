import 'package:aspiro_trade/features/tickers/bloc/bloc.dart';
import 'package:aspiro_trade/features/tickers/models/models.dart';
import 'package:aspiro_trade/repositories/assets/assets.dart';

import 'package:aspiro_trade/repositories/core/core.dart';

import 'package:aspiro_trade/repositories/tickers/tickers.dart';
import 'package:aspiro_trade/router/app_router.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:aspiro_trade/utils/methods/show_error_dialog.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class TickersScreen extends StatefulWidget {
  const TickersScreen({super.key});

  @override
  State<TickersScreen> createState() => _TickersScreenState();
}

class _TickersScreenState extends State<TickersScreen> {
  @override
  void initState() {
    context.read<TickersBloc>().add(Start());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          BaseAppBar(
            text: 'Активы',
            onPressed: () => AutoRouter.of(context).push(AssetsRoute()),
          ),

          BlocConsumer<TickersBloc, TickersState>(
            listener: (context, state) {
              if (state is TickersFailure) {
                showErrorDialog(
                  context,
                  state.error.message.toString(),
                  'Ок',
                  () {
                    if (state.error is UnauthorizedException) {
                      AutoRouter.of(context).pushAndPopUntil(
                        LoginRoute(),
                        predicate: (value) => false,
                      );
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                );
              }
            },
            buildWhen: (previous, current) => current.isBuildable,
            builder: (context, state) {
              if (state is TickersLoading) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      children: [
                        PlatformProgressIndicator(),
                        Text('Загрузка...'),
                      ],
                    ),
                  ),
                );
              }
              else if (state is TickersLoaded) {
                if (state.tickers.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 60,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.6),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Список тикеров пуст',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Вы можете добавить тикеры, нажав на кнопку "+" в верхнем правом углу.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverList.builder(
                  itemCount: state.tickers.length,
                  itemBuilder: (context, index) {
                    return TickersItem(tickers: state.tickers[index]);
                  },
                );
              }
              return SliverToBoxAdapter(child: Center(child: Text('data')));
            },
          ),
        ],
      ),
    );
  }
}

class TickersItem extends StatelessWidget {
  const TickersItem({super.key, required this.tickers});
  final CombinedTicker tickers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.025,
        vertical: size.height * 0.01,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: size.height * 0.9,
          minHeight: size.height * 0.3,
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CryptoListTile(
                imagePath: 'assets/pictures/bitcoin.png',
                title: tickers.tickers.symbol,
                subtitle: tickers.assets.name,
                size: CryptoListTileSize.large,
              ),
              Row(
                children: [
                  Text(
                    tickers.assets.formatPriceLogic(tickers.assets.price),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: tickers.assets.change24h[0] == '-'
                          ? theme.colorScheme.error.withValues(alpha: 0.2)
                          : theme.colorScheme.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '(${tickers.assets.change24h}%)',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: tickers.assets.change24h[0] == '-'
                            ? theme.colorScheme.error
                            : theme.colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: size.width * 0.3,
                  maxWidth: size.width * 0.6,
                ),
                child: Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: tickers.tickers.notifyBuy
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.error,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 6),
                      BlinkingDot(
                        color: tickers.tickers.notifyBuy
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.error,
                        size: 10,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Сигнал: ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: tickers.tickers.notifyBuy
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        tickers.tickers.notifyBuy ? 'ПОКУПКА ' : 'ПРОДАЖА',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: tickers.tickers.notifyBuy
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              SignalChart(
                height: 120,
                candles: tickers.candles,
                color: tickers.tickers.notifyBuy
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.error,
              ),

              Divider(),

              Table(
                // border: TableBorder.symmetric(inside: BorderSide(width: 0.2, color: Colors.grey)),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1.2),
                  2: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            'Время сигнала',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            'Цена входа',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            'Изменение',
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
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '12:25',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '121,123',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '+0.50%',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BlinkingDot extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const BlinkingDot({
    super.key,
    this.color = Colors.green,
    this.size = 15,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<BlinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 0.3).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
  final List<Candles> candles;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // создаём споты из close
    final spots = <FlSpot>[];
    for (var i = 0; i < candles.length; i++) {
      final close = double.tryParse(candles[i].close) ?? 0;
      spots.add(FlSpot(i.toDouble(), close));
    }

    // находим min и max для оси Y
    final yValues = spots.map((e) => e.y);
    final minY = yValues.isEmpty ? 0 : yValues.reduce((a, b) => a < b ? a : b);
    final maxY = yValues.isEmpty ? 1 : yValues.reduce((a, b) => a > b ? a : b);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minY: minY * 0.95, // немного отступ сверху/снизу
          maxY: maxY * 1.05,
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withOpacity(0.4), color.withOpacity(0.0)],
                ),
              ),
              spots: spots,
            ),
          ],
        ),
      ),
    );
  }
}

// class SignalChart extends StatelessWidget {
//   const SignalChart({
//     super.key,
//     required this.height,
//     required this.color,
//     required this.candles,
//   });
//   final double height;
//   final List<Candles> candles;
//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: height,
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: LineChart(
//         LineChartData(
//           gridData: FlGridData(show: false),
//           titlesData: FlTitlesData(show: false),
//           borderData: FlBorderData(show: false),
//           lineBarsData: [
//             LineChartBarData(
//               isCurved: false,
//               color: color,
//               barWidth: 3,
//               dotData: FlDotData(show: false),
//               belowBarData: BarAreaData(
//                 show: true,
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     color.withValues(alpha: 0.4),
//                     color.withValues(alpha: 0.0),
//                   ],
//                 ),
//               ),
//               spots: const [
//                 FlSpot(0, 1.15),
//                 FlSpot(1, 1.3),
//                 FlSpot(2, 1.1),
//                 FlSpot(3, 1.6),
//                 FlSpot(4, 1.4),
//                 FlSpot(5, 1.9),
//                 FlSpot(6, 1.7),
//               ],
//             ),
//           ],
//           minY: 0.8,
//           maxY: 2.0,
//         ),
//       ),
//     );
//   }
// }
