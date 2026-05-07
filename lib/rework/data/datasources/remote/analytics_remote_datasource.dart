import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../../network/dio_client.dart';
import '../../network/api_constants.dart';
import '../../models/analytics/analytics_model.dart';
import '../../../core/error/app_exceptions.dart';

class AnalyticsRemoteDataSource {
  final DioClient _dioClient;

  AnalyticsRemoteDataSource(this._dioClient);

  Future<List<AnalyticsModel>> getAnalytics({
    required String imei,
    int? skip,
    int? limit,
    String? startDate,
    String? endDate,
  }) async {
    debugPrint(
      '[AnalyticsRemoteDataSource] getAnalytics() → imei: $imei'
      '${limit != null ? ', limit: $limit' : ''}'
      '${startDate != null ? ', from: $startDate' : ''}'
      '${endDate != null ? ', to: $endDate' : ''}',
    );

    final response = await _dioClient.dio.post(
      ApiConstants.analytics,
      data: {
        'query':
            '{ analyticsDataByImei('
            'imei: "$imei"'
            ', skip: ${skip ?? 0}'
            '${limit != null ? ', limit: $limit' : ''}'
            '${startDate != null ? ', startDate: "$startDate"' : ''}'
            '${endDate != null ? ', endDate: "$endDate"' : ''}'
            ') { id topic imei packet latitude longitude speed battery signal geoid deviceTimestamp  } }',
      },
    );

    final body = response.data as Map<String, dynamic>;

    // GraphQL errors come back as 200 with an errors key
    if (body.containsKey('errors')) {
      final errorMsg = (body['errors'] as List).first['message'] as String?;
      throw ServerException(message: errorMsg ?? 'Analytics query failed.');
    }

    final data = body['data'] as Map<String, dynamic>?;
    final rawList = data?['analyticsDataByImei'] as List<dynamic>? ?? [];

    debugPrint('[AnalyticsRemoteDataSource] Raw count: ${rawList.length}');

    // Parse list off the main thread
    final analytics = await Isolate.run(
      () => rawList
          .map((e) => AnalyticsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    debugPrint('[AnalyticsRemoteDataSource] Parsed ${analytics.length} points');

    return analytics;
  }
}
