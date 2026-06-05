import 'package:equatable/equatable.dart';
import 'package:aspiro_trade/repositories/digest/domain/market_digest.dart';

class MarketDigestDto extends Equatable {
  const MarketDigestDto({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.sentiment,
    required this.keyIndicators,
    required this.blocks,
    required this.generatedAt,
    required this.isLocked,
  });

  final String id;
  final String title;
  final String content;
  final String type; // 'CRYPTO' or 'TRADFI'
  final String sentiment; // 'BULLISH', 'BEARISH', 'NEUTRAL'
  final Map<String, dynamic> keyIndicators;
  final Map<String, dynamic> blocks; // Новые структурированные блоки
  final DateTime generatedAt;
  final bool isLocked;

  factory MarketDigestDto.fromJson(Map<String, dynamic> json) {
    return MarketDigestDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      type: json['type'] as String? ?? 'CRYPTO',
      sentiment: json['sentiment'] as String? ?? 'NEUTRAL',
      keyIndicators: (json['keyIndicators'] as Map<String, dynamic>?) ?? {},
      blocks: (json['blocks'] as Map<String, dynamic>?) ?? {},
      generatedAt: json['generatedAt'] != null 
          ? DateTime.parse(json['generatedAt'] as String) 
          : DateTime.now(),
      isLocked: json['isLocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'sentiment': sentiment,
      'keyIndicators': keyIndicators,
      'blocks': blocks,
      'generatedAt': generatedAt.toIso8601String(),
      'isLocked': isLocked,
    };
  }

  MarketDigest toEntity() => MarketDigest(
    id: id,
    title: title,
    content: content,
    type: type == 'CRYPTO' ? DigestType.crypto : DigestType.tradfi,
    sentiment: sentiment == 'BULLISH'
        ? MarketSentiment.bullish
        : sentiment == 'BEARISH'
            ? MarketSentiment.bearish
            : MarketSentiment.neutral,
    keyIndicators: keyIndicators,
    blocks: blocks,
    generatedAt: generatedAt,
    isLocked: isLocked,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    type,
    sentiment,
    keyIndicators,
    blocks,
    generatedAt,
    isLocked,
  ];
}
