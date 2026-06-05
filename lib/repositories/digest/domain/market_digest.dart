enum DigestType { crypto, tradfi }
enum MarketSentiment { bullish, bearish, neutral }

class MarketDigest {
  final String id;
  final String title;
  final String content;
  final DigestType type;
  final MarketSentiment sentiment;
  final Map<String, dynamic> keyIndicators;
  final Map<String, dynamic> blocks; // Новые структурированные UI-блоки
  final DateTime generatedAt;
  final bool isLocked;

  MarketDigest({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.sentiment,
    required this.keyIndicators,
    required this.blocks,
    required this.generatedAt,
    this.isLocked = false,
  });
}
