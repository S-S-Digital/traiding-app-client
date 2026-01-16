
import 'package:json_annotation/json_annotation.dart';


part 'google_receipts.g.dart';

@JsonSerializable()
class GoogleReceipts {
    GoogleReceipts({
    required this.purchaseToken,
    required this.productId,
    required this.packageName,
  });


  final String purchaseToken;
  final String productId;
  final String packageName;

factory GoogleReceipts.fromJson(Map<String, dynamic> json) => _$GoogleReceiptsFromJson(json);


  Map<String, dynamic> toJson() => _$GoogleReceiptsToJson(this);
}
