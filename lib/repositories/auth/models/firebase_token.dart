import 'package:json_annotation/json_annotation.dart';

part 'firebase_token.g.dart';

@JsonSerializable()
class FirebaseToken {
  FirebaseToken({required this.fcmToken});
  
  final String fcmToken;

  

  factory FirebaseToken.fromJson(Map<String, dynamic> json) =>
      _$FirebaseTokenFromJson(json);

  Map<String, dynamic> toJson() => _$FirebaseTokenToJson(this);
}
