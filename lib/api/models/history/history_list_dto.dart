import 'package:aspiro_trade/api/models/models.dart';
import 'package:aspiro_trade/repositories/signals/signals.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'history_list_dto.g.dart';

@JsonSerializable()
class HistoryListDto extends Equatable {
  const HistoryListDto({
    required this.data,
    required this.stats,
    required this.meta,
  });

  final List<HistoryDto> data;
  final StatsDto stats;
  final MetaDto meta;

  factory HistoryListDto.fromJson(Map<String, dynamic> json) =>
      _$HistoryListDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryListDtoToJson(this);

  HistoryList toEntity() => HistoryList(
    histories: data.map((history) => history.toEntity()).toList(),
    stats: stats.toEntity(),
  );

  @override
  List<Object?> get props => [data, stats, meta];
}
