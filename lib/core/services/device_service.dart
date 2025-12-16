import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/user_preferences.dart'; // Import your existing UserPreferences
import '../models/analytics_model.dart';

class DeviceService {
  // Replace with your actual base URL
  static const String _baseUrl = 'https://api.synquerra.com';

  Future<List<String>> getDeviceImeis() async {
    final url = Uri.parse('$_baseUrl/device/device-master-query');

    // Get the token to authenticate the request
    final token = await UserPreferences().getAccessToken();

    final Map<String, dynamic> body = {"query": "{ devices { imei } }"};

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Assuming your API needs auth
        },
        body: jsonEncode(body),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
        final List<dynamic> devices = jsonResponse['data']['devices'] ?? [];

        // Extract just the IMEIs into a List<String>
        return devices
            .map<String>((device) => device['imei'].toString())
            .toList();
      } else {
        throw Exception('Failed to load devices');
      }
    } catch (e) {
      print("Error fetching IMEIs: $e");
      return []; // Return empty list on error so app doesn't crash
    }
  }

  Future<List<AnalyticsData>> getAnalyticsByImei(String imei) async {
    final url = Uri.parse('$_baseUrl/analytics/analytics-query');
    final token = await UserPreferences().getAccessToken();

    // The GraphQL Query
    final String query =
        """
      { 
        analyticsDataByImei(imei: "$imei") { 
          id imei packet 
          latitude longitude speed battery signal alert 
          timestamp rawTemperature
        } 
      }
    """;

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"query": query}),
      );

      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
        final List<dynamic> dataList =
            jsonResponse['data']['analyticsDataByImei'] ?? [];

        // Parse the list
        return dataList.map((item) => AnalyticsData.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load analytics');
      }
    } catch (e) {
      print("Error fetching analytics: $e");
      return []; // Return empty list on error
    }
  }

  Future<List<AnalyticsDistance>> getDistance24(String imei) async {
    final token = await UserPreferences().getAccessToken();
    final url = Uri.parse('$_baseUrl/analytics/analytics-query');
    final query =
        '{ "query": "{ analyticsDistance24(imei: \\"\$imei\\") { hour distance cumulative } }" }';

    // We strictly replace the placeholder to inject the variable
    final body = query.replaceFirst('\$imei', imei);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );
      final json = jsonDecode(response.body);
      if (json['status'] == 'success') {
        final list = json['data']['analyticsDistance24'] as List;
        return list.map((e) => AnalyticsDistance.fromJson(e)).toList();
      }
    } catch (e) {
      print("Distance Error: $e");
    }
    return [];
  }

  // 2. Fetch Health
  Future<AnalyticsHealth?> getHealth(String imei) async {
    final token = await UserPreferences().getAccessToken();
    final url = Uri.parse('$_baseUrl/analytics/analytics-query');
    final body =
        '{ "query": "{ analyticsHealth(imei: \\"$imei\\") { gpsScore temperatureStatus temperatureHealthIndex } }" }';

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );
      final json = jsonDecode(response.body);
      if (json['status'] == 'success') {
        return AnalyticsHealth.fromJson(json['data']['analyticsHealth']);
      }
    } catch (e) {
      print("Health Error: $e");
    }
    return null;
  }

  // 3. Fetch Uptime
  Future<AnalyticsUptime?> getUptime(String imei) async {
    final token = await UserPreferences().getAccessToken();
    final url = Uri.parse('$_baseUrl/analytics/analytics-query');
    final body =
        '{ "query": "{ analyticsUptime(imei: \\"$imei\\") { score expectedPackets receivedPackets largestGapSec } }" }';

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );
      final json = jsonDecode(response.body);
      if (json['status'] == 'success') {
        return AnalyticsUptime.fromJson(json['data']['analyticsUptime']);
      }
    } catch (e) {
      print("Uptime Error: $e");
    }
    return null;
  }
}
