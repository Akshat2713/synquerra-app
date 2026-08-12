import 'dart:isolate';
import 'package:flutter/foundation.dart';
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

  /// Create / Link Relationship
  Future<void> createRelationship({
    required String personAId,
    required String personBId,
    required String relationshipType,
  }) async {
    debugPrint(
      '[RelationshipRemoteDataSource] createRelationship() called between $personAId and $personBId',
    );

    final response = await _dioClient.dio.post(
      '${ApiConstants.createPerson}/relationship', // Resolves to /api/v1/persons/relationship
      data: {
        'person_a_id': personAId,
        'person_b_id': personBId,
        'relationship_type': relationshipType,
      },
    );

    final body = response.data as Map<String, dynamic>;
    AppLogger.d(
      'RelationshipRemoteDataSource',
      'createRelationship status: ${body['status']}',
    );

    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to create relationship.',
        statusCode: body['code'] as int?,
      );
    }
  }
}
