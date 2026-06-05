import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/base/base.dart';
import 'package:aspiro_trade/repositories/digest/digest_repository_interface.dart';
import 'package:aspiro_trade/repositories/digest/domain/market_digest.dart';

class DigestRepository extends BaseRepository implements DigestRepositoryI {
  DigestRepository(super.talker, {required this.api});

  final AspiroTradeApi api;

  @override
  Future<List<MarketDigest>> fetchLatestDigests() => safeApiCall(() async {
    final response = await api.fetchLatestDigests();
    return response.map((dto) => dto.toEntity()).toList();
  });
}
