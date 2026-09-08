// lib/features/relationship/data/datasources/remote/relationship_remote_datasource.dart

import 'dart:isolate';
import '../../models/signup/person_model.dart';
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
    final response = await _dioClient.dio.get(ApiConstants.relationshipList);

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

  Future<PersonModel> searchPersonByPhone(String phoneNumber) async {
    AppLogger.d(
      'RelationshipRemoteDataSource',
      'searchPersonByPhone() called for $phoneNumber',
    );

    final response = await _dioClient.dio.get(
      ApiConstants.createRelationshipByPhone,
      queryParameters: {'query': phoneNumber},
    );

    final body = response.data as Map<String, dynamic>;

    if (body['status'] != 'success') {
      final code = body['code'] as int?;
      if (code == 404) {
        throw NotFoundException(
          message: body['message'] ?? 'No user found with this phone number.',
          statusCode: code,
        );
      }
      throw ServerException(
        message: body['message'] ?? 'Failed to search user.',
        statusCode: code,
      );
    }

    return PersonModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> createRelationship({
    required String relatedUserId,
    required String relationshipType,
  }) async {
    AppLogger.d(
      'RelationshipRemoteDataSource',
      'createRelationship() for $relatedUserId',
    );

    final response = await _dioClient.dio.post(
      ApiConstants.createRelation,
      data: {
        'related_user_id': relatedUserId,
        'relationship_type': relationshipType,
      },
    );

    final body = response.data as Map<String, dynamic>;
    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to create relationship.',
        statusCode: body['code'] as int?,
      );
    }
  }

  /// Unlink / Delete Relationship by ID
  Future<void> deleteRelationship(String relationshipId) async {
    AppLogger.d(
      'RelationshipRemoteDataSource',
      'deleteRelationship() called for $relationshipId',
    );

    final response = await _dioClient.dio.delete(
      '/api/v1/relationships/$relationshipId',
    );

    final body = response.data as Map<String, dynamic>;

    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to unlink relationship.',
        statusCode: body['code'] as int?,
      );
    }
  }

  /// Create / Link Relationship by Phone Number

  Future<void> unlinkRelationship(String relationshipId) async {
    AppLogger.d(
      'RelationshipRemoteDataSource',
      'deleteRelationship() called for $relationshipId',
    );

    final response = await _dioClient.dio.delete(
      '${ApiConstants.createPerson}/relationship/$relationshipId', // Resolves to /api/v1/persons/relationship/:relationship_id
    );

    final body = response.data as Map<String, dynamic>;

    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to unlink relationship.',
        statusCode: body['code'] as int?,
      );
    }
  }
}
