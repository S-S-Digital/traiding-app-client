import 'package:aspiro_trade/ui/localization/app_localizations.dart';
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

  String get premiumUntilFormatted {
    final d = premiumUntil;
    if (d == null) return '-';
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day.$month.${d.year}';
  }

  List<String> get readableFeatures {
    return availableFeatures.map((feature) => AppLocalizations.readableFeature(feature)).toList();
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
