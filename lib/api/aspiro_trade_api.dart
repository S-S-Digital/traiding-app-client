import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/api/models/base/base_response_dto.dart';
import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:aspiro_trade/repositories/payments/payments.dart';
import 'package:aspiro_trade/repositories/tickers/tickers.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:talker/talker.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

part 'aspiro_trade_api.g.dart';



@RestApi(baseUrl: '')
abstract class AspiroTradeApi {
  factory AspiroTradeApi(Dio dio, {String baseUrl}) = _AspiroTradeApi;

  factory AspiroTradeApi.create({
    String? apiUrl,
    Talker? talker,
    required Future<(String?, String?)> Function() getTokens,
    required Future<void> Function(String access, String refresh) saveTokens,
  }) {
    final dio = Dio();
    dio.interceptors.addAll([
      TalkerDioLogger(talker: talker),
      AuthInterceptor(dio: dio, getTokens: getTokens, saveTokens: saveTokens),
    ]);
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

  @PATCH('/auth/fcm-token')
  Future<void> registerFcmToken(@Body() FirebaseToken token);

  @POST('/auth/logout')
  Future<void> logout();

  @POST('/auth/google/mobile')
  Future<AuthDto> googleSignIn(@Body() GoogleAuth googleAuth);

  @POST('/auth/apple/mobile')
  Future<AuthDto> appleSignIn(@Body() AppleAuth appleAuth);

  // =============== Tickers ===============

  @POST('/tickers')
  Future<TickersDto> addNewTicker(@Body() AddTicker ticker);

  @GET('/tickers')
  Future<List<TickersDto>> fetchAllTickers();

  @DELETE('/tickers/{id}')
  Future<DeleteTickerDto> deleteTicker(@Path() String id);

  @PATCH('/tickers/{id}')
  Future<void> updateTickerSignals(@Path() String id, AddTicker ticker);

  // =============== Assets ===============

  @GET('/assets')
  Future<List<AssetsDto>> fetchAllAssets();

  @GET('/assets/popular')
  Future<List<AssetsDto>> fetchPopularAssets();

  @GET('/assets/search')
  Future<List<AssetsDto>> searchAssets(@Query('q') String query);

  @GET('/assets/validate/{symbol}')
  Future<ValidateSymbolDto> validateSymbol(@Path('symbol') String symbol);

  @GET('/assets/{symbol}/candles')
  Future<CandlesListDto> fetchCandlesForSymbol(
    @Path('symbol') String symbol,
    @Query('limit') String limit,
    @Query('interval') String interval,
  );

  @GET('/assets/{symbol}')
  Future<AssetsDto> fetchAssetsBySymbol(@Path('symbol') String symbol);

  // =============== Payments ===============

  @GET('/payments/plans')
  Future<List<SubscriptionPlansDto>> fetchAllPlans();

  @GET('/payments/subscriptions')
  Future<List<SubscriptionsDto>> getCurrentSubscription();


  @POST('/payments/verify/apple')
  Future<void> applePayments(@Body() AppleReceipts receipts);


  @POST('/payments/verify/google')
  Future<PaymentReceiptDto> googlePayments(@Body() GoogleReceipts receipts);

  // =============== Signals ===============

  @GET('/signals')
  Future<BaseResponseDto<List<SignalsDto>>> fetchAllSignals(
    @Query('page') int page,
    @Query('limit') int limit,
    @Query('symbol') String symbol,
    @Query('timeframe') String timeframe,
    @Query('direction') String direction,
    @Query('status') String status,
  );

  @GET('/signals/ticker/{tickerId}')
  Future<BaseResponseDto<List<SignalsDto>>> fetchSignalsByTickerId(
    @Path('tickerId') String tickerId,
    @Query('page') int page,
    @Query('limit') int limit,
    @Query('symbol') String symbol,
    @Query('timeframe') String timeframe,
    @Query('direction') String direction,
    @Query('status') String status,
  );
  @GET('/signals/history')
  Future<HistoryListDto> fetchHistory(
    @Query('page') int page,
    @Query('limit') int limit,
    @Query('symbol') String symbol,
    @Query('timeframe') String timeframe,
    @Query('direction') String direction,
    @Query('status') String status,
  );

  // =============== Users ===============

  @GET('/users/me')
  Future<UsersDto> getCurrentUser();

  @GET('/users/limits')
  Future<LimitsDto> getLimits();


  @DELETE('/users/account')
  Future<void> deleteAccount();
}
