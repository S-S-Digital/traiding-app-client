import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'refresh_dto.g.dart';

@JsonSerializable()
class RefreshDto extends Equatable{
    const RefreshDto({required this.accessToken, required this.refreshToken});
  final String accessToken;
  final String refreshToken;


  factory RefreshDto.fromJson(Map<String, dynamic> json) => _$RefreshDtoFromJson(json);

  
  Map<String, dynamic> toJson() => _$RefreshDtoToJson(this);
  @override
  List<Object?> get props => [];
}