import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/analytics/analytics_query_model.dart';
import '../../network/dio_client.dart';
import '../../network/api_constants.dart';
import '../../models/analytics/analytics_model.dart';
import '../../../core/error/app_exceptions.dart';
import '../graphql/analytics_queries.dart';

class AnalyticsRemoteDataSource {
  final DioClient _dioClient;

  AnalyticsRemoteDataSource(this._dioClient);

  Future<List<AnalyticsModel>> getAnalytics({
    required String deviceId,
    int? skip,
    int? limit,
    int? dataInterval,
    String? startDate,
    String? endDate,
  }) async {
    debugPrint(
      '[AnalyticsRemoteDataSource] getAnalytics() → deviceId: $deviceId'
      '${limit != null ? ', limit: $limit' : ''}'
      '${dataInterval != null ? ', dataInterval: $dataInterval' : ''}'
      '${startDate != null ? ', from: $startDate' : ''}'
      '${endDate != null ? ', to: $endDate' : ''}',
    );
    final response = await _dioClient.dio.post(
      ApiConstants.analyticsQuery,
      data: {
        'query': AnalyticsQueries.analyticsByDeviceId(
          deviceId: deviceId,
          skip: skip ?? 0,
          limit: limit,
          dataInterval: dataInterval,
          startDate: startDate,
          endDate: endDate,
        ),
      },
    );

    final body = response.data as Map<String, dynamic>;

    // GraphQL errors come back as 200 with an errors key
    if (body.containsKey('errors')) {
      final errorMsg = (body['errors'] as List).first['message'] as String?;
      throw ServerException(message: errorMsg ?? 'Analytics query failed.');
    }

    final data = body['data'] as Map<String, dynamic>?;
    final rawList = data?['analyticsDataByDeviceId'] as List<dynamic>? ?? [];
    AppLogger.d('AnalyticsRemoteDataSource', 'Raw count: ${rawList.length}');

    // Parse list off the main thread
    final analytics = await Isolate.run(
      () => rawList
          .map((e) => AnalyticsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    AppLogger.d(
      'AnalyticsRemoteDataSource',
      'Parsed ${analytics.length} points',
    );

    return analytics;
  }

  /// Queries the device's latest NormalPacket (live telemetry).
  Future<AnalyticsQueryModel> getLiveTelemetry({
    required String deviceId,
  }) async {
    debugPrint(
      '[AnalyticsRemoteDataSource] sendQueryCommand() → deviceId: $deviceId',
    );

    final response = await _dioClient.dio.post(
      ApiConstants.sendQueryCommand, // your constant
      data: {'device_id': deviceId},
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw ServerException(message: 'Unexpected response format.');
    }

    // The API can return HTTP 200 with a non-success status in the body
    final status = body['status']?.toString().toLowerCase();
    final innerStatus = (body['data'] as Map<String, dynamic>?)?['status']
        ?.toString()
        .toLowerCase();

    if (status != 'success' || innerStatus != 'success') {
      throw ServerException(
        message:
            body['message']?.toString() ?? 'Failed to fetch live telemetry.',
      );
    }

    final packet = (body['data'] as Map<String, dynamic>?)?['packet'];
    if (packet is! Map<String, dynamic>) {
      throw ServerException(
        message: 'No telemetry packet received from device.',
      );
    }

    final model = AnalyticsQueryModel.fromApiResponse(body);
    AppLogger.d(
      'AnalyticsRemoteDataSource',
      'Live telemetry: ${model.latitude}, ${model.longitude} @ ${model.deviceTimestamp}',
    );
    return model;
  }
}
