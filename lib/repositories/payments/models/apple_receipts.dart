
import 'package:json_annotation/json_annotation.dart';

part 'apple_receipts.g.dart';

@JsonSerializable()
class AppleReceipts {
  AppleReceipts({required this.receiptData, required this.transactionId});
  final String receiptData;
  final String transactionId;

  factory AppleReceipts.fromJson(Map<String, dynamic> json) => _$AppleReceiptsFromJson(json);


  Map<String, dynamic> toJson() => _$AppleReceiptsToJson(this);
}