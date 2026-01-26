
class SubscriptionPlans {
  SubscriptionPlans({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
    required this.currency,
    required this.appleProductId,
    required this.googleProductId,
    required this.maxTickers,
    required this.features,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

    SubscriptionPlans copyWith({
    String? id,
    String? name,
    String? description,
    int? duration,
    String? price,
    String? currency,
    String? appleProductId,
    String? googleProductId,
    int? maxTickers,
    List<String>? features,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionPlans(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      appleProductId: appleProductId ?? this.appleProductId,
      googleProductId: googleProductId ?? this.googleProductId,
      maxTickers: maxTickers ?? this.maxTickers,
      features: features ?? this.features,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  final String id;
  final String name;
  final String description;
  final int duration;
  final String price;
  final String currency;
  final String appleProductId;
  final String googleProductId;
  final int maxTickers;
  final List<String> features;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get readableDuration {
    switch (duration) {
      case 7:
        return '/неделя';
      case 30:
        return '/месяц';
      case 365:
        return '/год';
      default:
        return '$duration дней';
    }
  }

 List<String> get readableFeatures {
  return features.map((feature) {
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



}
