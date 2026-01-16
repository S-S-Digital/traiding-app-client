import 'package:aspiro_trade/features/tickers/widgets/widgets.dart';
import 'package:aspiro_trade/utils/utils.dart';
import 'package:flutter/material.dart';

class SignalIndicator extends StatelessWidget {
  const SignalIndicator({super.key, required this.status});

  final SignalStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color color;
    String text;

    switch (status) {
      case SignalStatus.buy:
        color = theme.colorScheme.secondary; // зелёный
        text = 'ПОКУПКА';
        break;
      case SignalStatus.sell:
        color = theme.colorScheme.error; // красный
        text = 'ПРОДАЖА';
        break;
      case SignalStatus.none:
        color = Colors.grey; // нет сигнала
        text = 'ОЖИДАНИЕ';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 6),
          BlinkingDot(color: color, size: 10),
          const SizedBox(width: 6),
          Text(
            'Сигнал: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
