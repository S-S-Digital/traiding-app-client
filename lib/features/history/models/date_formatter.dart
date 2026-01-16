import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');

  static String format(DateTime date) {
    return _dateTimeFormat.format(date);
  }
}
