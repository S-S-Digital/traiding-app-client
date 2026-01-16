class Users {
  final String id;
  final String email;
  final String passwordHash;
  final String phone;
  final String fcmToken;
  final bool isActive;
  final bool isPremium;
  final DateTime? premiumUntil;
  final DateTime createdAt;
  final DateTime updatedAt;

  Users({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.phone,
    required this.fcmToken,
    required this.isActive,
    required this.isPremium,
    required this.premiumUntil,
    required this.createdAt,
    required this.updatedAt,
  });

  String get premiumUntilFormatted {
    if (premiumUntil == null) return '-';

    final d = premiumUntil!;
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year;

    return '$day.$month.$year';
  }

 String get phoneFormatted {
  // Оставляем только цифры
  final digits = phone.replaceAll(RegExp(r'\D'), '');

  // Для Казахстана: +7 XXX XXX XX XX → всего 11 цифр
  if (digits.length != 11) {
    return phone; // возвращаем как есть, чтобы не ломать UI
  }

  // digits: 7 777 777 77 77
  final country = digits.substring(0, 1);     // 7
  final block1 = digits.substring(1, 4);      // 777
  final block2 = digits.substring(4, 7);      // 777
  final block3 = digits.substring(7, 9);      // 77
  final block4 = digits.substring(9, 11);     // 77

  return '+($country$block1)-$block2-$block3-$block4';
}

  
}
