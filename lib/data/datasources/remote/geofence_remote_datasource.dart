import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../../../domain/entities/geofence/geofence_entity.dart';
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
      ApiConstants.getGeofences,
      queryParameters: {'imei': imei},
    );

    final body = response.data as Map<String, dynamic>;

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

  Future<GeofenceModel> createGeofence({
    required String imei,
    required String name,
    required bool isActive,
    required List<Coordinate> coordinates,
  }) async {
    debugPrint('[GeofenceRemoteDataSource] createGeofence() called');
    final response = await _dioClient.dio.post(
      ApiConstants.createGeofence,
      data: {
        'imei': imei,
        'geofence_name': name,
        'is_active': isActive,
        'coordinates': coordinates
            .map((c) => {'lat': c.lat, 'lng': c.lng})
            .toList(),
      },
    );
    final body = response.data as Map<String, dynamic>;
    final rawData = body['data'];
    if (rawData == null || rawData is! Map<String, dynamic>) {
      throw ServerException(
        message: 'Failed to create geofence.',
        statusCode: response.statusCode,
      );
    }
    return GeofenceModel.fromJson(rawData);
  }

  Future<void> deleteGeofence({
    required String imei,
    required String geofenceId,
  }) async {
    debugPrint('[GeofenceRemoteDataSource] deleteGeofence() called');
    final response = await _dioClient.dio.post(
      ApiConstants.deleteGeofence,
      data: {'imei': imei, 'geofence_id': geofenceId},
    );
    final body = response.data as Map<String, dynamic>;
    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to delete geofence.',
        statusCode: response.statusCode,
      );
    }
  }
}
