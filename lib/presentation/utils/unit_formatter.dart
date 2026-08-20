// lib/presentation/utils/unit_formatter.dart

class UnitFormatter {
  UnitFormatter._();

  /// Formats speed in km/h.
  static String formatSpeed(dynamic speed, {int decimals = 1}) {
    if (speed == null) return 'N/A';
    if (speed is num) {
      return '${speed.toStringAsFixed(decimals)} km/h';
    }
    return '$speed km/h';
  }

  /// Converts a 0-23 hour index to 12-hour formatted time (e.g. 0 -> '12:00 AM', 13 -> '1:00 PM')
  static String hourLabel(int hour) {
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:00 $period';
  }

  /// Calculates filled signal bars (0 to 4) based on percentage strength.
  static int signalBarsFilled(int? s) {
    final sig = s ?? 0;
    if (sig >= 75) return 4;
    if (sig >= 50) return 3;
    if (sig >= 25) return 2;
    if (sig > 0) return 1;
    return 0;
  }
}
