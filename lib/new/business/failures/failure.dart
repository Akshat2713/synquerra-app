// lib/business/failures/failure.dart
import 'package:equatable/equatable.dart';

/// Base failure class for all domain errors
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Network related failures
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.statusCode});
}

/// Server related failures (API errors, 5xx, etc.)
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Authentication related failures (invalid token, unauthorized)
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

/// Cache/Storage related failures
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.statusCode});
}

/// Validation related failures (invalid input)
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.statusCode});
}

/// Unknown/unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.statusCode});
}
