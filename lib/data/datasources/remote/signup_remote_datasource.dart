import 'package:flutter/foundation.dart';
import 'dart:isolate';
import '../../models/signup/person_model.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/error/app_exceptions.dart';
import '../../network/api_constants.dart';
import '../../network/dio_client.dart';

class SignupRemoteDataSource {
  final DioClient _dioClient;

  SignupRemoteDataSource(this._dioClient);

  Future<PersonModel> signUp({
    required String firstName,
    required String email,
    required String password,
    String? lastName,
    String? phone,
    String? userClass,
    String? birthDate,
    String? gender,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
    String? profilePhoto,
  }) async {
    AppLogger.d('SignupRemoteDataSource', 'signUp() called for $email');

    final response = await _dioClient.dio.post(
      ApiConstants.signUp, // ⚠️ confirm this points to the new merged endpoint
      data: {
        'first_name': firstName,
        'email': email,
        'password': password,
        if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (userClass != null) 'user_class': userClass,
        if (birthDate != null && birthDate.isNotEmpty) 'birth_date': birthDate,
        if (gender != null && gender.isNotEmpty) 'gender': gender,
        if (address != null && address.isNotEmpty) 'address': address,
        if (city != null && city.isNotEmpty) 'city': city,
        if (state != null && state.isNotEmpty) 'state': state,
        if (country != null && country.isNotEmpty) 'country': country,
        if (pincode != null && pincode.isNotEmpty) 'pincode': pincode,
        if (profilePhoto != null) 'profile_photo': profilePhoto,
      },
    );

    final body = response.data as Map<String, dynamic>;
    debugPrint('[SignupRemoteDataSource] signUp status: ${body['status']}');

    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to sign up.',
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

    final person = await Isolate.run(() => PersonModel.fromJson(rawData));
    AppLogger.d('SignupRemoteDataSource', 'Signed up: ${person.id}');
    return person;
  }

  // ── Delete Person (retained) ────────────────────────────────
  Future<void> deletePerson(String personId) async {
    debugPrint('[SignupRemoteDataSource] deletePerson() called for $personId');

    final response = await _dioClient.dio.delete(
      ApiConstants.deleteUser(personId), // ⚠️ confirm this path still exists
    );

    final body = response.data as Map<String, dynamic>;
    debugPrint(
      '[SignupRemoteDataSource] deletePerson status: ${body['status']}',
    );

    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to delete person.',
        statusCode: body['code'] as int?,
      );
    }
  }
}
