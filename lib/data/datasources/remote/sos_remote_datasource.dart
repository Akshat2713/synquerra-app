import '../../network/dio_client.dart';
import '../../network/api_constants.dart';
import '../../../core/error/app_exceptions.dart';

class SosRemoteDataSource {
  final DioClient _dioClient;

  SosRemoteDataSource(this._dioClient);

  Future<void> acknowledgeSos({required String alertId}) async {
    final response = await _dioClient.dio.post(
      ApiConstants.acknowledgeSos(alertId),
    );

    final body = response.data as Map<String, dynamic>;

    if (body['status'] != 'success') {
      throw ServerException(
        message:
            body['error_description'] ??
            body['message'] ??
            'Failed to acknowledge alert.',
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> stopSos({required String deviceId}) async {
    final response = await _dioClient.dio.post(
      ApiConstants.stopSos,
      data: {'device_id': deviceId},
    );

    final body = response.data as Map<String, dynamic>;

    if (body['status'] != 'success') {
      throw ServerException(
        message:
            body['error_description'] ??
            body['message'] ??
            'Failed to stop SOS.',
        statusCode: response.statusCode,
      );
    }
  }
}
