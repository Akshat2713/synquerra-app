// lib/core/providers/searched_device_provider.dart
import 'package:flutter/material.dart';
import 'package:synquerra/old/core/models/analytics_model.dart';
import 'package:synquerra/old/core/services/device_service.dart';

class SearchedDeviceProvider with ChangeNotifier {
  // Pass the service through the constructor
  final DeviceService _service;

  SearchedDeviceProvider(this._service);

  AnalyticsData? _latestTelemetry;
  List<AnalyticsData> _allPackets = [];
  List<AnalyticsDistance> _distanceData = [];
  AnalyticsHealth? _healthData;
  AnalyticsUptime? _uptimeData;
  bool _isLoading = false;
  String? _currentImei;

  AnalyticsData? get latestTelemetry => _latestTelemetry;
  List<AnalyticsData> get allPackets => _allPackets;
  List<AnalyticsDistance> get distanceData => _distanceData;
  AnalyticsHealth? get healthData => _healthData;
  AnalyticsUptime? get uptimeData => _uptimeData;
  bool get isLoading => _isLoading;
  String? get currentImei => _currentImei;

  Future<void> fetchSearchedDevice(String imei) async {
    _currentImei = imei;
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
      _healthData = results[2] as AnalyticsHealth?;
      _uptimeData = results[3] as AnalyticsUptime?;
    } catch (e) {
      debugPrint("SearchedDevice Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _latestTelemetry = null;
    _allPackets = [];
    _distanceData = [];
    _healthData = null;
    _uptimeData = null;
    _currentImei = null;
    notifyListeners();
  }
}
