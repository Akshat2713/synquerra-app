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

  Future<PersonModel> createPersonWithRelationship({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String relationshipType,
    String? middleName,
    String? mobile,
    String? birthDate,
    String? gender,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
    bool isHead = false,
  }) async {
    AppLogger.d(
      'RelationshipRemoteDataSource',
      'createPersonWithRelationship() called for $email',
    );

    final response = await _dioClient.dio.post(
      ApiConstants.createPersonWithRelationship,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'relationship_type': relationshipType,
        'is_head': isHead,
        if (middleName != null && middleName.isNotEmpty)
          'middle_name': middleName,
        if (mobile != null && mobile.isNotEmpty) 'mobile': mobile,
        if (birthDate != null && birthDate.isNotEmpty) 'birth_date': birthDate,
        if (gender != null && gender.isNotEmpty) 'gender': gender,
        if (address != null && address.isNotEmpty) 'address': address,
        if (city != null && city.isNotEmpty) 'city': city,
        if (state != null && state.isNotEmpty) 'state': state,
        if (country != null && country.isNotEmpty) 'country': country,
        if (pincode != null && pincode.isNotEmpty) 'pincode': pincode,
      },
    );

    final body = response.data as Map<String, dynamic>;
    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to add family member.',
        statusCode: body['code'] as int?,
      );
    }

    return PersonModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// Unlink / Delete Relationship by ID
  Future<void> deleteRelationship(String userId) async {
    AppLogger.d(
      'RelationshipRemoteDataSource',
      'deleteRelationship() called for $userId',
    );

    final response = await _dioClient.dio.delete(
      ApiConstants.deleteUser(userId),
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

  Future<void> unlinkRelationship(String relatedUserId) async {
    AppLogger.d(
      'RelationshipRemoteDataSource',
      'deleteRelationship() called for $relatedUserId',
    );

    final response = await _dioClient.dio.delete(
      ApiConstants.removeRelationship(relatedUserId),
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
