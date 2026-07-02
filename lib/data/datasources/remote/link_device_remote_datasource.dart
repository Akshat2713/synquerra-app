import 'package:flutter/foundation.dart';
import '../../../core/error/app_exceptions.dart';
import '../../network/api_constants.dart';
import '../../network/dio_client.dart';

class LinkDeviceRemoteDataSource {
  final DioClient _dioClient;
  LinkDeviceRemoteDataSource(this._dioClient);
  Future<void> linkDevice({
    required String ownerId,
    required String ownerType,
    required String deviceSerialNo,
  }) async {
    debugPrint(
      '[LinkDeviceRemoteDataSource] linkDevice() called for owner $ownerId',
    );

    final response = await _dioClient.dio.post(
      ApiConstants.linkDevice,
      data: {
        'owner_id': ownerId,
        'owner_type': ownerType,
        'device_serial_no': deviceSerialNo,
      },
    );

    final body = response.data as Map<String, dynamic>;
    debugPrint('[SignupRemoteDataSource] linkDevice status: ${body['status']}');

    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to link device.',
        statusCode: body['code'] as int?,
      );
    }
  }
}
