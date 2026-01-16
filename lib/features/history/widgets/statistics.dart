
import 'package:aspiro_trade/features/history/models/models.dart';
import 'package:flutter/material.dart';

class Statistics extends StatelessWidget {
  const Statistics({super.key, required this.stat});

  final HistoryStatistics stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        height: size.height * 0.07,
        width: size.width * 0.28,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stat.title,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(
              stat.value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: stat.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
