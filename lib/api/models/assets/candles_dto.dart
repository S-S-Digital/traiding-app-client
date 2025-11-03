import 'package:aspiro_trade/repositories/assets/assets.dart';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'candles_dto.g.dart';

@JsonSerializable()
class CandlesDto extends Equatable {
  const CandlesDto({
    required this.openTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.closeTime,
    required this.quoteAssetVolume,
    required this.numberOfTrades,
    required this.takerBuyBaseAssetVolume,
    required this.takerBuyQuoteAssetVolume,
  });

  final int openTime;
  final String open;
  final String high;
  final String low;
  final String close;
  final String volume;
  final int closeTime;
  final String quoteAssetVolume;
  final int numberOfTrades;
  final String takerBuyBaseAssetVolume;
  final String takerBuyQuoteAssetVolume;

  factory CandlesDto.fromJson(Map<String, dynamic> json) =>
      _$CandlesDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CandlesDtoToJson(this);

  Candles toEntity() => Candles(
    openTime: openTime,
    open: open,
    high: high,
    low: low,
    close: close,
    volume: volume,
    closeTime: closeTime,
    quoteAssetVolume: quoteAssetVolume,
    numberOfTrades: numberOfTrades,
    takerBuyBaseAssetVolume: takerBuyBaseAssetVolume,
    takerBuyQuoteAssetVolume: takerBuyQuoteAssetVolume,
  );

  CandlesLocal toLocal() {
    var uuid = Uuid();
    return CandlesLocal(
      uuid.v4(),
      openTime,
      open,
      high,
      low,
      close,
      volume,
      closeTime,
      quoteAssetVolume,
      numberOfTrades,
      takerBuyBaseAssetVolume,
      takerBuyQuoteAssetVolume,
    );
  }

  @override
  List<Object?> get props => [
    openTime,
    open,
    high,
    low,
    close,
    volume,
    closeTime,
    quoteAssetVolume,
    numberOfTrades,
    takerBuyBaseAssetVolume,
    takerBuyQuoteAssetVolume,
  ];
}
