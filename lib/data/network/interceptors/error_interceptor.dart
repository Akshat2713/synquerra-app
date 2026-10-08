import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/error/app_exceptions.dart';
import '../session_expired_notifier.dart';

class ErrorInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final SessionExpiredNotifier _sessionNotifier;

  ErrorInterceptor(this._storage, this._sessionNotifier);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
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

      // In error_interceptor.dart — expand the badResponse case:

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final data = err.response?.data;
        final serverMessage = (data is Map ? data['message'] as String? : null);

        switch (statusCode) {
          case 400:
            exception = ServerException(
              message: serverMessage ?? 'Bad request. Please check your input.',
              statusCode: statusCode,
            );
          case 401:
            final hadToken = err.requestOptions.headers.containsKey(
              'Authorization',
            );
            if (hadToken) {
              await _clearTokens();
              _sessionNotifier.notify();
            }
            exception = AuthException(
              message: serverMessage ?? 'Session expired. Please log in again.',
              statusCode: statusCode,
            );
          case 403:
            exception = AuthException(
              message:
                  serverMessage ?? 'You don\'t have permission to do that.',
              statusCode: statusCode,
            );
          case 404:
            exception = NotFoundException(
              // NEW exception type
              message: serverMessage ?? 'Resource not found.',
              statusCode: statusCode,
            );
          case 408:
            exception = NetworkException(
              message: 'Request timed out. Please try again.',
            );
          case 422:
            exception = ServerException(
              message: serverMessage ?? 'Invalid data submitted.',
              statusCode: statusCode,
            );
          case 429:
            exception = ServerException(
              message: 'Too many requests. Please slow down.',
              statusCode: statusCode,
            );
          case 500:
            exception = ServerException(
              message: 'Internal server error. Please try again later.',
              statusCode: statusCode,
            );
          case 502:
          case 503:
          case 504:
            exception = ServerException(
              message:
                  'Service temporarily unavailable. Please try again later.',
              statusCode: statusCode,
            );
          default:
            exception = ServerException(
              message: serverMessage ?? 'Unexpected error (HTTP $statusCode).',
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

  Future<void> _clearTokens() async {
    try {
      await Future.wait([
        _storage.delete(key: 'cached_user'),
        _storage.delete(key: 'access_token'),
        _storage.delete(key: 'refresh_token'),
        _storage.delete(key: 'person_id'),
        _storage.delete(key: 'last_sent_fcm_token'),
      ]);
    } catch (e) {
      // Ignore errors during token clearing
    }
  }
}
