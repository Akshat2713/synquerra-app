import 'dart:io';

import 'package:dio/dio.dart';
import '../../../core/error/app_exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        exception = const NetworkException(message: 'Connection timed out.');
        break;

      case DioExceptionType.unknown:
        if (err.error is SocketException) {
          exception = const NetworkException();
        } else if (err.error is AppException) {
          // Already wrapped — pass through
          return handler.next(err);
        } else {
          exception = ServerException(
            message: err.message ?? 'Unexpected error.',
            statusCode: err.response?.statusCode,
          );
        }
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final data = err.response?.data;
        final serverMessage =
            (data is Map ? data['message'] as String? : null) ??
            'Server error.';

        if (statusCode == 401) {
          exception = AuthException(
            message: serverMessage,
            statusCode: statusCode,
          );
        } else if (statusCode == 404) {
          exception = ServerException(
            message: 'Resource not found.',
            statusCode: statusCode,
          );
        } else if (statusCode == 500) {
          exception = ServerException(
            message: 'Internal server error.',
            statusCode: statusCode,
          );
        } else {
          exception = ServerException(
            message: serverMessage,
            statusCode: statusCode,
          );
        }
        break;

      default:
        exception = ServerException(
          message: err.message ?? 'Unexpected error.',
          statusCode: err.response?.statusCode,
        );
    }

    // ✅ Reject with the exception attached, not thrown
    return handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
        response: err.response,
      ),
    );
  }
}
