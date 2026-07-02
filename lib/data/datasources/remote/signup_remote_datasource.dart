import 'package:flutter/foundation.dart';
import 'dart:isolate';
import '../../models/signup/person_model.dart';

import '../../../core/error/app_exceptions.dart';
import '../../network/api_constants.dart';
import '../../network/dio_client.dart';

class SignupRemoteDataSource {
  final DioClient _dioClient;

  SignupRemoteDataSource(this._dioClient);

  // ── Step 1: Create Person ─────────────────────────────────
  Future<PersonModel> createPerson({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String birthDate,
    required String gender,
    required String address,
    required String city,
    required String state,
    required String country,
    required String pincode,
  }) async {
    debugPrint('[SignupRemoteDataSource] createPerson() called for $email');

    final response = await _dioClient.dio.post(
      ApiConstants.createPerson,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'birth_date': birthDate,
        'gender': gender,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'pincode': pincode,
        'is_active': true,
      },
    );

    final body = response.data as Map<String, dynamic>;
    debugPrint(
      '[SignupRemoteDataSource] createPerson status: ${body['status']}',
    );

    // ← status check FIRST, before any parsing
    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to create profile.',
        statusCode: body['code'] as int?,
      );
    }

    final rawData = body['data'];
    if (rawData == null || rawData is! Map<String, dynamic>) {
      throw ServerException(
        message: 'Invalid response from server.',
        statusCode: body['code'] as int?,
      );
    }

    // ← Isolate.run AFTER status check, passing rawData not full body
    final person = await Isolate.run(() => PersonModel.fromJson(rawData));

    debugPrint('[SignupRemoteDataSource] Person created: ${person.personId}');
    return person;
  }

  // ── Step 2: Create Credentials ────────────────────────────
  Future<void> createCredentials({
    required String personId,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    debugPrint(
      '[SignupRemoteDataSource] createCredentials() called for $email',
    );

    final response = await _dioClient.dio.post(
      ApiConstants.signUp,
      data: {
        'person_id': personId,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    final body = response.data as Map<String, dynamic>;
    debugPrint(
      '[SignupRemoteDataSource] createCredentials status: ${body['status']}',
    );

    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to create credentials.',
        statusCode: body['code'] as int?,
      );
    }
  }
}
