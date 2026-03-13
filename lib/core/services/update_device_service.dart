import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:synquerra/core/models/send_command_model.dart';
import 'package:synquerra/core/services/base_api_service.dart';

class UpdateDeviceService {
  final BaseApiService _api;
  UpdateDeviceService(this._api);

  Future<CommandResponse> queryNormal({
    required String imei,
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _api.post('/send', {
        "imei": imei,
        "command": "QUERY_NORMAL",
        "params": params ?? {},
      });

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Optimized: Direct conversion to your new model
      return CommandResponse.fromJson(jsonResponse);
    } catch (e) {
      debugPrint("Error in sendCommand: $e");
      rethrow;
    }
  }

  Future<CommandResponse> updateDeviceSettings({
    required String imei,
    required Map<String, String> settings,
  }) async {
    try {
      final response = await _api.post('/send', {
        "imei": imei,
        "command": "DEVICE_SETTINGS",
        "params": settings,
      });

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Reuse the CommandResponse model we created earlier
      return CommandResponse.fromJson(jsonResponse);
    } catch (e) {
      debugPrint("Error updating device settings: $e");
      rethrow;
    }
  }
}
