import 'package:aspiro_trade/repositories/users/users.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'users_dto.g.dart';

@JsonSerializable()
class UsersDto extends Equatable {
  const UsersDto({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.phone,
    required this.fcmToken,
    required this.isActive,
    required this.isPremium,
    required this.premiumUntil,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String email;
  final String passwordHash;
  final String phone;
  final String? fcmToken;
  final bool isActive;
  final bool isPremium;
  final DateTime? premiumUntil;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UsersDto.fromJson(Map<String, dynamic> json) =>
      _$UsersDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UsersDtoToJson(this);

  Users toEntity() => Users(
    id: id,
    email: email,
    passwordHash: passwordHash,
    phone: phone,
    fcmToken: fcmToken ?? '',
    isActive: isActive,
    isPremium: isPremium,
    premiumUntil: premiumUntil,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    email,
    passwordHash,
    phone,
    fcmToken,
    isActive,
    isPremium,
    premiumUntil,
    createdAt,
    updatedAt,
  ];
}
