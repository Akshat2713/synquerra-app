import 'package:flutter/foundation.dart';
import '../../../core/error/app_exceptions.dart';
import '../../../core/utils/app_logger.dart';
import '../../network/api_constants.dart';
import '../../network/dio_client.dart';

class DeviceAssignmentRemoteDataSource {
  final DioClient _dioClient;

  DeviceAssignmentRemoteDataSource(this._dioClient);

  /// Assign Device (POST with body)
  Future<void> assignDevice({
    required String personId,
    required String deviceId,
    required String associationType,
  }) async {
    debugPrint(
      '[DeviceAssignmentRemoteDataSource] assignDevice() called for person $personId',
    );

    final response = await _dioClient.dio.post(
      ApiConstants.deviceAssignments,
      data: {
        'person_id': personId,
        'device_id': deviceId,
        'association_type': associationType,
      },
    );

    final body = response.data as Map<String, dynamic>;
    AppLogger.d(
      'DeviceAssignmentRemoteDataSource',
      'assignDevice status: ${body['status']}',
    );

    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to assign device.',
        statusCode: body['code'] as int?,
      );
    }
  }

  /// Unassign Device (DELETE with query parameters)
  Future<void> unassignDevice({
    required String personId,
    required String deviceId,
    required String associationType,
  }) async {
    debugPrint(
      '[DeviceAssignmentRemoteDataSource] unassignDevice() called for device $deviceId',
    );

    final response = await _dioClient.dio.delete(
      ApiConstants.deviceAssignments,
      queryParameters: {
        'person_id': personId,
        'device_id': deviceId,
        'association_type': associationType,
      },
    );

    final body = response.data as Map<String, dynamic>;
    AppLogger.d(
      'DeviceAssignmentRemoteDataSource',
      'unassignDevice status: ${body['status']}',
    );

    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to unassign device.',
        statusCode: body['code'] as int?,
      );
    }
  }
}
