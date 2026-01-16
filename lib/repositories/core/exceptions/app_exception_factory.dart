import 'package:aspiro_trade/repositories/core/core.dart';

final class AppExceptionFactory {
  const AppExceptionFactory._();

  static AppException fromStatusCode(int? statusCode, [String? message]) {
    // нормализуем серверное сообщение
    final msg = message?.toLowerCase().trim();

    switch (statusCode) {
      case 400:
        return BadRequestException(_mapMessage(msg) ?? 'Некорректный запрос');
      case 401:
        return UnauthorizedException(_mapMessage(msg) ?? 'Необходима авторизация');
      case 403:
        return FordibenException(_mapMessage(msg) ?? 'Недостаточно прав!');
      case 409:
        return ConflictException(_mapMessage(msg) ?? 'Конфликт данных');
      case 500:
        return InternalServerErrorException(_mapMessage(msg) ?? 'Ошибка сервера');
      default:
        return UnknownException(_mapMessage(msg) ?? 'Неизвестная ошибка');
    }
  }

  static String? _mapMessage(String? msg) {
    if (msg == null) return null;

    // перевод стандартных фраз от backend
    if (msg.contains('invalid credentials')) return 'Неверный логин или пароль';
    if (msg.contains('user not found')) return 'Пользователь не найден';
    if (msg.contains('email already exists')) return 'Email уже зарегистрирован';
    if (msg.contains('network is unreachable')) return 'Нет подключения к сети';
    if (msg.contains('token expired')) return 'Сессия истекла, войдите заново';

    return null;
  }
}
