import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:synquerra/data/models/settings/send_query_command_model.dart';
import '../../../core/error/app_exceptions.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/settings/settings_model.dart';
import '../../network/api_constants.dart';
import '../../network/dio_client.dart';

class SettingsRemoteDataSource {
  final DioClient _dioClient;

  SettingsRemoteDataSource(this._dioClient);

  /// Fetches device settings by device ID
  Future<SettingsModel> getSettings({required String deviceId}) async {
    AppLogger.d(
      'SettingsRemoteDataSource',
      'getSettings() called for deviceId: $deviceId',
    );

    final response = await _dioClient.dio.get(
      ApiConstants.getSettings,
      queryParameters: {'device_id': deviceId},
    );

    final body = response.data as Map<String, dynamic>;

    // Validate response status
    final status = body['status'];
    if (status != null && status != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to fetch device settings.',
        statusCode: response.statusCode,
      );
    }

    final rawData = body['data'];
    if (rawData == null || rawData is! Map<String, dynamic>) {
      throw ServerException(
        message: 'Invalid settings response data.',
        statusCode: response.statusCode,
      );
    }

    // Parse model off the main thread for optimal UI smoothness
    final settings = await Isolate.run(() => SettingsModel.fromJson(rawData));

    debugPrint(
      '[SettingsRemoteDataSource] Successfully fetched settings for $deviceId',
    );
    return settings;
  }

  /// Updates phone numbers for the device via update-core
  Future<SettingsModel> updatePhoneNumbers({
    required String deviceId,
    String? phoneNum1,
    String? phoneNum2,
  }) async {
    AppLogger.d(
      'SettingsRemoteDataSource',
      'updatePhoneNumbers() called for deviceId: $deviceId',
    );

    final response = await _dioClient.dio.post(
      ApiConstants.updatephone,
      data: {
        'device_id': deviceId,
        if (phoneNum1 != null) 'phonenum1': phoneNum1,
        if (phoneNum2 != null) 'phonenum2': phoneNum2,
      },
    );

    final body = response.data as Map<String, dynamic>;

    // Validate response status
    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to update phone numbers.',
        statusCode: response.statusCode,
      );
    }

    final rawData = body['data'];
    if (rawData == null || rawData is! Map<String, dynamic>) {
      throw ServerException(
        message: 'Invalid response received after updating phone numbers.',
        statusCode: response.statusCode,
      );
    }

    return SettingsModel.fromJson(rawData);
  }

  /// Sends a query command to the device to retrieve telemetry data
  Future<SendQueryCommandModel> sendQueryCommand({
    required String deviceId,
  }) async {
    AppLogger.d(
      'SettingsRemoteDataSource',
      'sendQueryCommand() called for deviceId: $deviceId',
    );

    final response = await _dioClient.dio.post(
      ApiConstants
          .sendQueryCommand, // Ensure this endpoint path is defined in ApiConstants
      data: {'device_id': deviceId},
    );

    final body = response.data as Map<String, dynamic>;

    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to send query command.',
        statusCode: response.statusCode,
      );
    }

    final rawData = body['data'];
    if (rawData == null || rawData is! Map<String, dynamic>) {
      throw ServerException(
        message: 'Invalid response received after sending query command.',
        statusCode: response.statusCode,
      );
    }

    return SendQueryCommandModel.fromJson(rawData);
  }
}
