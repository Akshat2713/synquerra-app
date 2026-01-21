// lib/core/providers/my_device_provider.dart
import 'package:flutter/material.dart';
import 'package:synquerra/core/models/analytics_model.dart';
import 'package:synquerra/core/services/device_service.dart';

class DeviceProvider with ChangeNotifier {
  // Pass the service through the constructor
  final DeviceService _service;

  DeviceProvider(this._service);
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AnalyticsData? _latestTelemetry;
  AnalyticsHealth? _healthData;
  List<AnalyticsData> _allPackets = [];
  List<AnalyticsDistance> _distanceData = [];
  AnalyticsUptime? _uptimeData;
  bool _isLoading = false;

  AnalyticsData? get latestTelemetry => _latestTelemetry;
  AnalyticsHealth? get healthData => _healthData;
  List<AnalyticsData> get allPackets => _allPackets;
  List<AnalyticsDistance> get distanceData => _distanceData;
  AnalyticsUptime? get uptimeData => _uptimeData;
  bool get isLoading => _isLoading;

  Future<void> refreshMyDevice(String imei) async {
    if (imei.isEmpty) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getAnalyticsByImei(imei),
        _service.getDistance24(imei),
        _service.getHealth(imei),
        _service.getUptime(imei),
      ]);

      _allPackets = results[0] as List<AnalyticsData>;

      _latestTelemetry = null;

      if (_allPackets.isNotEmpty) {
        // Iterate backwards from the end of the list
        for (int i = _allPackets.length - 1; i >= 0; i--) {
          // final packet = _allPackets[i];

          // Check for non-null and non-zero coordinates (Null Island check)
          if (_allPackets[i].latitude != null &&
              _allPackets[i].longitude != null) {
            _latestTelemetry = _allPackets[i];
            debugPrint(
              "Found valid telemetry at index $i: ${_allPackets[i].latitude}, ${_allPackets[i].longitude}, ${_allPackets[i].timestamp}",
            );
            break; // Stop once we find the most recent valid location
          }
        }
      }

      // _latestTelemetry = _allPackets.isNotEmpty ? _allPackets.last : null;
      _distanceData = results[1] as List<AnalyticsDistance>;
      _healthData = results[2] as AnalyticsHealth?;
      _uptimeData = results[3] as AnalyticsUptime?;
    } catch (e) {
      debugPrint("MyDevice Fetch Error: $e");
      _errorMessage = "Network error. Please check your internet.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
