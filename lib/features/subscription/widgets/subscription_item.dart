import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/core/core.dart';
import 'package:aspiro_trade/repositories/payments/payments.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:flutter/material.dart';

class SubscriptionItem extends StatelessWidget {
  const SubscriptionItem({
    super.key,
    required this.plans,
    required this.onPay,
    this.subscriptions,
    this.isLoading = false,
  });

  final SubscriptionPlans plans;
  final SubscriptionsDto? subscriptions;
  final VoidCallback onPay;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: double.infinity,
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
                    plans.price.toString(),
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
              children: plans.readableFeatures.map((feature) {
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
            if (subscriptions != null && plans.price != "0")
              ElevatedButton(
                onPressed:
                    subscriptions != null &&
                            subscriptions!.planId.contains(plans.id) ||
                        isLoading
                    ? null
                    : onPay,
                style: ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(Size(size.width, 50)),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: PlatformProgressIndicator()
                      )
                    : () {
                        final bool hasActiveSub = subscriptions != null;
                        final bool isThisPlanActive =
                            hasActiveSub && subscriptions!.planId == plans.id;
                        final bool isFreePlan =
                            (plans.price == "0" || plans.price == "0.0");
                        talker.debug(isFreePlan);

                        if (isThisPlanActive) {
                          return const Text('Ваш текущий тариф');
                        }

                        if (isFreePlan) {
                          // Если у пользователя есть ЛЮБАЯ активная подписка (например PRO),
                          // а мы смотрим на карточку FREE
                          return const Text('');
                        }

                        return Text('Подписаться за ${plans.price} \$');
                      }(),
              ),
            if (subscriptions == null)
              ElevatedButton(
                onPressed: plans.price.contains('0') ? null : onPay,
                style: ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(Size(size.width, 50)),
                ),
                child: () {
                  final bool hasActiveSub = subscriptions != null;
                  final bool isThisPlanActive =
                      hasActiveSub && subscriptions!.planId == plans.id;
                  final bool isFreePlan =
                      plans.price == "0" || plans.price == "0.0";

                  if (isThisPlanActive) {
                    return const Text('Ваш текущий тариф');
                  }

                  if (isFreePlan) {
                    // Если у пользователя есть ЛЮБАЯ активная подписка (например PRO),
                    // а мы смотрим на карточку FREE
                    return const Text('У вас обычный тариф');
                  }

                  return Text('Подписаться за ${plans.price} \$');
                }(),
              ),
          ],
        ),
      ),
    );
  }
}
