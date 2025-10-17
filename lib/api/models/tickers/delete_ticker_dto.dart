import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'delete_ticker_dto.g.dart';
@JsonSerializable()
class DeleteTickerDto extends Equatable {
  final int count;

  const DeleteTickerDto({required this.count});

  factory DeleteTickerDto.fromJson(Map<String, dynamic> json) =>
      _$DeleteTickerDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteTickerDtoToJson(this);

  @override
  List<Object?> get props => [count];
}
