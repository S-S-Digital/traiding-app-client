import 'package:aspiro_trade/repositories/tickers/tickers.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tickers_dto.g.dart';

@JsonSerializable()
class TickersDto extends Equatable {
  const TickersDto({
    required this.id,
    required this.userId,
    required this.symbol,
    required this.timeframe,
    required this.notifyBuy,
    required this.notifySell,
    required this.isActive,
    required this.addedAt,
  });

  final String id;
  final String userId;
  final String symbol;
  final String timeframe;
  final bool notifyBuy;
  final bool notifySell;
  final bool isActive;
  final DateTime addedAt;

  factory TickersDto.fromJson(Map<String, dynamic> json) =>
      _$TickersDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TickersDtoToJson(this);

  Tickers toEntity() => Tickers(
    id: id,
    userId: userId,
    symbol: symbol,
    timeframe: timeframe,
    notifyBuy: notifyBuy,
    notifySell: notifySell,
    isActive: isActive,
    addedAt: addedAt,
  );

  TickersLocal toLocal()=> TickersLocal(id, userId, symbol, timeframe, notifyBuy, notifySell, isActive, addedAt);

  @override
  List<Object?> get props => [
    id,
    userId,
    symbol,
    timeframe,
    notifyBuy,
    notifySell,
    isActive,
    addedAt,
  ];
}
