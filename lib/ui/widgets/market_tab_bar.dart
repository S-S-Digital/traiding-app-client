import 'package:aspiro_trade/api/models/app_config/app_config_dto.dart';
import 'package:aspiro_trade/services/config/app_config_cubit.dart';
import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Market-category selector, rendered from `app-config`'s `markets[]`.
///
/// PHASE 0 SAFETY: when 0 or 1 market is enabled (today: only `crypto`) this
/// renders NOTHING — the app stays implicitly single-market, exactly as before.
/// The chip row only appears once a second market is flipped on server-side,
/// at which point [onSelected] lets the host filter its content by market id.
class MarketTabBar extends StatelessWidget {
  const MarketTabBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  /// Currently-selected market id (e.g. `crypto`).
  final String selected;
  final ValueChanged<String> onSelected;

  /// Maps server material-icon keys to [IconData]. Unknown keys ⇒ a neutral
  /// fallback. Kept tiny on purpose (tree-shake-safe constant icons).
  static IconData iconFor(String? key) {
    switch (key) {
      case 'currency_bitcoin':
        return Icons.currency_bitcoin;
      case 'currency_exchange':
        return Icons.currency_exchange;
      case 'show_chart':
        return Icons.show_chart;
      case 'oil_barrel':
        return Icons.oil_barrel;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final markets =
        context.watch<AppConfigCubit>().state.config.enabledMarkets;
    // Single (or no) market ⇒ no selector: byte-for-byte identical to today.
    if (markets.length <= 1) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: markets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final MarketDto m = markets[i];
          final isSel = m.id == selected;
          return GestureDetector(
            onTap: () => onSelected(m.id),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSel
                    ? AppColors.brand.withValues(alpha: 0.12)
                    : AppColors.card.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSel
                      ? AppColors.brand.withValues(alpha: 0.5)
                      : AppColors.border.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(iconFor(m.icon),
                      size: 15,
                      color: isSel ? AppColors.brand : AppColors.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    m.name,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color:
                          isSel ? AppColors.textPrimary : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
