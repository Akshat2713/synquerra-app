// lib/data/mappers/type_converter.dart
class TypeConverter {
  TypeConverter._(); // Prevent instantiation

  /// Parse double from dynamic value (String, int, double, null)
  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Parse int from dynamic value
  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Parse DateTime from string or return null
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value).toLocal();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Clean temperature value (remove 'C' suffix)
  static String? cleanTemperature(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    return str.split(RegExp(r'[cC]')).first.trim();
  }

  /// Convert battery string to int (with validation)
  static int? parseBattery(dynamic value) {
    final parsed = parseInt(value);
    if (parsed == null) return null;
    // Clamp between 0 and 100
    return parsed.clamp(0, 100);
  }

  /// Convert signal string to int (with validation)
  static int? parseSignal(dynamic value) {
    final parsed = parseInt(value);
    if (parsed == null) return null;
    // Clamp between 0 and 100
    return parsed.clamp(0, 100);
  }
}
