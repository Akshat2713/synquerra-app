// lib/presentation/utils/telemetry_formatter.dart
class TelemetryFormatter {
  TelemetryFormatter._();

  /// Format speed with unit
  static String formatSpeed(double? speed) {
    if (speed == null) return '0 km/h';
    return '${speed.toStringAsFixed(1)} km/h';
  }

  /// Format distance with unit
  static String formatDistance(double? distance) {
    if (distance == null) return '0 km';
    return '${distance.toStringAsFixed(2)} km';
  }

  /// Format battery with unit
  static String formatBattery(int? battery) {
    if (battery == null) return '--%';
    return '$battery%';
  }

  /// Format signal with unit
  static String formatSignal(int? signal) {
    if (signal == null) return '--%';
    return '$signal%';
  }

  /// Format temperature with unit
  static String formatTemperature(int? temperature) {
    if (temperature == null) return '--°C';
    return '$temperature°C';
  }

  /// Format coordinates
  static String formatCoordinates(double? lat, double? lng) {
    if (lat == null || lng == null) return '--, --';
    return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
  }

  /// Format interval with unit
  static String formatInterval(String? interval) {
    if (interval == null) return '-- sec';
    return '$interval sec';
  }

  /// Get packet type display name
  static String getPacketTypeDisplay(String type) {
    switch (type.toUpperCase()) {
      case 'A':
        return 'Alert';
      case 'N':
        return 'Normal';
      case 'S':
        return 'SOS';
      default:
        return type;
    }
  }
}
