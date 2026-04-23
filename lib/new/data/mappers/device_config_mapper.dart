// lib/data/mappers/device_config_mapper.dart
class DeviceConfigMapper {
  const DeviceConfigMapper();

  // Default values for intervals (in seconds)
  static const int defaultNormalSending = 60;
  static const int defaultSOSSending = 5;
  static const int defaultNormalScanning = 30;
  static const int defaultAirplane = 300;
  static const double defaultTemperatureLimit = 85.0;
  static const double defaultSpeedLimit = 120.0;
  static const int defaultLowBatteryLimit = 15;

  /// Convert string value to int interval (with validation)
  int stringToInterval(String value, int defaultValue) {
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 1) return defaultValue;
    return parsed;
  }

  /// Convert string value to double limit (with validation)
  double stringToLimit(String value, double defaultValue) {
    final parsed = double.tryParse(value);
    if (parsed == null || parsed < 0) return defaultValue;
    return parsed;
  }

  /// Convert interval to string for storage
  String intervalToString(int value) {
    return value.toString();
  }

  /// Convert limit to string for storage
  String limitToString(double value) {
    return value.toString();
  }

  /// Get default intervals map
  Map<String, String> getDefaultIntervals() {
    return {
      'NormalSendingInterval': intervalToString(defaultNormalSending),
      'SOSSendingInterval': intervalToString(defaultSOSSending),
      'NormalScanningInterval': intervalToString(defaultNormalScanning),
      'AirplaneInterval': intervalToString(defaultAirplane),
      'TemperatureLimit': limitToString(defaultTemperatureLimit),
      'SpeedLimit': limitToString(defaultSpeedLimit),
      'LowbatLimit': intervalToString(defaultLowBatteryLimit),
      'LowBatDataInterval': intervalToString(defaultNormalSending),
      'LowBatGpsInterval': intervalToString(defaultNormalScanning),
    };
  }
}
