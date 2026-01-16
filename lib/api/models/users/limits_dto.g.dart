// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'limits_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LimitsDto _$LimitsDtoFromJson(Map<String, dynamic> json) => LimitsDto(
  isPremium: json['isPremium'] as bool,
  premiumUntil: json['premiumUntil'] == null
      ? null
      : DateTime.parse(json['premiumUntil'] as String),
  currentTickers: (json['currentTickers'] as num).toInt(),
  maxTickers: const MaxTickersConverter().fromJson(json['maxTickers']),
  canAddMoreTickers: json['canAddMoreTickers'] as bool,
  availableFeatures: (json['availableFeatures'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$LimitsDtoToJson(LimitsDto instance) => <String, dynamic>{
  'isPremium': instance.isPremium,
  'premiumUntil': instance.premiumUntil?.toIso8601String(),
  'currentTickers': instance.currentTickers,
  'maxTickers': const MaxTickersConverter().toJson(instance.maxTickers),
  'canAddMoreTickers': instance.canAddMoreTickers,
  'availableFeatures': instance.availableFeatures,
};
