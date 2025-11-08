import 'package:aspiro_trade/repositories/assets/assets.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'assets_dto.g.dart';

@JsonSerializable()
class AssetsDto extends Equatable {
  const AssetsDto({
    required this.symbol,
    required this.name,
    required this.baseAsset,
    required this.quoteAsset,
    required this.price,
    required this.change24h,
    required this.logoUrl,
    required this.volume24h,
    required this.high24h,
    required this.low24h,
    required this.priceChangePercent,
  });

  final String symbol;
  final String name;
  final String baseAsset;
  final String quoteAsset;
  final String price;
  final String change24h;
  final String logoUrl;
  final String volume24h;
  final String high24h;
  final String low24h;
  final String priceChangePercent;

  factory AssetsDto.fromJson(Map<String, dynamic> json) =>
      _$AssetsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AssetsDtoToJson(this);

  Assets toEntity() => Assets(
    symbol: symbol,
    name: name,
    baseAsset: baseAsset,
    quoteAsset: quoteAsset,
    price: price,
    change24h: change24h,
    logoUrl: logoUrl,
    volume24h: volume24h,
    high24h: high24h,
    low24h: low24h,
    priceChangePercent: priceChangePercent,
  );

  AssetsLocal toLocal() {
    var uuid = Uuid();

    return AssetsLocal(
      uuid.v4(),
      symbol,
      name,
      baseAsset,
      quoteAsset,
      price,
      change24h,
      logoUrl,
    );
  }

  @override
  List<Object?> get props => [
    symbol,
    name,
    baseAsset,
    quoteAsset,
    price,
    change24h,
    logoUrl,
    volume24h,
    high24h,
    low24h,
    priceChangePercent,
  ];
}
