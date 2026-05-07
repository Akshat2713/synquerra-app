import 'dart:io';

import 'package:dio/dio.dart';
import '../../../core/error/app_exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        throw NetworkException(message: 'Connection timed out.');

      case DioExceptionType.unknown:
        if (err.error is SocketException) {
          throw const NetworkException();
        }
        throw ServerException(
          message: err.message ?? 'Unexpected error.',
          statusCode: err.response?.statusCode,
        );

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final data = err.response?.data;
        final serverMessage =
            (data is Map ? data['message'] : null) ?? 'Server error.';

        if (statusCode == 401) {
          throw AuthException(message: serverMessage, statusCode: statusCode);
        }
        throw ServerException(message: serverMessage, statusCode: statusCode);

      default:
        throw ServerException(
          message: err.message ?? 'Unexpected error.',
          statusCode: err.response?.statusCode,
        );
    }
  }
}
