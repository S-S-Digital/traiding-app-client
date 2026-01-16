
import 'package:aspiro_trade/repositories/payments/payments.dart';
import 'package:flutter/material.dart';

class SubscriptionItem extends StatelessWidget {
  const SubscriptionItem({super.key, required this.plans, required this.onPay});

  final SubscriptionPlans plans;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: double.infinity ,
        maxWidth: size.width,
      ),
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plans.name,
              textAlign: TextAlign.left,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
            ),

            Text(
              plans.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.primaryColor, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '\$',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    plans.price,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    plans.readableDuration,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Включено:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Wrap(
              spacing: 8, // горизонтальный отступ между элементами
              runSpacing: 8, // вертикальный отступ между строками
              children: plans.features.map((feature) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.primaryColor, width: 1),
                  ),
                  child: Text(
                    feature,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              height: 50,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.canvasColor.withValues(alpha: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Spacer(),
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyLarge, // общий стиль
                      children: [
                        const TextSpan(text: 'до '),
                        TextSpan(
                          text: plans.maxTickers.toString(),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme
                                .colorScheme
                                .onPrimary, // или любой другой стиль для цифр
                          ),
                        ),
                        const TextSpan(text: ' тикеров, '),
                        TextSpan(
                          text: plans.duration.toString(),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        const TextSpan(text: ' дней'),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if(!plans.price.contains('0'))

              ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(Size(size.width, 50)),
                ),
                child: Text(
                  'Подписаться за ${plans.price} \$',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
