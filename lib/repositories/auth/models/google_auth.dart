import 'package:json_annotation/json_annotation.dart';

part 'google_auth.g.dart';

@JsonSerializable()
class GoogleAuth {
    GoogleAuth({
    required this.provider,
    required this.providerId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.picture,
    required this.accessToken,
  });
  
  final String provider;
  final String providerId;
  final String email;
  final String firstName;
  final String lastName;
  final String picture;
  final String accessToken;



  factory GoogleAuth.fromJson(Map<String, dynamic> json) =>
      _$GoogleAuthFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleAuthToJson(this);
}
