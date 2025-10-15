import 'package:aspiro_trade/api/models/auth/auth.dart';
import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_dto.g.dart';

@JsonSerializable()
class AuthDto extends Equatable {
  const AuthDto({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  
  final UserDto user;
  final String accessToken;
  final String refreshToken;

  

  factory AuthDto.fromJson(Map<String, dynamic> json) =>
      _$AuthDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AuthDtoToJson(this);

  User toEntity() => User(
    id: user.id,
    email: user.email,
    phone: user.phone,
    accessToken: accessToken,
    refreshToken: refreshToken,
  );

  UserLocal toLocal() =>
      UserLocal(user.id, user.email, user.phone, accessToken, refreshToken);

  @override
  List<Object?> get props => [user, accessToken, refreshToken];
}
