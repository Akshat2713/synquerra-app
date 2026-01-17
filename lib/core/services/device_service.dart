import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:synquerra/core/services/base_api_service.dart';
import '../models/analytics_model.dart';

class DeviceService {
  final BaseApiService _api;

  DeviceService(this._api);

  // --- 1. Fetch Device IMEIs ---
  Future<List<String>> getDeviceImeis() async {
    final Map<String, dynamic> body = {"query": "{ devices { imei } }"};

    try {
      // Structure kept identical, using _api.post to handle URL/Headers
      final response = await _api.post('/device/device-master-query', body);

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
        final List<dynamic> devices = jsonResponse['data']['devices'] ?? [];
        return devices
            .map<String>((device) => device['imei'].toString())
            .toList();
      } else {
        throw Exception('Failed to load devices');
      }
    } catch (e) {
      // Debug line preserved as requested
      print("Error fetching IMEIs: $e");
      return [];
    }
  }

  // --- 2. Fetch Analytics by IMEI ---
  Future<List<AnalyticsData>> getAnalyticsByImei(String imei) async {
    final String query =
        """
      { 
        analyticsDataByImei(imei: "$imei") { 
          id imei packet interval geoid
          latitude longitude speed battery signal alert 
          timestamp rawTemperature
        } 
      }
    """;

    try {
      final response = await _api.post('/analytics/analytics-query', {
        "query": query,
      });
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
        final List<dynamic> dataList =
            jsonResponse['data']['analyticsDataByImei'] ?? [];
        return dataList.map((item) => AnalyticsData.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load analytics');
      }
    } catch (e) {
      // Debug line preserved
      print("Error fetching analytics: $e");
      return [];
    }
  }

  // --- 3. Fetch Distance 24h ---
  Future<List<AnalyticsDistance>> getDistance24(String imei) async {
    final String queryTemplate =
        '{ "query": "{ analyticsDistance24(imei: \\"\$imei\\") { hour distance cumulative } }" }';

    final String bodyString = queryTemplate.replaceFirst('\$imei', imei);
    // Convert string query to Map for the base service
    final Map<String, dynamic> body = jsonDecode(bodyString);

    try {
      final response = await _api.post('/analytics/analytics-query', body);
      final json = jsonDecode(response.body);

      if (json['status'] == 'success') {
        final list = json['data']['analyticsDistance24'] as List;
        return list.map((e) => AnalyticsDistance.fromJson(e)).toList();
      }
    } catch (e) {
      // Debug line preserved
      print("Distance Error: $e");
    }
    return [];
  }

  // --- 4. Fetch Health ---
  Future<AnalyticsHealth?> getHealth(String imei) async {
    final Map<String, dynamic> body = {
      "query":
          "{ analyticsHealth(imei: \"$imei\") { gpsScore temperatureStatus temperatureHealthIndex } }",
    };

    try {
      final response = await _api.post('/analytics/analytics-query', body);
      final json = jsonDecode(response.body);

      if (json['status'] == 'success') {
        return AnalyticsHealth.fromJson(json['data']['analyticsHealth']);
      }
    } catch (e) {
      // Debug line preserved
      print("Health Error: $e");
    }
    return null;
  }

  // --- 5. Fetch Uptime ---
  Future<AnalyticsUptime?> getUptime(String imei) async {
    final Map<String, dynamic> body = {
      "query":
          "{ analyticsUptime(imei: \"$imei\") { score expectedPackets receivedPackets largestGapSec } }",
    };

    try {
      final response = await _api.post('/analytics/analytics-query', body);
      final json = jsonDecode(response.body);

      if (json['status'] == 'success') {
        return AnalyticsUptime.fromJson(json['data']['analyticsUptime']);
      }
    } catch (e) {
      // Debug line preserved
      print("Uptime Error: $e");
    }
    return null;
  }
}
