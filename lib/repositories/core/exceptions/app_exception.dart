sealed class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => '$runtimeType: $message';
}

class BadRequestException extends AppException {
  const BadRequestException([super.message = 'Некорректный запрос'])
      : super(statusCode: 400);
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'Нет интернет соединения']) : super(statusCode: null);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Необходима авторизация'])
      : super(statusCode: 401);
}

class FordibenException extends AppException {
  const FordibenException([super.message = 'Недостаточно прав!'])
      : super(statusCode: 403);
}

class ConflictException extends AppException {
  const ConflictException([super.message = 'Конфликт данных'])
      : super(statusCode: 409);
}

class InternalServerErrorException extends AppException {
  const InternalServerErrorException([super.message = 'Ошибка сервера'])
      : super(statusCode: 500);
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'Неизвестная ошибка'])
      : super();
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Сервер не отвечает. Попробуйте позже.'])
      : super(statusCode: null);
}