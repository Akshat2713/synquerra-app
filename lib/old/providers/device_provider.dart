// lib/core/providers/my_device_provider.dart
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:synquerra/old/core/models/analytics_model.dart';
import 'package:synquerra/old/core/services/device_service.dart';
// import 'package:synquerra/widgets/history_dot.dart';

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

  List<LatLng> _historyPoints = [];
  // List<Marker> _historyMarkers = [];
  List<double> _historyBearings = []; // Added this
  List<String> _historyTimestamps = [];

  List<LatLng> get historyPoints => _historyPoints;
  // List<Marker> get historyMarkers => _historyMarkers;
  List<double> get historyBearings => _historyBearings;
  List<String> get historyTimestamps => _historyTimestamps;

  DateTime? _lastDataTimestamp;
  int _lastPacketCount = 0;
  DateTime? get lastDataTimestamp => _lastDataTimestamp;
  int get lastPacketCount => _lastPacketCount;

  Future<void> refreshMyDevice(String imei, {bool forceRefresh = false}) async {
    if (imei.isEmpty || _isLoading) return;
    if (_latestTelemetry != null && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // STEP 1: CRITICAL PATH (The Map)
      // Fetch only Analytics first so we can show the location ASAP
      _allPackets = await _service.getAnalyticsByImei(imei);
      _lastPacketCount = _allPackets.length;

      if (_allPackets.isNotEmpty) {
        // Find the latest valid point in a background isolate (Your existing function)
        _latestTelemetry = await compute(
          _findLatestValidTelemetry,
          _allPackets,
        );

        if (_latestTelemetry != null && _latestTelemetry!.timestamp != null) {
          _lastDataTimestamp = DateTime.parse(_latestTelemetry!.timestamp!);
        }

        // --- PERFORMANCE WIN: STOP LOADING HERE ---
        // The Map will now show the boy icon and center itself immediately.
        _isLoading = false;
        notifyListeners();

        // STEP 2: SECONDARY PATH (The Details & History)
        // We run these without 'awaiting' the first one, so they don't block the UI
        _fetchSecondaryData(imei);
        _processHistoryData(_allPackets, _latestTelemetry!);
      }
    } catch (e) {
      _errorMessage = "Tracking sync failed.";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchSecondaryData(String imei) async {
    try {
      final results = await Future.wait([
        _service.getDistance24(imei),
        _service.getHealth(imei),
        _service.getUptime(imei),
      ]);
      _distanceData = results[0] as List<AnalyticsDistance>;
      _healthData = results[1] as AnalyticsHealth?;
      _uptimeData = results[2] as AnalyticsUptime?;
      notifyListeners(); // Updates the Bottom Sheet once data arrives
    } catch (e) {
      debugPrint("Secondary data fetch failed: $e");
    }
  }

  Future<void> _processHistoryData(
    List<AnalyticsData> packets,
    AnalyticsData latest,
  ) async {
    try {
      final result = await compute(_processHistoryInBackground, {
        'packets': packets,
        'currentPos': LatLng(latest.latitude!, latest.longitude!),
      });
      _historyPoints = result.points;
      _historyBearings = result.bearings;
      _historyTimestamps = result.timestamps;
      notifyListeners(); // Draws the blue history lines once processed
    } catch (e) {
      debugPrint("History processing failed: $e");
    }
  }

  bool hasNewData(List<AnalyticsData> newPackets) {
    if (newPackets.isEmpty) return false;
    if (_allPackets.isEmpty) return true;

    try {
      // Compare by timestamp if available
      final newestNew = DateTime.parse(newPackets.last.timestamp!);
      final newestOld = DateTime.parse(_allPackets.last.timestamp!);
      return newestNew.isAfter(newestOld);
    } catch (e) {
      // Fallback to packet count comparison
      return newPackets.length > _allPackets.length;
    }
  }
}

AnalyticsData? _findLatestValidTelemetry(List<AnalyticsData> packets) {
  if (packets.isEmpty) return null;

  // Perform the heavy loop in the background
  for (int i = packets.length - 1; i >= 0; i--) {
    final p = packets[i];
    if (p.latitude != null &&
        p.longitude != null &&
        !(p.latitude == 0.0 && p.longitude == 0.0)) {
      return p;
    }
  }
  return null;
}

/// Data structure to pass back from the Isolate
class HistoryResult {
  final List<LatLng> points;
  final List<double> bearings;
  final List<String> timestamps;
  HistoryResult(this.points, this.bearings, this.timestamps);
}

/// The heavy lifter: Runs in a separate Isolate
HistoryResult _processHistoryInBackground(Map<String, dynamic> params) {
  final List<dynamic> packets = params['packets'];
  final LatLng? currentPos = params['currentPos'];

  if (packets.isEmpty || currentPos == null) {
    return HistoryResult([], [], []);
  }

  final now = DateTime.now();
  final cutoff = now.subtract(const Duration(hours: 24));

  List<LatLng> points = [currentPos];
  List<double> bearings = [];
  List<String> timestamps = [];
  LatLng nextPoint = currentPos;

  // Iterate backwards to get recent history
  // Logic: i -= 5 (as in your original code)
  for (int i = packets.length - 5; i >= 0; i -= 5) {
    final p = packets[i];
    if (p.latitude == null ||
        p.longitude == null ||
        p.timestamp == null ||
        p.latitude == 0.0 && p.longitude == 0.0) {
      continue;
    }

    final packetTime = DateTime.parse(p.timestamp!).toLocal();
    if (packetTime.isBefore(cutoff)) break;

    final pos = LatLng(p.latitude!, p.longitude!);

    points.add(pos);

    // Calculate Bearing here
    double lat1 = pos.latitude * math.pi / 180;
    double lon1 = pos.longitude * math.pi / 180;
    double lat2 = nextPoint.latitude * math.pi / 180;
    double lon2 = nextPoint.longitude * math.pi / 180;

    double dLon = lon2 - lon1;
    double y = math.sin(dLon) * math.cos(lat2);
    double x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    bearings.add(math.atan2(y, x));
    timestamps.add(p.timestamp!);
    nextPoint = pos;
  }

  return HistoryResult(points, bearings, timestamps);
}
