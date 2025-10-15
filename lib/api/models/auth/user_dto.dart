import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto extends Equatable {
  const UserDto({
    required this.id,
    required this.email,
    required this.phone,
    this.createdAt,
  });

  
  final String id;
  final String email;
  final String phone;
  final DateTime? createdAt;

  

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  @override
  List<Object?> get props => [id, email, phone, createdAt];
}
