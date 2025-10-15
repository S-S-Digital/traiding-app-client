import 'package:json_annotation/json_annotation.dart';

part 'refresh.g.dart';

@JsonSerializable()
class Refresh {
  Refresh({required this.refreshToken});
  
  final String refreshToken;

  


  factory Refresh.fromJson(Map<String, dynamic> json) => _$RefreshFromJson(json);


  Map<String, dynamic> toJson() => _$RefreshToJson(this);
}