import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'validate_symbol_dto.g.dart';

@JsonSerializable()
class ValidateSymbolDto extends Equatable {
  final String symbol;
  final bool isValid;

  const ValidateSymbolDto({required this.symbol, required this.isValid});

  factory ValidateSymbolDto.fromJson(Map<String, dynamic> json) =>
      _$ValidateSymbolDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ValidateSymbolDtoToJson(this);

  @override
  List<Object?> get props => [symbol, isValid];
}
