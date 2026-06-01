import '../../models/modes/mode_model.dart';
import '../../network/dio_client.dart';
import '../../network/api_constants.dart';
import '../../../core/error/app_exceptions.dart';

class ModeRemoteDataSource {
  final DioClient _dioClient;

  ModeRemoteDataSource(this._dioClient);

  Future<List<ModeModel>> getModes() async {
    final response = await _dioClient.dio.get(ApiConstants.getModes);
    final body = response.data as Map<String, dynamic>;
    final rawData = body['data'];

    if (rawData == null || rawData is! List) {
      throw ServerException(
        message: 'Failed to fetch modes.',
        statusCode: response.statusCode,
      );
    }

    return (rawData)
        .map((e) => ModeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> switchMode({
    required String imei,
    required String modeId,
  }) async {
    final response = await _dioClient.dio.post(
      ApiConstants.switchMode,
      data: {'imei': imei, 'mode_id': modeId},
    );

    final body = response.data as Map<String, dynamic>;

    // Treat anything other than success as failure — including timeout 400
    if (body['status'] != 'success') {
      throw ServerException(
        message:
            body['error_description'] ??
            body['message'] ??
            'Failed to switch mode.',
        statusCode: response.statusCode,
      );
    }
  }
}
