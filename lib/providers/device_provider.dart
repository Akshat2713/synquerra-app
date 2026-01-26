// lib/core/providers/my_device_provider.dart
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:synquerra/core/models/analytics_model.dart';
import 'package:synquerra/core/services/device_service.dart';
import 'package:synquerra/widgets/history_dot.dart';

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
  List<Marker> _historyMarkers = [];
  List<double> _historyBearings = []; // Added this
  List<String> _historyTimestamps = [];

  List<LatLng> get historyPoints => _historyPoints;
  List<Marker> get historyMarkers => _historyMarkers;
  List<double> get historyBearings => _historyBearings;
  List<String> get historyTimestamps => _historyTimestamps;

  Future<void> refreshMyDevice(String imei) async {
    if (imei.isEmpty) return;

    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    // WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

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
        // final packet = _allPackets[i];

        // Check for non-null and non-zero coordinates (Null Island check)
        if (_allPackets.isNotEmpty) {
          _latestTelemetry = await compute(
            _findLatestValidTelemetry,
            _allPackets,
          );

          if (_latestTelemetry != null) {
            debugPrint(
              "Found valid telemetry in Background Isolate: ${_latestTelemetry!.latitude}, ${_latestTelemetry!.longitude}",
            );
          }

          if (_allPackets.isNotEmpty && _latestTelemetry != null) {
            // 1. Process data in Isolate
            final result = await compute(_processHistoryInBackground, {
              'packets': _allPackets,
              'currentPos': LatLng(
                _latestTelemetry!.latitude!,
                _latestTelemetry!.longitude!,
              ),
            });

            // 2. Map results to UI components (Markers) ONLY ONCE
            _historyPoints = result.points;
            _historyBearings = result.bearings;
            _historyTimestamps = result.timestamps;
            _historyMarkers = [];

            for (int i = 0; i < result.bearings.length; i++) {
              _historyMarkers.add(
                Marker(
                  point:
                      _historyPoints[i +
                          1], // Offset by 1 because points[0] is live
                  width: 20,
                  height: 20,
                  child: HistoryDot(rotation: result.bearings[i]),
                ),
              );
            }
          }
        } else {
          _latestTelemetry = null;
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

  // Inside DeviceProvider
  // Future<bool> sendDeviceCommand(String imei, String command) async {
  //   try {
  //     final response = await _service.queryNormal(
  //       imei: imei,
  //       params: {
  //         // Add any necessary parameters here
  //       },
  //     );
  //     return response.status == 'SENT'; // Using the model we created
  //   } catch (e) {
  //     debugPrint("Command failed: $e");
  //     return false;
  //   }
  // }
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
        p.latitude == 0.0 && p.longitude == 0.0)
      continue;

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
