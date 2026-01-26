
import 'package:aspiro_trade/repositories/payments/payments.dart';
import 'package:aspiro_trade/ui/ui.dart';
import 'package:flutter/material.dart';


class PrimeSubscription extends StatelessWidget {
  const PrimeSubscription({super.key, required this.plans, required this.onPay});

  final SubscriptionPlans plans;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: double.infinity,
          maxWidth: size.width,
        ),
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.cardColor.withValues(alpha: 0.5),
                theme.cardColor.withValues(alpha: 0.6),
                theme.cardColor.withValues(alpha: 0.15),
              ],
              stops: const [0.0, 0.4, 1.0],
            ),

            border: const Border.symmetric(
              vertical: BorderSide(color: AppColors.darkAccentGold, width: 2),
              horizontal: BorderSide(color: AppColors.darkAccentGold, width: 5),
            ),
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
                  color: AppColors.darkAccentGold,
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
                  color: AppColors.darkAccentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.darkAccentGold, width: 1),
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 10,
                ),
                child: Wrap(
                  spacing: 50,
                  runSpacing: 8,
                  children: plans.features.map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),

                      decoration: BoxDecoration(
                        color: AppColors.darkAccentGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.darkAccentGold,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        feature,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.darkAccentGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                height: 50,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.canvasColor,
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
              // SizedBox(
              //   width: double.infinity,
              //   height: size.height * 0.07,
              //   child: ApplePayButton(
              //     paymentConfiguration: applePayConfig,
              //     paymentItems: paymentItems,
                  
              //     style: theme.brightness == Brightness.light? ApplePayButtonStyle.white : ApplePayButtonStyle.black,
              //     type: ApplePayButtonType.buy,
              //     cornerRadius: 15,
              //     margin: const EdgeInsets.only(top: 15),
              //     onPaymentResult: onApplePayResult,
              //     loadingIndicator: const Center(
              //       child: PlatformProgressIndicator(),
              //     ),
              //   ),
              // ),

              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF59E0B), // gold
                      Color(0xFFFFC107), // lighter gold tone
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.darkShadow,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, // прозрачный фон
                    shadowColor: Colors.transparent, // убираем стандартную тень
                    minimumSize: Size(size.width, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onPay,
                  child: Text(
                    ('Подписаться за ${plans.price}\$'),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
