// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assets_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetsDto _$AssetsDtoFromJson(Map<String, dynamic> json) => AssetsDto(
  symbol: json['symbol'] as String,
  name: json['name'] as String,
  baseAsset: json['baseAsset'] as String,
  quoteAsset: json['quoteAsset'] as String,
  price: json['price'] as String,
  change24h: json['change24h'] as String,
  logoUrl: json['logoUrl'] as String,
);

Map<String, dynamic> _$AssetsDtoToJson(AssetsDto instance) => <String, dynamic>{
  'symbol': instance.symbol,
  'name': instance.name,
  'baseAsset': instance.baseAsset,
  'quoteAsset': instance.quoteAsset,
  'price': instance.price,
  'change24h': instance.change24h,
  'logoUrl': instance.logoUrl,
};
