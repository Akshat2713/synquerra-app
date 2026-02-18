import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/analytics_model.dart';
import '../constants/device_queries.dart';
import '../services/base_api_service.dart';

class DeviceService {
  final BaseApiService _api;

  DeviceService(this._api);

  // --- 1. Fetch Device IMEIs ---
  Future<List<String>> getDeviceImeis() async {
    try {
      final response = await _api.post('/device/device-master-query', {
        "query": DeviceQueries.getImeis,
      });
      debugPrint("RAW SERVER RESPONSE: ${response.body}");
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
        final List devices = jsonResponse['data']['devices'] ?? [];
        return devices.map((d) => d['imei'].toString()).toList();
      }
    } catch (e) {
      debugPrint("Error fetching IMEIs: $e");
    }
    return [];
  }

  // --- 2. Fetch Analytics by IMEI ---
  Future<List<AnalyticsData>> getAnalyticsByImei(String imei) async {
    final body = {"query": DeviceQueries.getAnalytics(imei)};
    // final variables = {"imei": imei};

    // DEBUGGER: See exactly what we are sending
    debugPrint("--- [NETWORK REQUEST] Path: /analytics-query ---");
    debugPrint("--- [NETWORK REQUEST] Query: ${body["query"]} ---");
    // debugPrint("--- [NETWORK REQUEST] Variables: $variables ---");

    try {
      final response = await _api.post('/analytics/analytics-query', body);
      debugPrint("--- [NETWORK RESPONSE] Status: ${response.statusCode} ---");
      // debugPrint("--- [NETWORK RESPONSE] Body: ${response.body} ---");
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
        final List dataList = jsonResponse['data']['analyticsDataByImei'] ?? [];
        return dataList.map((item) => AnalyticsData.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching analytics: $e");
    }
    return [];
  }

  // --- 3. Fetch Distance 24h ---
  Future<List<AnalyticsDistance>> getDistance24(String imei) async {
    final body = {
      "query": DeviceQueries.getDistance(imei),
      // "variables": {"imei": imei},
    };

    try {
      final response = await _api.post('/analytics/analytics-query', body);
      final json = jsonDecode(response.body);

      if (json['status'] == 'success') {
        final list = json['data']['analyticsDistance24'] as List;
        return list.map((e) => AnalyticsDistance.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Distance Error: $e");
    }
    return [];
  }

  // --- 4. Fetch Health ---
  Future<AnalyticsHealth?> getHealth(String imei) async {
    final body = {
      "query": DeviceQueries.getHealth(imei),
      // "variables": {"imei": imei},
    };

    try {
      final response = await _api.post('/analytics/analytics-query', body);
      final json = jsonDecode(response.body);

      if (json['status'] == 'success') {
        return AnalyticsHealth.fromJson(json['data']['analyticsHealth']);
      }
    } catch (e) {
      debugPrint("Health Error: $e");
    }
    return null;
  }

  // --- 5. Fetch Uptime ---
  Future<AnalyticsUptime?> getUptime(String imei) async {
    final body = {
      "query": DeviceQueries.getUptime(imei),
      // "variables": {"imei": imei},
    };

    try {
      final response = await _api.post('/analytics/analytics-query', body);
      final json = jsonDecode(response.body);

      if (json['status'] == 'success') {
        return AnalyticsUptime.fromJson(json['data']['analyticsUptime']);
      }
    } catch (e) {
      debugPrint("Uptime Error: $e");
    }
    return null;
  }
}
