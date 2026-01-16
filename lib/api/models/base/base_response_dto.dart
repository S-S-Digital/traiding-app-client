import 'package:aspiro_trade/api/api.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'base_response_dto.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class BaseResponseDto<T> extends Equatable {
  final T data;
  final MetaDto meta;

  const BaseResponseDto({required this.data, required this.meta});

  factory BaseResponseDto.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$BaseResponseDtoFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$BaseResponseDtoToJson(this, toJsonT);

  @override
  List<Object?> get props => [data, meta];
}
