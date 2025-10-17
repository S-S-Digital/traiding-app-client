import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:aspiro_trade/repositories/tickers/tickers.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:talker/talker.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

part 'aspiro_trade_api.g.dart';

@RestApi(baseUrl: '')
abstract class AspiroTradeApi {
  factory AspiroTradeApi(Dio dio, {String baseUrl}) = _AspiroTradeApi;

  factory AspiroTradeApi.create({String? apiUrl, Talker? talker}) {
    final dio = Dio();
    dio.interceptors.addAll([TalkerDioLogger(talker: talker)]);
    if (apiUrl != null) {
      return AspiroTradeApi(dio, baseUrl: apiUrl);
    }
    return AspiroTradeApi(dio);
  }

  // =============== Auth ===============
  @POST('/auth/register')
  Future<AuthDto> register(@Body() Register register);

  @POST('/auth/login')
  Future<AuthDto> login(@Body() Login login);

  @POST('/auth/refresh')
  Future<RefreshDto> refresh(@Body() Refresh refresh);

  @POST('/auth/fcm-token')
  Future<String> registerFcmToken(@Body() FirebaseToken token);

  @POST('/auth/logout')
  Future<void> logout();

  // =============== Tickers ===============

  @POST('/tickers')
  Future<TickersDto> addNewTicker(@Body() AddTicker ticker);

  @GET('/tickers')
  Future<List<TickersDto>> fetchAllTickers();


  @DELETE('/tickers/{id}')
  Future<DeleteTickerDto> deleteTicker(@Path() String id);


  @PATCH('/tickers/{id}')
  Future<void> updateTickerSignals(@Path() String id);
}
