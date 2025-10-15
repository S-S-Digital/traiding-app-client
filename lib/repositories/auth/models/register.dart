import 'package:json_annotation/json_annotation.dart';

part 'register.g.dart';

@JsonSerializable()
class Register {
  Register({required this.email, required this.password, required this.phone});
  
  
  final String email;
  final String password;
  final String phone;

  

  factory Register.fromJson(Map<String, dynamic> json) =>
      _$RegisterFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterToJson(this);
}
