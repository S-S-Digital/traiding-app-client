import 'package:aspiro_trade/repositories/digest/domain/market_digest.dart';

abstract interface class DigestRepositoryI {
  Future<List<MarketDigest>> fetchLatestDigests();
}
