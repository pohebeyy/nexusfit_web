extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

extension DateTimeExtension on DateTime {
  String toFormattedDate() {
    return "$day.$month.$year";
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension DoubleExtension on double {
  String toStringWithDecimals({int decimals = 2}) {
    return toStringAsFixed(decimals);
  }
}
