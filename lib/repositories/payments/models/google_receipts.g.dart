// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_receipts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleReceipts _$GoogleReceiptsFromJson(Map<String, dynamic> json) =>
    GoogleReceipts(
      purchaseToken: json['purchaseToken'] as String,
      productId: json['productId'] as String,
      packageName: json['packageName'] as String,
    );

Map<String, dynamic> _$GoogleReceiptsToJson(GoogleReceipts instance) =>
    <String, dynamic>{
      'purchaseToken': instance.purchaseToken,
      'productId': instance.productId,
      'packageName': instance.packageName,
    };
