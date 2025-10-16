import 'app_exception.dart';


final class AppExceptionFactory {
  const AppExceptionFactory._();

  static AppException fromStatusCode(int? statusCode, [String? message]) {
    switch (statusCode) {
      case 400:
        return BadRequestException(message ?? 'Некорректный запрос');
      case 401:
        return UnauthorizedException(message ?? 'Необходима авторизация');
      case 409:
        return ConflictException(message ?? 'Конфликт данных');
      case 500:
        return InternalServerErrorException(message ?? 'Ошибка сервера');
      default:
        return UnknownException(message ?? 'Неизвестная ошибка');
    }
  }
}
