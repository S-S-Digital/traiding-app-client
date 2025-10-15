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
    dio.interceptors.addAll([
      TalkerDioLogger(talker: talker),
      
    ]);
    if (apiUrl != null) {
      return AspiroTradeApi(dio, baseUrl: apiUrl);
    }
    return AspiroTradeApi(dio);
  }

  
}