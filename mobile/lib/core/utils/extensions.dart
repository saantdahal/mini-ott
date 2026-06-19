import 'formatters.dart';

extension StringX on String {
  String get trimmed => trim();

  bool get isBlank => trimmed.isEmpty;
}

extension DateTimeX on DateTime {
  String toReadableDate() {
    return AppFormatters.date(this);
  }

  String toReadableTime() {
    return AppFormatters.time(this);
  }
}
