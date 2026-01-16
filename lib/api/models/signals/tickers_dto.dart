import 'package:aspiro_trade/repositories/signals/signals.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tickers_dto.g.dart';

@JsonSerializable()
class TickersDto extends Equatable {
  final String? symbol;
  final String? timeframe;

  const TickersDto({required this.symbol, required this.timeframe});

  factory TickersDto.fromJson(Map<String, dynamic> json) =>
      _$TickersDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TickersDtoToJson(this);

  Tickers toEntity()=>Tickers(symbol: symbol ??'', timeframe: timeframe?? '');
  
  factory TickersDto.empty() => const TickersDto(symbol: '', timeframe: '');

  @override
  List<Object?> get props => [symbol, timeframe];
}
