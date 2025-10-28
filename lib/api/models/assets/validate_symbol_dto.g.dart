// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'validate_symbol_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ValidateSymbolDto _$ValidateSymbolDtoFromJson(Map<String, dynamic> json) =>
    ValidateSymbolDto(
      symbol: json['symbol'] as String,
      isValid: json['isValid'] as bool,
    );

Map<String, dynamic> _$ValidateSymbolDtoToJson(ValidateSymbolDto instance) =>
    <String, dynamic>{'symbol': instance.symbol, 'isValid': instance.isValid};
