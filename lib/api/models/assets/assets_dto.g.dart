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
  volume24h: json['volume24h'] as String,
  high24h: json['high24h'] as String,
  low24h: json['low24h'] as String,
  priceChangePercent: json['priceChangePercent'] as String,
);

Map<String, dynamic> _$AssetsDtoToJson(AssetsDto instance) => <String, dynamic>{
  'symbol': instance.symbol,
  'name': instance.name,
  'baseAsset': instance.baseAsset,
  'quoteAsset': instance.quoteAsset,
  'price': instance.price,
  'change24h': instance.change24h,
  'logoUrl': instance.logoUrl,
  'volume24h': instance.volume24h,
  'high24h': instance.high24h,
  'low24h': instance.low24h,
  'priceChangePercent': instance.priceChangePercent,
};
