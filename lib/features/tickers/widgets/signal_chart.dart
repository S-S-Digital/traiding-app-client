
import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minY: minY * 0.95, // немного отступ сверху/снизу
          maxY: maxY * 1.05,
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withValues(alpha:0.4), color.withValues(alpha:0.0)],
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
