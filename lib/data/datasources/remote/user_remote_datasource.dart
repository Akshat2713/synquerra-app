// lib/data/datasources/remote/user_remote_datasource.dart

import 'dart:io';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:synquerra/data/models/signup/person_model.dart';
import '../../network/dio_client.dart';
import '../../network/api_constants.dart';
import '../../../core/error/app_exceptions.dart';
import '../../../core/utils/app_logger.dart';

abstract class UserRemoteDataSource {
  Future<PersonModel> fetchUserProfile();
  Future<PersonModel> updateUserProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? password,
    String? relationshipType,
    bool? isHead,
    String? middleName,
    String? mobile,
    String? birthDate,
    String? gender,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
    File? profileImage,
  });
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final DioClient _dioClient;

  UserRemoteDataSourceImpl(this._dioClient);

  @override
  Future<PersonModel> fetchUserProfile() async {
    AppLogger.d('UserRemoteDataSourceImpl', 'fetchUserProfile() called');

    final response = await _dioClient.dio.get(ApiConstants.fetchUser);
    final body = response.data as Map<String, dynamic>;

    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to fetch user profile.',
        statusCode: body['code'] as int?,
      );
    }

    return await Isolate.run(
      () => PersonModel.fromJson(body['data'] as Map<String, dynamic>),
    );
  }

  @override
  Future<PersonModel> updateUserProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? password,
    String? relationshipType,
    bool? isHead,
    String? middleName,
    String? mobile,
    String? birthDate,
    String? gender,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
    File? profileImage,
  }) async {
    AppLogger.d('UserRemoteDataSourceImpl', 'updateUserProfile() called');

    final Map<String, dynamic> data = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      if (password != null && password.isNotEmpty) 'password': password,
      if (relationshipType != null) 'relationship_type': relationshipType,
      if (isHead != null) 'is_head': isHead,
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
    };

    dynamic payload = data;

    if (profileImage != null) {
      payload = FormData.fromMap({
        ...data,
        'profile_photo': await MultipartFile.fromFile(
          profileImage.path,
          filename: profileImage.path.split('/').last,
        ),
      });
    }

    final response = await _dioClient.dio.patch(
      ApiConstants.updateProfile,
      data: payload,
      options: payload is FormData
          ? Options(
              contentType: 'multipart/form-data; boundary=${payload.boundary}',
            )
          : null, // let the client's existing default (application/json) apply, unchanged from before
    );
    final body = response.data as Map<String, dynamic>;

    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to update user profile.',
        statusCode: body['code'] as int?,
      );
    }

    return await Isolate.run(
      () => PersonModel.fromJson(body['data'] as Map<String, dynamic>),
    );
  }
}
