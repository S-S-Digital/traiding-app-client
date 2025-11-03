import 'package:aspiro_trade/api/models/assets/assets.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';


part 'candles_list_dto.g.dart';


@JsonSerializable()
class CandlesListDto extends Equatable {
    const CandlesListDto({
    required this.symbol,
    required this.interval,
    required this.limit,
    required this.candles,
  });


  final String symbol;
  final String interval;
  final int limit;
  final List<CandlesDto> candles;


  factory CandlesListDto.fromJson(Map<String, dynamic> json) => _$CandlesListDtoFromJson(json);


  Map<String, dynamic> toJson() => _$CandlesListDtoToJson(this);
  @override
  List<Object?> get props => [symbol, interval, limit, candles];
}
