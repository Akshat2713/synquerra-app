import 'dart:isolate';
import 'package:dio/dio.dart';
import '../../../../core/error/app_exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../../models/schedule/effective_schedule_model.dart';
import '../../models/schedule/schedule_model.dart';
import '../../models/schedule/schedule_override_model.dart';
import '../../network/api_constants.dart';
import '../../network/dio_client.dart';

class ScheduleRemoteDataSource {
  final DioClient _dioClient;

  ScheduleRemoteDataSource(this._dioClient);

  /// Helper to handle and log Dio exceptions
  Never _handleDioError(String methodName, DioException e) {
    AppLogger.e('ScheduleRemoteDataSource', '$methodName DioException caught');
    AppLogger.e(
      'ScheduleRemoteDataSource',
      'Status Code: ${e.response?.statusCode}',
    );
    AppLogger.e(
      'ScheduleRemoteDataSource',
      'Response Data: ${e.response?.data}',
    );

    if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
      final errorBody = e.response!.data as Map<String, dynamic>;
      final errorMessage =
          errorBody['error_description'] ??
          errorBody['message'] ??
          'An unexpected error occurred.';

      throw ServerException(
        message: errorMessage,
        statusCode: e.response?.statusCode,
      );
    }

    throw ServerException(
      message: e.message ?? 'Network error occurred',
      statusCode: e.response?.statusCode,
    );
  }

  /// 1. Create User Schedule
  Future<ScheduleModel> createSchedule(Map<String, dynamic> requestBody) async {
    AppLogger.d(
      'ScheduleRemoteDataSource',
      'createSchedule() called with payload: $requestBody',
    );
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.schedules,
        data: requestBody,
      );

      AppLogger.d(
        'ScheduleRemoteDataSource',
        'createSchedule() status: ${response.statusCode}',
      );
      AppLogger.d(
        'ScheduleRemoteDataSource',
        'createSchedule() response data: ${response.data}',
      );

      final body = response.data as Map<String, dynamic>;
      if (body['status'] != 'success') {
        throw ServerException(
          message: body['message'] ?? 'Failed to create schedule.',
          statusCode: body['code'] as int?,
        );
      }

      return ScheduleModel.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError('createSchedule()', e);
    }
  }

  /// 2. Get Schedules of Authenticated Caller
  Future<List<ScheduleModel>> getMySchedules({bool? isActive}) async {
    AppLogger.d(
      'ScheduleRemoteDataSource',
      'getMySchedules() called with isActive: $isActive',
    );
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.mySchedules,
        queryParameters: {if (isActive != null) 'is_active': isActive},
      );

      AppLogger.d(
        'ScheduleRemoteDataSource',
        'getMySchedules() status: ${response.statusCode}',
      );
      AppLogger.d(
        'ScheduleRemoteDataSource',
        'getMySchedules() response data: ${response.data}',
      );

      final body = response.data as Map<String, dynamic>;
      if (body['status'] != 'success') {
        throw ServerException(
          message: body['message'] ?? 'Failed to fetch schedules.',
          statusCode: body['code'] as int?,
        );
      }

      final rawList = body['data'] as List<dynamic>;
      AppLogger.d(
        'ScheduleRemoteDataSource',
        'getMySchedules() parsed items count: ${rawList.length}',
      );

      return await Isolate.run(
        () => rawList
            .map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      _handleDioError('getMySchedules()', e);
    }
  }

  /// 3. Get Schedules for Target User
  Future<List<ScheduleModel>> getTargetUserSchedules(
    String targetUserId, {
    bool? isActive,
  }) async {
    AppLogger.d(
      'ScheduleRemoteDataSource',
      'getTargetUserSchedules() for targetUserId: $targetUserId, isActive: $isActive',
    );
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.targetUserSchedules(targetUserId),
        queryParameters: {if (isActive != null) 'is_active': isActive},
      );

      AppLogger.d(
        'ScheduleRemoteDataSource',
        'getTargetUserSchedules() status: ${response.statusCode}',
      );
      AppLogger.d(
        'ScheduleRemoteDataSource',
        'getTargetUserSchedules() response data: ${response.data}',
      );

      final body = response.data as Map<String, dynamic>;
      if (body['status'] != 'success') {
        throw ServerException(
          message: body['message'] ?? 'Failed to fetch target user schedules.',
          statusCode: body['code'] as int?,
        );
      }

      final rawList = body['data'] as List<dynamic>;
      AppLogger.d(
        'ScheduleRemoteDataSource',
        'getTargetUserSchedules() parsed items count: ${rawList.length}',
      );

      return await Isolate.run(
        () => rawList
            .map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      _handleDioError('getTargetUserSchedules()', e);
    }
  }

  /// 4. Get Schedule Details by ID
  Future<ScheduleModel> getScheduleById(String scheduleId) async {
    AppLogger.d(
      'ScheduleRemoteDataSource',
      'getScheduleById() for scheduleId: $scheduleId',
    );
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.scheduleById(scheduleId),
      );

      AppLogger.d(
        'ScheduleRemoteDataSource',
        'getScheduleById() status: ${response.statusCode}',
      );
      AppLogger.d(
        'ScheduleRemoteDataSource',
        'getScheduleById() response data: ${response.data}',
      );

      final body = response.data as Map<String, dynamic>;
      if (body['status'] != 'success') {
        throw ServerException(
          message: body['message'] ?? 'Failed to fetch schedule details.',
          statusCode: body['code'] as int?,
        );
      }

      return ScheduleModel.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError('getScheduleById()', e);
    }
  }

  /// 5. Update Schedule Definition
  Future<ScheduleModel> updateSchedule(
    String scheduleId,
    Map<String, dynamic> updateBody,
  ) async {
    AppLogger.d(
      'ScheduleRemoteDataSource',
      'updateSchedule() for scheduleId: $scheduleId with body: $updateBody',
    );
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.scheduleById(scheduleId),
        data: updateBody,
      );

      AppLogger.d(
        'ScheduleRemoteDataSource',
        'updateSchedule() status: ${response.statusCode}',
      );
      AppLogger.d(
        'ScheduleRemoteDataSource',
        'updateSchedule() response data: ${response.data}',
      );

      final body = response.data as Map<String, dynamic>;
      if (body['status'] != 'success') {
        throw ServerException(
          message: body['message'] ?? 'Failed to update schedule.',
          statusCode: body['code'] as int?,
        );
      }

      return ScheduleModel.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError('updateSchedule()', e);
    }
  }

  /// 6. Toggle Schedule Active Status
  Future<void> toggleScheduleStatus(String scheduleId, bool isActive) async {
    AppLogger.d(
      'ScheduleRemoteDataSource',
      'toggleScheduleStatus() for scheduleId: $scheduleId to isActive: $isActive',
    );
    try {
      final response = await _dioClient.dio.patch(
        ApiConstants.scheduleStatus(scheduleId),
        data: {'is_active': isActive},
      );

      AppLogger.d(
        'ScheduleRemoteDataSource',
        'toggleScheduleStatus() status: ${response.statusCode}',
      );
      AppLogger.d(
        'ScheduleRemoteDataSource',
        'toggleScheduleStatus() response data: ${response.data}',
      );

      final body = response.data as Map<String, dynamic>;
      if (body['status'] != 'success') {
        throw ServerException(
          message: body['message'] ?? 'Failed to toggle schedule status.',
          statusCode: body['code'] as int?,
        );
      }
    } on DioException catch (e) {
      _handleDioError('toggleScheduleStatus()', e);
    }
  }

  /// 7. Delete Schedule Rule
  Future<void> deleteSchedule(String scheduleId) async {
    AppLogger.d(
      'ScheduleRemoteDataSource',
      'deleteSchedule() for scheduleId: $scheduleId',
    );
    try {
      final response = await _dioClient.dio.delete(
        ApiConstants.scheduleById(scheduleId),
      );

      AppLogger.d(
        'ScheduleRemoteDataSource',
        'deleteSchedule() status: ${response.statusCode}',
      );
      AppLogger.d(
        'ScheduleRemoteDataSource',
        'deleteSchedule() response data: ${response.data}',
      );

      final body = response.data as Map<String, dynamic>;
      if (body['status'] != 'success') {
        throw ServerException(
          message: body['message'] ?? 'Failed to delete schedule.',
          statusCode: body['code'] as int?,
        );
      }
    } on DioException catch (e) {
      _handleDioError('deleteSchedule()', e);
    }
  }

  /// 8. Create Schedule Override
  Future<ScheduleOverrideModel> createScheduleOverride(
    String scheduleId,
    Map<String, dynamic> overrideBody,
  ) async {
    AppLogger.d(
      'ScheduleRemoteDataSource',
      'createScheduleOverride() for scheduleId: $scheduleId with body: $overrideBody',
    );
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.scheduleOverrides(scheduleId),
        data: overrideBody,
      );

      AppLogger.d(
        'ScheduleRemoteDataSource',
        'createScheduleOverride() status: ${response.statusCode}',
      );
      AppLogger.d(
        'ScheduleRemoteDataSource',
        'createScheduleOverride() response data: ${response.data}',
      );

      final body = response.data as Map<String, dynamic>;
      if (body['status'] != 'success') {
        throw ServerException(
          message: body['message'] ?? 'Failed to create schedule override.',
          statusCode: body['code'] as int?,
        );
      }

      return ScheduleOverrideModel.fromJson(
        body['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _handleDioError('createScheduleOverride()', e);
    }
  }

  /// 9. List Schedule Overrides
  Future<List<ScheduleOverrideModel>> getScheduleOverrides(
    String scheduleId, {
    String? startDate,
    String? endDate,
  }) async {
    AppLogger.d(
      'ScheduleRemoteDataSource',
      'getScheduleOverrides() for scheduleId: $scheduleId, startDate: $startDate, endDate: $endDate',
    );
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.scheduleOverrides(scheduleId),
        queryParameters: {
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        },
      );

      AppLogger.d(
        'ScheduleRemoteDataSource',
        'getScheduleOverrides() status: ${response.statusCode}',
      );
      AppLogger.d(
        'ScheduleRemoteDataSource',
        'getScheduleOverrides() response data: ${response.data}',
      );

      final body = response.data as Map<String, dynamic>;
      if (body['status'] != 'success') {
        throw ServerException(
          message: body['message'] ?? 'Failed to list schedule overrides.',
          statusCode: body['code'] as int?,
        );
      }

      final rawList = body['data'] as List<dynamic>;
      AppLogger.d(
        'ScheduleRemoteDataSource',
        'getScheduleOverrides() parsed items count: ${rawList.length}',
      );

      return await Isolate.run(
        () => rawList
            .map(
              (e) => ScheduleOverrideModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
    } on DioException catch (e) {
      _handleDioError('getScheduleOverrides()', e);
    }
  }

  /// 10. Get Schedule Override by ID
  Future<ScheduleOverrideModel> getScheduleOverrideById(
    String scheduleId,
    String overrideId,
  ) async {
    AppLogger.d(
      'ScheduleRemoteDataSource',
      'getScheduleOverrideById() for scheduleId: $scheduleId, overrideId: $overrideId',
    );
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.scheduleOverrideById(scheduleId, overrideId),
      );

      AppLogger.d(
        'ScheduleRemoteDataSource',
        'getScheduleOverrideById() status: ${response.statusCode}',
      );
      AppLogger.d(
        'ScheduleRemoteDataSource',
        'getScheduleOverrideById() response data: ${response.data}',
      );

      final body = response.data as Map<String, dynamic>;
      if (body['status'] != 'success') {
        throw ServerException(
          message: body['message'] ?? 'Failed to fetch schedule override.',
          statusCode: body['code'] as int?,
        );
      }

      return ScheduleOverrideModel.fromJson(
        body['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _handleDioError('getScheduleOverrideById()', e);
    }
  }

  /// 11. Update Schedule Override
  Future<ScheduleOverrideModel> updateScheduleOverride(
    String scheduleId,
    String overrideId,
    Map<String, dynamic> updateBody,
  ) async {
    AppLogger.d(
      'ScheduleRemoteDataSource',
      'updateScheduleOverride() for overrideId: $overrideId with body: $updateBody',
    );
    try {
      final response = await _dioClient.dio.patch(
        ApiConstants.scheduleOverrideById(scheduleId, overrideId),
        data: updateBody,
      );

      AppLogger.d(
        'ScheduleRemoteDataSource',
        'updateScheduleOverride() status: ${response.statusCode}',
      );
      AppLogger.d(
        'ScheduleRemoteDataSource',
        'updateScheduleOverride() response data: ${response.data}',
      );

      final body = response.data as Map<String, dynamic>;
      if (body['status'] != 'success') {
        throw ServerException(
          message: body['message'] ?? 'Failed to update schedule override.',
          statusCode: body['code'] as int?,
        );
      }

      return ScheduleOverrideModel.fromJson(
        body['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _handleDioError('updateScheduleOverride()', e);
    }
  }

  /// 12. Delete Schedule Override
  Future<void> deleteScheduleOverride(
    String scheduleId,
    String overrideId,
  ) async {
    AppLogger.d(
      'ScheduleRemoteDataSource',
      'deleteScheduleOverride() for scheduleId: $scheduleId, overrideId: $overrideId',
    );
    try {
      final response = await _dioClient.dio.delete(
        ApiConstants.scheduleOverrideById(scheduleId, overrideId),
      );

      AppLogger.d(
        'ScheduleRemoteDataSource',
        'deleteScheduleOverride() status: ${response.statusCode}',
      );
      AppLogger.d(
        'ScheduleRemoteDataSource',
        'deleteScheduleOverride() response data: ${response.data}',
      );

      final body = response.data as Map<String, dynamic>;
      if (body['status'] != 'success') {
        throw ServerException(
          message: body['message'] ?? 'Failed to delete schedule override.',
          statusCode: body['code'] as int?,
        );
      }
    } on DioException catch (e) {
      _handleDioError('deleteScheduleOverride()', e);
    }
  }

  /// 13. Get Effective Schedule for Date
  Future<EffectiveScheduleModel> getEffectiveSchedule(
    String scheduleId,
    String date,
  ) async {
    AppLogger.d(
      'ScheduleRemoteDataSource',
      'getEffectiveSchedule() for scheduleId: $scheduleId on date: $date',
    );
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.effectiveSchedule(scheduleId),
        queryParameters: {'date': date},
      );

      AppLogger.d(
        'ScheduleRemoteDataSource',
        'getEffectiveSchedule() status: ${response.statusCode}',
      );
      AppLogger.d(
        'ScheduleRemoteDataSource',
        'getEffectiveSchedule() response data: ${response.data}',
      );

      final body = response.data as Map<String, dynamic>;
      if (body['status'] != 'success') {
        throw ServerException(
          message: body['message'] ?? 'Failed to calculate effective schedule.',
          statusCode: body['code'] as int?,
        );
      }

      return EffectiveScheduleModel.fromJson(
        body['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _handleDioError('getEffectiveSchedule()', e);
    }
  }
}
