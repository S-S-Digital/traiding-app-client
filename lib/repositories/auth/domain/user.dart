import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.phone,
    required this.accessToken,
    required this.refreshToken,
  });

  
  final String id;
  final String email;
  final String phone;

  final String accessToken;
  final String refreshToken;

  

  @override
  List<Object?> get props => [id, email, phone, accessToken, refreshToken];
}
