import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../../network/dio_client.dart';
import '../../network/api_constants.dart';
import '../../models/alerts/alert_error_model.dart';
import '../../../core/error/app_exceptions.dart';

class AlertsRemoteDataSource {
  final DioClient _dioClient;

  AlertsRemoteDataSource(this._dioClient);

  Future<List<AlertErrorModel>> getAlerts(String? imei) async {
    debugPrint('[AlertsRemoteDataSource] getAlerts() called');

    final response = await _dioClient.dio.get(ApiConstants.alerts);

    final body = response.data as Map<String, dynamic>;

    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to fetch alerts.',
        statusCode: body['code'] as int?,
      );
    }

    final rawList = body['data'] as List<dynamic>;

    // Parse list off the main thread
    final alerts = await Isolate.run(
      () => rawList
          .map((e) => AlertErrorModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    debugPrint('[AlertsRemoteDataSource] Fetched ${alerts.length} alerts');

    return alerts;
  }
}
