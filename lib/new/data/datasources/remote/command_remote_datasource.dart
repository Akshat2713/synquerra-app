// lib/data/datasources/remote/command_remote_datasource.dart
import 'dart:convert';
import 'package:synquerra/data/models/send_command_model.dart';

import '../../network/api_client.dart';
// import '../models/send_command_model.dart';

class CommandRemoteDataSource {
  final ApiClient _apiClient;

  CommandRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  /// Send QUERY_NORMAL command to device
  Future<CommandResponseModel> queryNormal({
    required String imei,
    Map<String, dynamic>? params,
  }) async {
    final body = {
      "imei": imei,
      "command": "QUERY_NORMAL",
      "params": params ?? {},
    };

    final response = await _apiClient.post('/send', body);
    final jsonResponse = jsonDecode(response.body);

    return CommandResponseModel.fromJson(jsonResponse);
  }

  /// Update device settings
  Future<CommandResponseModel> updateDeviceSettings({
    required String imei,
    required Map<String, String> settings,
  }) async {
    final body = {
      "imei": imei,
      "command": "DEVICE_SETTINGS",
      "params": settings,
    };

    final response = await _apiClient.post('/send', body);
    final jsonResponse = jsonDecode(response.body);

    return CommandResponseModel.fromJson(jsonResponse);
  }
}
