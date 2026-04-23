// lib/data/network/error_handler.dart
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

class NetworkErrorHandler {
  NetworkErrorHandler._(); // Prevent instantiation

  /// Handle HTTP response and throw appropriate exceptions
  static void handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 202:
        // Success - do nothing
        return;
      case 400:
        throw ApiException(
          'Bad request. Please check your input.',
          statusCode: 400,
        );
      case 401:
        throw ApiException(
          'Unauthorized. Please login again.',
          statusCode: 401,
        );
      case 403:
        throw ApiException(
          'Forbidden. You don\'t have permission.',
          statusCode: 403,
        );
      case 404:
        throw ApiException('Resource not found.', statusCode: 404);
      case 500:
        throw ApiException(
          'Internal server error. Please try again later.',
          statusCode: 500,
        );
      case 502:
        throw ApiException(
          'Bad gateway. Please try again later.',
          statusCode: 502,
        );
      case 503:
        throw ApiException(
          'Service unavailable. Please try again later.',
          statusCode: 503,
        );
      default:
        throw ApiException(
          'Something went wrong. Status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
    }
  }

  /// Handle network/dio errors
  static Exception handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    } else if (error is SocketException) {
      return NetworkException(
        'No internet connection. Please check your network.',
      );
    } else if (error is TimeoutException) {
      return NetworkException('Connection timeout. Please try again.');
    } else if (error is HttpException) {
      return NetworkException('Network error: ${error.message}');
    } else {
      return UnknownException(error.toString());
    }
  }
}

/// API Exception with status code
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Network Exception (connectivity issues)
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => message;
}

/// Unknown Exception
class UnknownException implements Exception {
  final String message;

  UnknownException(this.message);

  @override
  String toString() => message;
}
