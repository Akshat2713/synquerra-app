import 'package:synquerra/data/datasources/graphql/geofence_mode_query.dart';
import 'package:synquerra/data/datasources/graphql/mode_conditions_query.dart';

import '../../../core/error/app_exceptions.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/geofence_mode/geofence_mode_model.dart';
import '../../models/geofence_mode/mode_condition_model.dart';
import '../../network/api_constants.dart';
import '../../network/dio_client.dart';

class ModeConditionsRemoteDataSource {
  final DioClient _dioClient;

  ModeConditionsRemoteDataSource(this._dioClient);

  // ───────────────────────── Geofence Modes ─────────────────────────

  /// Fetch geofence modes using GraphQL.
  Future<List<GeofenceModeModel>> getModes({
    String category = 'geofence',
    bool isActive = true,
  }) async {
    const tag = 'ModeConditionsRemoteDataSource';

    AppLogger.d(tag, 'getModes() called for category: $category');

    final response = await _dioClient.dio.post(
      ApiConstants.geofenceMode,
      data: {
        'query': GeofenceModeQuery.modes,
        'variables': {'category': category, 'isActive': isActive},
      },
    );

    final body = response.data as Map<String, dynamic>;

    // GraphQL can return errors inside "errors" even with HTTP 200.
    final errors = body['errors'] as List<dynamic>?;

    if (errors != null && errors.isNotEmpty) {
      final first = errors.first as Map<String, dynamic>;

      throw ServerException(
        message: (first['message'] ?? 'Failed to fetch modes.').toString(),
        statusCode: response.statusCode,
      );
    }

    final data = body['data'] as Map<String, dynamic>? ?? {};

    final modes = data['modes'] as List<dynamic>? ?? [];

    AppLogger.d(tag, 'getModes count: ${modes.length}');

    return modes
        .map((mode) => GeofenceModeModel.fromJson(mode as Map<String, dynamic>))
        .toList();
  }

  // ───────────────────────── Mode Conditions ─────────────────────────

  static const _tag = 'ModeConditionsRemoteDataSource';

  /// Fetch mode conditions using GraphQL.
  Future<List<ModeConditionModel>> getModeConditions({
    required String deviceId,
    required String conditionType,
    bool enabled = true,
    String scope = 'device',
    int? page,
    int? limit,
  }) async {
    AppLogger.d(
      _tag,
      'getModeConditions() device: $deviceId, type: $conditionType',
    );

    final response = await _dioClient.dio.post(
      ApiConstants.modeConditionsQuery,
      data: {
        'query': ModeConditionsQuery.getModeConditions,
        'variables': {
          'deviceId': deviceId,
          'conditionType': conditionType,
          'enabled': enabled,
          'scope': scope,
        },
      },
    );

    final body = response.data as Map<String, dynamic>;

    // GraphQL can return errors inside "errors" even with HTTP 200.
    final errors = body['errors'] as List<dynamic>?;

    if (errors != null && errors.isNotEmpty) {
      final first = errors.first as Map<String, dynamic>;

      throw ServerException(
        message: (first['message'] ?? 'Failed to fetch mode conditions.')
            .toString(),
        statusCode: response.statusCode,
      );
    }

    final data = body['data'] as Map<String, dynamic>? ?? {};

    final list = data['modeConditions'] as List<dynamic>? ?? [];

    AppLogger.d(_tag, 'getModeConditions count: ${list.length}');

    return list
        .map(
          (condition) =>
              ModeConditionModel.fromJson(condition as Map<String, dynamic>),
        )
        .toList();
  }

  /// Create a mode condition.
  Future<void> createModeCondition({
    required String modeId,
    required String deviceId,
    required String conditionType,
    required bool enabled,
    required Map<String, dynamic> config,
  }) async {
    AppLogger.d(_tag, 'createModeCondition() device: $deviceId');

    final response = await _dioClient.dio.post(
      ApiConstants.modeConditions,
      data: _buildBody(modeId, deviceId, conditionType, enabled, config),
    );

    _checkSuccess(response.data, 'Failed to create mode condition.');
  }

  /// Update a mode condition.
  Future<void> updateModeCondition({
    required String conditionId,
    required String modeId,
    required String deviceId,
    required String conditionType,
    required bool enabled,
    required Map<String, dynamic> config,
  }) async {
    AppLogger.d(_tag, 'updateModeCondition() id: $conditionId');

    final response = await _dioClient.dio.put(
      '${ApiConstants.modeConditions}/$conditionId',
      data: _buildBody(modeId, deviceId, conditionType, enabled, config),
    );

    _checkSuccess(response.data, 'Failed to update mode condition.');
  }

  /// Delete a mode condition.
  Future<void> deleteModeCondition(String conditionId) async {
    AppLogger.d(_tag, 'deleteModeCondition() id: $conditionId');

    final response = await _dioClient.dio.delete(
      '${ApiConstants.modeConditions}/$conditionId',
    );

    _checkSuccess(response.data, 'Failed to delete mode condition.');
  }

  // ───────────────────────── Helpers ─────────────────────────

  Map<String, dynamic> _buildBody(
    String modeId,
    String deviceId,
    String conditionType,
    bool enabled,
    Map<String, dynamic> config,
  ) {
    return {
      'mode_id': modeId,
      'device_id': deviceId,
      'condition_type': conditionType,
      'enabled': enabled,
      'config': config,
    };
  }

  void _checkSuccess(dynamic data, String fallbackMessage) {
    final body = data as Map<String, dynamic>;

    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? fallbackMessage,
        statusCode: body['code'] as int?,
      );
    }
  }
}
