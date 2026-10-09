// lib/data/datasources/remote/user_remote_datasource.dart

import 'dart:io';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
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
  static const _tag = 'UserRemoteDataSourceImpl';

  final DioClient _dioClient;

  UserRemoteDataSourceImpl(this._dioClient);

  @override
  Future<PersonModel> fetchUserProfile() async {
    AppLogger.d(_tag, 'fetchUserProfile() called');

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
    AppLogger.d(_tag, 'updateUserProfile() called');

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
      final filename = profileImage.path.split(Platform.pathSeparator).last;

      payload = FormData.fromMap({
        ...data,
        'profile_photo': await MultipartFile.fromFile(
          profileImage.path,
          filename: filename,
          contentType: _imageMediaType(filename),
        ),
      });
    }

    _logPayload(payload);

    final Response response;
    try {
      response = await _dioClient.dio.patch(
        ApiConstants.updateProfile,
        data: payload,
        // No manual contentType: Dio sets multipart + boundary for FormData
        // and application/json for a Map by itself.
      );
    } on DioException catch (e) {
      if (kDebugMode) {
        AppLogger.d(_tag, '❌ PATCH failed');
        AppLogger.d(_tag, 'status: ${e.response?.statusCode}');
        AppLogger.d(_tag, 'response body: ${e.response?.data}');
        AppLogger.d(
          _tag,
          'request content-type: '
          '${e.requestOptions.headers['content-type'] ?? e.requestOptions.contentType}',
        );
        AppLogger.d(_tag, 'dio error type: ${e.type}, message: ${e.message}');
      }
      rethrow;
    }

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

  // ── Debug helpers ──────────────────────────────────────────────

  void _logPayload(dynamic payload) {
    if (!kDebugMode) return;

    if (payload is FormData) {
      final fields = {for (final f in payload.fields) f.key: f.value};
      if (fields.containsKey('password')) fields['password'] = '***';

      AppLogger.d(_tag, 'PATCH ${ApiConstants.updateProfile} (multipart)');
      AppLogger.d(_tag, 'fields: $fields');
      AppLogger.d(
        _tag,
        'files: ${payload.files.map((f) => '${f.key} -> '
            'filename=${f.value.filename}, '
            'length=${f.value.length}, '
            'contentType=${f.value.contentType}').toList()}',
      );
    } else {
      final safe = Map<String, dynamic>.from(payload as Map);
      if (safe.containsKey('password')) safe['password'] = '***';

      AppLogger.d(_tag, 'PATCH ${ApiConstants.updateProfile} (json)');
      AppLogger.d(_tag, 'payload: $safe');
    }
  }

  MediaType _imageMediaType(String filename) {
    switch (filename.split('.').last.toLowerCase()) {
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'gif':
        return MediaType('image', 'gif');
      case 'jpg':
      case 'jpeg':
      default:
        return MediaType('image', 'jpeg');
    }
  }
}
