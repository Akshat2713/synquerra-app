class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() => 'AppException: $message (status: $statusCode)';
}

class NetworkException extends AppException {
  const NetworkException({super.message = 'No internet connection.'});
}

class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});
}

class AuthException extends AppException {
  const AuthException({required super.message, super.statusCode});
}

class CacheException extends AppException {
  const CacheException({required super.message});
}
