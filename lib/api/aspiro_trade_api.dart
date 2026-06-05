import 'package:aspiro_trade/api/api.dart';
import 'package:aspiro_trade/api/models/base/base_response_dto.dart';
import 'package:aspiro_trade/repositories/auth/auth.dart';
import 'package:aspiro_trade/repositories/payments/payments.dart';
import 'package:aspiro_trade/repositories/tickers/tickers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    required Future<void> Function() onForceLogout,
  }) {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    // Order matters: Auth attaches token → Retry handles transient failures → Logger logs final result
    dio.interceptors.addAll([
      AuthInterceptor(
        dio: dio,
        getTokens: getTokens,
        saveTokens: saveTokens,
        onForceLogout: onForceLogout,
      ),
      RetryInterceptor(dio: dio, maxRetries: 3),
      TalkerDioLogger(
        talker: talker,
        settings: TalkerDioLoggerSettings(
          printRequestHeaders: false,
          printResponseHeaders: false,
          printRequestData: kDebugMode,
          printResponseData: kDebugMode,
        ),
      ),
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

  /// Cancels a subscription record on OUR backend (clears auto-renew + flips
  /// isPremium if no other active sub remains). NOTE: this does NOT stop
  /// Apple/Google auto-renewal — for store-managed (auto-renewable) purchases
  /// the user must cancel via the store. Kept for completeness / admin flows;
  /// the user-facing button deep-links to the store instead. See report.
  @DELETE('/payments/subscription/{id}')
  Future<void> cancelSubscription(@Path() String id);

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

  @GET('/signals/stats')
  Future<SignalStatsDto> fetchSignalStats({
    @Query('category') String? category,
  });

  // =============== Digest ===============

  @GET('/market-digest')
  Future<List<MarketDigestDto>> fetchLatestDigests();

  // =============== Per-asset Analytics (premium) ===============

  @GET('/asset-analytics/today')
  Future<AssetAnalyticsFeedDto> fetchTodayAnalytics();

  // =============== Users ===============

  @GET('/users/me')
  Future<UsersDto> getCurrentUser();

  @GET('/users/limits')
  Future<LimitsDto> getLimits();

  // Account-level strategy mode (quality | turnover)
  @GET('/users/strategy-mode')
  Future<StrategyModeDto> getStrategyMode();

  @PUT('/users/strategy-mode')
  Future<StrategyModeDto> setStrategyMode(@Body() UpdateStrategyMode body);


  @DELETE('/users/account')
  Future<void> deleteAccount();
}
