import 'dart:isolate';
import '../../network/dio_client.dart';
import '../../network/api_constants.dart';
import '../../models/relationship/relationship_model.dart';
import '../../../core/error/app_exceptions.dart';
import '../../../core/utils/app_logger.dart';

class RelationshipRemoteDataSource {
  final DioClient _dioClient;

  RelationshipRemoteDataSource(this._dioClient);

  Future<List<RelationshipModel>> getRelationshipList(String personId) async {
    AppLogger.d(
      'RelationshipRemoteDataSource',
      'getRelationshipList() called for $personId',
    );
    final response = await _dioClient.dio.get(
      ApiConstants.relationshipList(personId),
    );

    final body = response.data as Map<String, dynamic>;

    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to fetch relationships.',
        statusCode: body['code'] as int?,
      );
    }

    final rawList = body['data'] as List<dynamic>;

    // Parse list off the main thread
    final relationships = await Isolate.run(
      () => rawList
          .map((e) => RelationshipModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    AppLogger.d(
      'RelationshipRemoteDataSource',
      'Fetched ${relationships.length} relationships',
    );

    return relationships;
  }
}
