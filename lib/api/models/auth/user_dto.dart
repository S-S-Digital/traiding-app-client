import 'package:aspiro_trade/repositories/auth/auth.dart';
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
  final String? phone;
  final DateTime? createdAt;

  

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);


    User toEntity() => User(
    id: id,
    email: email,
    phone: phone ?? ''
  );

  UserLocal toLocal() =>
      UserLocal(id, email, phone ?? '');

  @override
  List<Object?> get props => [id, email, phone, createdAt];
}
