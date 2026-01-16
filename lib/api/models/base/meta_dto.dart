import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meta_dto.g.dart';

@JsonSerializable()
class MetaDto extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const MetaDto({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });
  factory MetaDto.fromJson(Map<String, dynamic> json) =>
      _$MetaDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MetaDtoToJson(this);

  @override
  List<Object?> get props => [total, page, limit, totalPages];
}
