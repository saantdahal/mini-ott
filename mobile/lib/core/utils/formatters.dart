import 'package:intl/intl.dart';

class AppFormatters {
  const AppFormatters._();

  static String currency(
    num value, {
    String locale = 'en_US',
    String symbol = 'Rs ',
    int decimalDigits = 2,
  }) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );

    return formatter.format(value);
  }

  static String date(
    DateTime value, {
    String pattern = 'dd MMM yyyy',
    String locale = 'en_US',
  }) {
    return DateFormat(pattern, locale).format(value);
  }

  static String time(
    DateTime value, {
    String pattern = 'hh:mm a',
    String locale = 'en_US',
  }) {
    return DateFormat(pattern, locale).format(value);
  }
}
