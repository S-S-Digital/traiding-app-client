
import 'package:json_annotation/json_annotation.dart';

part 'add_ticker.g.dart';

@JsonSerializable()
class AddTicker {
    AddTicker({
    required this.symbol,
    required this.timeframe,
    required this.notifyBuy,
    required this.notifySell,
  });


  final String symbol;
  final String timeframe;
  final bool notifyBuy;
  final bool notifySell;


  factory AddTicker.fromJson(Map<String, dynamic> json) => _$AddTickerFromJson(json);

  
  Map<String, dynamic> toJson() => _$AddTickerToJson(this);


}
