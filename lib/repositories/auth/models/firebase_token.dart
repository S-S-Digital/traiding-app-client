import 'package:json_annotation/json_annotation.dart';

part 'firebase_token.g.dart';

@JsonSerializable()
class FirebaseToken {
  FirebaseToken({required this.fcmToken, required this.platform});

  final String fcmToken;
  final String platform;

  factory FirebaseToken.fromJson(Map<String, dynamic> json) =>
      _$FirebaseTokenFromJson(json);

  Map<String, dynamic> toJson() => _$FirebaseTokenToJson(this);
}
