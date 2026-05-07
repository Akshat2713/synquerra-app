import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../../network/dio_client.dart';
import '../../network/api_constants.dart';
import '../../models/auth/user_model.dart';
import '../../../core/error/app_exceptions.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient);

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    debugPrint('[AuthRemoteDataSource] login() called for $email');

    final response = await _dioClient.dio.post(
      ApiConstants.signIn,
      data: {'email': email, 'password': password},
    );

    final body = response.data as Map<String, dynamic>;

    debugPrint('[AuthRemoteDataSource] Response status: ${body['status']}');

    if (body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Login failed.',
        statusCode: body['code'] as int?,
      );
    }

    // Parse off the main thread
    final user = await Isolate.run(
      () => UserModel.fromJson(body['data'] as Map<String, dynamic>),
    );

    debugPrint(
      '[AuthRemoteDataSource] User parsed: ${user.firstName} ${user.lastName}',
    );

    return user;
  }
}
