import 'package:aspiro_trade/repositories/users/users.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'limits_dto.g.dart';

/// Тип значения maxTickers
enum MaxTickersType { number, unlimited }

/// Value-object для поля maxTickers
class MaxTickersValue extends Equatable {
  final MaxTickersType type;
  final int? value;

  const MaxTickersValue.number(this.value) : type = MaxTickersType.number;
  const MaxTickersValue.unlimited()
    : type = MaxTickersType.unlimited,
      value = null;

  @override
  List<Object?> get props => [type, value];
}

/// Конвертер для JSON
class MaxTickersConverter implements JsonConverter<MaxTickersValue, dynamic> {
  const MaxTickersConverter();

  @override
  MaxTickersValue fromJson(dynamic json) {
    if (json is int) {
      return MaxTickersValue.number(json);
    }
    if (json == 'unlimited') {
      return const MaxTickersValue.unlimited();
    }
    throw Exception('Invalid maxTickers value: $json');
  }

  @override
  dynamic toJson(MaxTickersValue object) {
    return object.type == MaxTickersType.unlimited ? 'unlimited' : object.value;
  }
}

@JsonSerializable()
class LimitsDto extends Equatable {
  final bool isPremium;
  final DateTime? premiumUntil;
  final int currentTickers;

  @MaxTickersConverter()
  final MaxTickersValue maxTickers;

  final bool canAddMoreTickers;
  final List<String> availableFeatures;

  const LimitsDto({
    required this.isPremium,
    required this.premiumUntil,
    required this.currentTickers,
    required this.maxTickers,
    required this.canAddMoreTickers,
    required this.availableFeatures,
  });

  factory LimitsDto.fromJson(Map<String, dynamic> json) =>
      _$LimitsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LimitsDtoToJson(this);

  Limits toEntity() => Limits(
    isPremium: isPremium,
    premiumUntil: premiumUntil,
    currentTickers: currentTickers,
    maxTickers: maxTickers,
    canAddMoreTickers: canAddMoreTickers,
    availableFeatures: availableFeatures,
  );

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
