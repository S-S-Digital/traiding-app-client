import 'package:aspiro_trade/features/tickers/bloc/bloc.dart';
import 'package:aspiro_trade/repositories/core/exceptions/exceptions.dart';
import 'package:aspiro_trade/repositories/tickers/tickers.dart';
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
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          BaseAppBar(text: 'Активы'),

          BlocConsumer<TickersBloc, TickersState>(
            listener: (context, state) {
              if(state is TickersFailure){
                
                  showErrorDialog(context, state.error.toString());
                

              }
            },
            buildWhen: (previous, current) => current.isBuildable,
            builder: (context, state) {
              if(state is TickersLoaded){
              return SliverList.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return TickersItem(tickers: state.tickers[index],);
                },
              );
              }
              return SliverToBoxAdapter(child: Center(
                child: Text('data'),
              ),);
            },
          ),
        ],
      ),
    );
  }
}

class TickersItem extends StatelessWidget {
  const TickersItem({
    super.key,
    required this.tickers
    
  });
  final Tickers tickers;

  

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
                title: tickers.symbol,
                subtitle: 'Binance',
                size: CryptoListTileSize.large,
              ),
              Row(
                children: [
                  Text(
                    '122,426.54',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onPrimary,
                        ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '+1,123.59(+0.93%)',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.secondary,
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
                    color: theme.colorScheme.secondary.withValues(
                      alpha: 0.2,
                    ),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: tickers.notifyBuy? theme.colorScheme.secondary :theme.colorScheme.error,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 6),
                      BlinkingDot(
                        color: tickers.notifyBuy? theme.colorScheme.secondary :theme.colorScheme.error,
                        size: 10,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Сигнал: ',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(
                              color: tickers.notifyBuy? theme.colorScheme.secondary :theme.colorScheme.error,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        tickers.notifyBuy?
                        'ПОКУПКА ' : 'ПРОДАЖА',
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(
                              color: tickers.notifyBuy? theme.colorScheme.secondary :theme.colorScheme.error,
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
                color: tickers.notifyBuy? theme.colorScheme.secondary :theme.colorScheme.error,
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
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                          ),
                          child: Text(
                            'Время сигнала',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                          ),
                          child: Text(
                            'Цена входа',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                          ),
                          child: Text(
                            'Изменение',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(
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
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                          ),
                          child: Text(
                            '12:25',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(
                                  color:
                                      theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                          ),
                          child: Text(
                            '121,123',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(
                                  color:
                                      theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                          ),
                          child: Text(
                            '+0.50%',
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(
                                  color:
                                      theme.colorScheme.secondary,
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
  const SignalChart({super.key, required this.height, required this.color});
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: false,
              color: color,
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.4),
                    color.withValues(alpha: 0.0),
                  ],
                ),
              ),
              spots: const [
                FlSpot(0, 1.15),
                FlSpot(1, 1.3),
                FlSpot(2, 1.1),
                FlSpot(3, 1.6),
                FlSpot(4, 1.4),
                FlSpot(5, 1.9),
                FlSpot(6, 1.7),
              ],
            ),
          ],
          minY: 0.8,
          maxY: 2.0,
        ),
      ),
    );
  }
}
