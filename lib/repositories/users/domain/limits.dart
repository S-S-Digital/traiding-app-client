import 'package:aspiro_trade/api/api.dart';
import 'package:equatable/equatable.dart';

class Limits extends Equatable {
  const Limits({
    required this.isPremium,
    required this.premiumUntil,
    required this.currentTickers,
    required this.maxTickers,
    required this.canAddMoreTickers,
    required this.availableFeatures,
  });
  final bool isPremium;
  final DateTime? premiumUntil;
  final int currentTickers;
  final MaxTickersValue maxTickers;
  final bool canAddMoreTickers;
  final List<String> availableFeatures;

  /// Удобный метод: сколько осталось доступных слотов
  int? get remainingSlots {
    if (maxTickers.type == MaxTickersType.unlimited) return null;
    return maxTickers.value! - currentTickers;
  }

  /// Удобный метод: проверка, действительно ли подписка активна сейчас
  bool get isSubscriptionActive {
    if (!isPremium) return false;
    if (premiumUntil == null) return true;
    return premiumUntil!.isAfter(DateTime.now());
  }

  List<String> get readableFeatures {
  return availableFeatures.map((feature) {
    switch (feature) {
      case 'view_signals':
        return 'Просмотр сигналов';

      case 'add_tickers':
        return 'Добавление тикеров';

      case 'receive_signals':
        return 'Получение сигналов';

      case 'push_notifications':
        return 'Push-уведомления';

      case 'signal_history':
        return 'История сигналов';

      case 'advanced_analytics':
        return 'Расширенная аналитика';

      case 'priority_support':
        return 'Приоритетная поддержка';

      case 'unlimited_signals':
        return 'Неограниченные сигналы';

      case 'custom_alerts':
        return 'Пользовательские уведомления';

      case 'lifetime_updates':
        return 'Обновления на всю жизнь';

      default:
        return feature;
    }
  }).toList();
}

  @override
  List<Object?> get props => [
    isPremium,
    premiumUntil,
    currentTickers,
    maxTickers,
    canAddMoreTickers,
    availableFeatures,
  ];
}
