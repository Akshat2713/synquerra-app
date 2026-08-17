// lib/features/relationship/data/datasources/remote/relationship_remote_datasource.dart

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
      '${ApiConstants.createPerson}/relationship', // /api/v1/persons/relationship
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
  Future<void> createRelationshipByPhone({
    required String personId,
    required String phoneNumber,
    required String relationType,
  }) async {
    AppLogger.d(
      'RelationshipRemoteDataSource',
      'createRelationshipByPhone() called for $phoneNumber with type $relationType',
    );

    final response = await _dioClient.dio.post(
      ApiConstants.createRelationshipByPhone,
      data: {
        'person_id': personId,
        'phone_number': phoneNumber,
        'relation_type': relationType,
      },
    );

    final body = response.data as Map<String, dynamic>;

    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to create relationship by phone.',
        statusCode: body['code'] as int?,
      );
    }
  }

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
