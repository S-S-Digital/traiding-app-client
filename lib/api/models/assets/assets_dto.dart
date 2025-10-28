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
  });

  final String symbol;
  final String name;
  final String baseAsset;
  final String quoteAsset;
  final String price;
  final String change24h;
  final String logoUrl;

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
  ];
}
