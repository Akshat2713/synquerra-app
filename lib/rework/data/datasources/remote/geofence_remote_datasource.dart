import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../../network/dio_client.dart';
import '../../network/api_constants.dart';
import '../../models/geofence/geofence_model.dart';
import '../../../core/error/app_exceptions.dart';

class GeofenceRemoteDataSource {
  final DioClient _dioClient;

  GeofenceRemoteDataSource(this._dioClient);

  Future<List<GeofenceModel>> getGeofences(String imei) async {
    debugPrint('[GeofenceRemoteDataSource] getGeofences() called');

    final response = await _dioClient.dio.get(
      ApiConstants.geofences,
      queryParameters: {'imei': imei},
    );

    final body = response.data as Map<String, dynamic>;

    // if (body['status'] != 'success') {
    //   throw ServerException(
    //     message: body['message'] ?? 'Failed to fetch geofences.',
    //     statusCode: body['code'] as int?,
    //   );

    final rawData = body['data'];
    if (rawData == null || rawData is! List) {
      throw ServerException(
        message: 'Failed to fetch geofences.',
        statusCode: response.statusCode,
      );
    }

    final rawList = body['data'] as List<dynamic>;

    // Parse list off the main thread
    final geofences = await Isolate.run(
      () => rawList
          .map((e) => GeofenceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    debugPrint(
      '[GeofenceRemoteDataSource] Fetched ${geofences.length} geofences',
    );

    return geofences;
  }
}
