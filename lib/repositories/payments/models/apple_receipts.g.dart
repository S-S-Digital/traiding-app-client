// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apple_receipts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppleReceipts _$AppleReceiptsFromJson(Map<String, dynamic> json) =>
    AppleReceipts(
      receiptData: json['receiptData'] as String,
      transactionId: json['transactionId'] as String,
    );

Map<String, dynamic> _$AppleReceiptsToJson(AppleReceipts instance) =>
    <String, dynamic>{
      'receiptData': instance.receiptData,
      'transactionId': instance.transactionId,
    };
