// lib/data/datasources/local/device_config_local_datasource.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../mappers/device_config_mapper.dart';

class DeviceConfigLocalDataSource {
  final DeviceConfigMapper _mapper;

  DeviceConfigLocalDataSource({required DeviceConfigMapper mapper})
    : _mapper = mapper;

  // Keys matching your API parameters
  static const String keyNormalSending = "NormalSendingInterval";
  static const String keySOSSending = "SOSSendingInterval";
  static const String keyNormalScanning = "NormalScanningInterval";
  static const String keyAirplane = "AirplaneInterval";
  static const String keyTempLimit = "TemperatureLimit";
  static const String keySpeedLimit = "SpeedLimit";
  static const String keyLowBatLimit = "LowbatLimit";
  static const String keyLowBatData = "LowBatDataInterval";
  static const String keyLowBatGps = "LowBatGpsInterval";

  /// Save a single interval setting
  Future<void> saveInterval(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  /// Get all interval settings
  Future<Map<String, String>> getAllIntervals() async {
    final prefs = await SharedPreferences.getInstance();
    final defaults = _mapper.getDefaultIntervals();

    return {
      keyNormalSending:
          prefs.getString(keyNormalSending) ?? defaults[keyNormalSending]!,
      keySOSSending: prefs.getString(keySOSSending) ?? defaults[keySOSSending]!,
      keyNormalScanning:
          prefs.getString(keyNormalScanning) ?? defaults[keyNormalScanning]!,
      keyAirplane: prefs.getString(keyAirplane) ?? defaults[keyAirplane]!,
      keyTempLimit: prefs.getString(keyTempLimit) ?? defaults[keyTempLimit]!,
      keySpeedLimit: prefs.getString(keySpeedLimit) ?? defaults[keySpeedLimit]!,
      keyLowBatLimit:
          prefs.getString(keyLowBatLimit) ?? defaults[keyLowBatLimit]!,
      keyLowBatData: prefs.getString(keyLowBatData) ?? defaults[keyLowBatData]!,
      keyLowBatGps: prefs.getString(keyLowBatGps) ?? defaults[keyLowBatGps]!,
    };
  }

  /// Get a specific setting
  Future<String> getSetting(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final defaults = _mapper.getDefaultIntervals();
    return prefs.getString(key) ?? defaults[key]!;
  }
}
