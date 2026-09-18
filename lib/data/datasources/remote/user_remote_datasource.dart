// lib/data/datasources/remote/user_remote_datasource.dart

import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:synquerra/data/models/signup/person_model.dart';
import '../../network/dio_client.dart';
import '../../network/api_constants.dart';
import '../../../core/error/app_exceptions.dart';
import '../../../core/utils/app_logger.dart';

abstract class UserRemoteDataSource {
  Future<PersonModel> fetchUserProfile();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final DioClient _dioClient;

  UserRemoteDataSourceImpl(this._dioClient);

  @override
  Future<PersonModel> fetchUserProfile() async {
    AppLogger.d('UserRemoteDataSourceImpl', 'fetchUserProfile() called');

    final response = await _dioClient.dio.get(ApiConstants.fetchUser);

    final body = response.data as Map<String, dynamic>;

    AppLogger.d(
      'UserRemoteDataSourceImpl',
      'Response status: ${body['status']}',
    );

    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Failed to fetch user profile.',
        statusCode: body['code'] as int?,
      );
    }

    final user = await Isolate.run(
      () => PersonModel.fromJson(body['data'] as Map<String, dynamic>),
    );
    debugPrint(
      '[UserRemoteDataSourceImpl] Profile fetched: ${user.firstName} ${user.lastName}',
    );

    return user;
  }
}
