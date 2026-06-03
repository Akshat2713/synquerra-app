import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../../network/dio_client.dart';
import '../../network/api_constants.dart';
import '../../models/alerts/alert_error_model.dart';
import '../../../core/error/app_exceptions.dart';

class AlertErrorsRemoteDataSource {
  final DioClient _dioClient;

  AlertErrorsRemoteDataSource(this._dioClient);

  Future<List<AlertErrorModel>> getAlertsErrors(String imei) async {
    debugPrint('[AlertErrorsRemoteDataSource] getAlertsErrors() called');

    final response = await _dioClient.dio.get(
      ApiConstants.alertErrors,
      queryParameters: {'imei': imei},
    );

    final body = response.data as Map<String, dynamic>;

    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to fetch alerts and errors.',
        statusCode: body['code'] as int?,
      );
    }

    final rawList = body['data'] as List<dynamic>;

    // Parse list off the main thread
    final alertsErrors = await Isolate.run(
      () => rawList
          .map((e) => AlertErrorModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    debugPrint(
      '[AlertErrorsRemoteDataSource] Fetched ${alertsErrors.length} alerts and errors',
    );

    return alertsErrors;
  }
}
