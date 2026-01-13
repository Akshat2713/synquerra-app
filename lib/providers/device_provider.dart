// lib/core/providers/my_device_provider.dart
import 'package:flutter/material.dart';
import 'package:synquerra/core/models/analytics_model.dart';
import 'package:synquerra/core/services/device_service.dart';

class DeviceProvider with ChangeNotifier {
  final DeviceService _service = DeviceService();

  AnalyticsData? _latestTelemetry;
  AnalyticsHealth? _healthData;
  List<AnalyticsData> _allPackets = []; // Added
  List<AnalyticsDistance> _distanceData = []; // Added
  AnalyticsUptime? _uptimeData; // Added
  bool _isLoading = false;

  AnalyticsData? get latestTelemetry => _latestTelemetry;
  AnalyticsHealth? get healthData => _healthData;
  List<AnalyticsData> get allPackets => _allPackets;
  List<AnalyticsDistance> get distanceData => _distanceData;
  AnalyticsUptime? get uptimeData => _uptimeData;
  bool get isLoading => _isLoading;

  // This is only called for the IMEI retrieved during login
  Future<void> refreshMyDevice(String imei) async {
    if (imei.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getAnalyticsByImei(imei),
        _service.getDistance24(imei),
        _service.getHealth(imei),
        _service.getUptime(imei),
      ]);

      _allPackets = results[0] as List<AnalyticsData>;
      _latestTelemetry = _allPackets.isNotEmpty ? _allPackets.last : null;
      _distanceData = results[1] as List<AnalyticsDistance>;
      _healthData = results[2] as AnalyticsHealth;
      _uptimeData = results[3] as AnalyticsUptime;
    } catch (e) {
      debugPrint("MyDevice Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
