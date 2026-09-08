import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../domain/entities/geofence/geofence_entity.dart';
import '../../network/dio_client.dart';
import '../../network/api_constants.dart';
import '../../models/geofence/geofence_model.dart';
import '../../../core/error/app_exceptions.dart';
import '../../../core/utils/app_logger.dart';

class GeofenceRemoteDataSource {
  final DioClient _dioClient;

  GeofenceRemoteDataSource(this._dioClient);

  /// Helper to log detailed network errors to the terminal
  void _logError(String methodName, dynamic error) {
    if (error is DioException) {
      AppLogger.e(
        'GeofenceRemoteDataSource',
        '[$methodName ERROR] Status Code: ${error.response?.statusCode}',
      );
      AppLogger.e(
        'GeofenceRemoteDataSource',
        '[$methodName ERROR] Response Data: ${error.response?.data}',
      );
      AppLogger.e(
        'GeofenceRemoteDataSource',
        '[$methodName ERROR] Message: ${error.message}',
      );
      debugPrint('❌ [$methodName API Error] Payload: ${error.response?.data}');
    } else {
      AppLogger.e(
        'GeofenceRemoteDataSource',
        '[$methodName UNKNOWN ERROR] $error',
      );
      debugPrint('❌ [$methodName Error] $error');
    }
  }

  Future<List<GeofenceModel>> getGeofences(String deviceId) async {
    AppLogger.d(
      'GeofenceRemoteDataSource',
      'getGeofences() called for device: $deviceId',
    );

    try {
      final response = await _dioClient.dio.get(
        ApiConstants.geofences(deviceId),
      );

      final body = response.data as Map<String, dynamic>;

      final status = body['status'];
      if (status != null && status != 'success') {
        AppLogger.w(
          'GeofenceRemoteDataSource',
          'getGeofences failed status: $body',
        );
        throw ServerException(
          message: body['message'] ?? 'Failed to fetch geofences.',
          statusCode: response.statusCode,
        );
      }

      final rawData = body['data'];
      if (rawData == null || rawData is! List) {
        AppLogger.w(
          'GeofenceRemoteDataSource',
          'getGeofences invalid data format',
        );
        throw ServerException(
          message: 'Failed to fetch geofences.',
          statusCode: response.statusCode,
        );
      }

      final geofences = await Isolate.run(
        () => (rawData)
            .map((e) => GeofenceModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      debugPrint(
        '[GeofenceRemoteDataSource] Fetched ${geofences.length} geofences',
      );
      return geofences;
    } catch (e) {
      _logError('getGeofences', e);
      rethrow;
    }
  }

  Future<GeofenceModel> createGeofence({
    required String deviceId,
    required String name,
    required bool isActive,
    required List<Coordinate> coordinates,
    required String color,
    String? locality,
    String? block,
    String? district,
    String? state,
    String? postcode,
    String? country,
    String? landmark,
    String? address,
  }) async {
    AppLogger.d(
      'GeofenceRemoteDataSource',
      'createGeofence() called for device: $deviceId',
    );

    try {
      final response = await _dioClient.dio.post(
        ApiConstants.createGeofence,
        data: {
          'device_id': deviceId,
          'geofence_name': name,
          'is_active': isActive,
          'coordinates': coordinates
              .map((c) => {'lat': c.lat, 'lng': c.lng})
              .toList(),
          'geofence_color': color,
          'locality': locality ?? '',
          'block': block ?? '',
          'district': district ?? '',
          'state': state ?? '',
          'postcode': postcode ?? '',
          'country': country ?? '',
          'landmark': landmark ?? '',
          'address': address ?? '',
        },
      );

      final body = response.data as Map<String, dynamic>;

      if (body['status'] != 'success') {
        AppLogger.w(
          'GeofenceRemoteDataSource',
          'createGeofence failed status: $body',
        );
        throw ServerException(
          message: body['message'] ?? 'Failed to create geofence.',
          statusCode: response.statusCode,
        );
      }

      final rawData = body['data'];
      if (rawData == null || rawData is! Map<String, dynamic>) {
        throw ServerException(
          message: 'Failed to create geofence.',
          statusCode: response.statusCode,
        );
      }

      return GeofenceModel.fromJson(rawData);
    } catch (e) {
      _logError('createGeofence', e);
      rethrow;
    }
  }

  Future<GeofenceModel> editGeofence({
    required String deviceId,
    required String id,
    required String name,
    required bool isActive,
    required List<Coordinate> coordinates,
    required String color,
    required String geofenceNumber,
    String? locality,
    String? block,
    String? district,
    String? state,
    String? postcode,
    String? country,
    String? landmark,
    String? address,
  }) async {
    AppLogger.d(
      'GeofenceRemoteDataSource',
      'editGeofence() called for geofence: $id',
    );

    try {
      final response = await _dioClient.dio.patch(
        ApiConstants.editGeofence(id),
        data: {
          'geofence_name': name,
          'is_active': isActive,
          'coordinates': coordinates
              .map((c) => {'lat': c.lat, 'lng': c.lng})
              .toList(),
          'geofence_number': geofenceNumber,
          'geofence_color': color,
          'locality': locality ?? '',
          'block': block ?? '',
          'district': district ?? '',
          'state': state ?? '',
          'postcode': postcode ?? '',
          'country': country ?? '',
          'landmark': landmark ?? '',
          'address': address ?? '',
        },
      );

      final body = response.data as Map<String, dynamic>;
      if (body['status'] != 'success') {
        AppLogger.w(
          'GeofenceRemoteDataSource',
          'editGeofence failed status: $body',
        );
        throw ServerException(
          message: body['message'] ?? 'Failed to update geofence.',
          statusCode: response.statusCode,
        );
      }

      final rawData = body['data'];
      if (rawData == null || rawData is! Map<String, dynamic>) {
        throw ServerException(
          message: 'Failed to update geofence.',
          statusCode: response.statusCode,
        );
      }

      return GeofenceModel.fromJson(rawData);
    } catch (e) {
      _logError('editGeofence', e);
      rethrow;
    }
  }

  Future<void> deleteGeofence({
    required String deviceId,
    required String id,
  }) async {
    AppLogger.d(
      'GeofenceRemoteDataSource',
      'deleteGeofence() called for geofence: $id',
    );

    try {
      final response = await _dioClient.dio.delete(
        ApiConstants.deleteGeofence(id),
        // queryParameters: {'device_id': deviceId},
      );

      final body = response.data as Map<String, dynamic>;

      if (body['status'] != 'success') {
        AppLogger.w(
          'GeofenceRemoteDataSource',
          'deleteGeofence failed status: $body',
        );
        throw ServerException(
          message: body['message'] ?? 'Failed to delete geofence.',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      _logError('deleteGeofence', e);
      rethrow;
    }
  }
}
