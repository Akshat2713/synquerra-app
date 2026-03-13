import 'package:shared_preferences/shared_preferences.dart';

class IntervalPreferences {
  // Keys matching your API parameters
  static const String keyNormalSending = "NormalSendingInterval";
  static const String keySOSSending = "SOSSendingInterval";
  static const String keyNormalScanning = "NormalScanningInterval";
  static const String keyAirplane = "AirplaneInterval";
  static const String keyTempLimit = "TemperatureLimit";
  static const String keySpeedLimit = "SpeedLimit";
  static const String keyLowBatLimit = "LowbatLimit";

  static const String keyLowBatData = "LowBatDataInterval"; // Added
  static const String keyLowBatGps = "LowBatGpsInterval"; // Added

  Future<void> saveInterval(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<Map<String, String>> getAllIntervals() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      keyNormalSending: prefs.getString(keyNormalSending) ?? "00",
      keySOSSending: prefs.getString(keySOSSending) ?? "00",
      keyNormalScanning: prefs.getString(keyNormalScanning) ?? "00",
      keyAirplane: prefs.getString(keyAirplane) ?? "00",
      keyTempLimit: prefs.getString(keyTempLimit) ?? "00",
      keySpeedLimit: prefs.getString(keySpeedLimit) ?? "00",
      keyLowBatLimit: prefs.getString(keyLowBatLimit) ?? "00",
      keyLowBatData: prefs.getString(keyLowBatData) ?? "00",
      keyLowBatGps: prefs.getString(keyLowBatGps) ?? "00",
    };
  }
}
