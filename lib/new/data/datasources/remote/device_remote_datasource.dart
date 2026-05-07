// lib/data/datasources/remote/device_remote_datasource.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:synquerra/new/data/models/analytics_model.dart';

import '../../network/api_client.dart';
import '../graphql/device_queries.dart';
// import '../models/analytics_model.dart';
import '../../mappers/analytics_mapper.dart';

class DeviceRemoteDataSource {
  final ApiClient _apiClient;
  final AnalyticsMapper _mapper;

  DeviceRemoteDataSource({
    required ApiClient apiClient,
    required AnalyticsMapper mapper,
  }) : _apiClient = apiClient,
       _mapper = mapper;

  /// Get device IMEIs for the authenticated user
  Future<List<String>> getDeviceImeis() async {
    final body = {"query": DeviceQueries.deviceImeiQuery};

    final response = await _apiClient.post('/device/device-master-query', body);
    final jsonResponse = jsonDecode(response.body);

    if (jsonResponse['status'] == 'success') {
      final List<dynamic> devices = jsonResponse['data']['devices'] ?? [];
      return devices
          .map<String>((device) => device['imei'].toString())
          .toList();
    } else {
      throw Exception('Failed to load devices');
    }
  }

  /// Get analytics data by IMEI
  Future<List<AnalyticsDataModel>> getAnalyticsByImei(String imei) async {
    final body = {"query": DeviceQueries.getAnalytics(imei)};

    debugPrint('📤 Analytics Query: ${DeviceQueries.getAnalytics(imei)}');

    final response = await _apiClient.post('/analytics/analytics-query', body);
    final jsonResponse = jsonDecode(response.body);

    debugPrint('📥 Analytics Response: $jsonResponse');

    if (jsonResponse['status'] == 'success') {
      final List dataList = jsonResponse['data']['analyticsDataByImei'] ?? [];
      return dataList.map((item) => _mapper.fromJson(item)).toList();
    }
    return [];
  }

  /// Get 24-hour distance data
  Future<List<AnalyticsDistanceModel>> getDistance24(String imei) async {
    final body = {"query": DeviceQueries.getDistance(imei)};

    final response = await _apiClient.post('/analytics/analytics-query', body);
    final jsonResponse = jsonDecode(response.body);

    if (jsonResponse['status'] == 'success') {
      final List list =
          jsonResponse['data']['analyticsDistance24'] as List? ?? [];
      return list.map((e) => _mapper.distanceFromJson(e)).toList();
    }
    return [];
  }

  /// Get device health data
  Future<AnalyticsHealthModel?> getHealth(String imei) async {
    final body = {"query": DeviceQueries.getHealth(imei)};

    final response = await _apiClient.post('/analytics/analytics-query', body);
    final jsonResponse = jsonDecode(response.body);

    if (jsonResponse['status'] == 'success') {
      return _mapper.healthFromJson(jsonResponse['data']['analyticsHealth']);
    }
    return null;
  }

  /// Get device uptime data
  Future<AnalyticsUptimeModel?> getUptime(String imei) async {
    final body = {"query": DeviceQueries.getUptime(imei)};

    final response = await _apiClient.post('/analytics/analytics-query', body);
    final jsonResponse = jsonDecode(response.body);

    if (jsonResponse['status'] == 'success') {
      return _mapper.uptimeFromJson(jsonResponse['data']['analyticsUptime']);
    }
    return null;
  }
}
