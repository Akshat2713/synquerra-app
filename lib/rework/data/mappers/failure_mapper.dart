import 'package:dio/dio.dart';

import '../../core/error/app_exceptions.dart';
import '../../domain/failures/failure.dart';

Failure mapExceptionToFailure(Object e) {
  // final err = (e is DioException && e.error is AppException)
  //     ? e.error as AppException
  //     : e;

  if (e is AuthException) {
    return AuthFailure(message: e.message);
  } else if (e is NetworkException) {
    return NetworkFailure(message: e.message);
  } else if (e is ServerException) {
    return ServerFailure(
      message: e.statusCode != null
          ? '${e.message} (status: ${e.statusCode})'
          : e.message,
    );
  } else if (e is CacheException) {
    return CacheFailure(message: e.message);
  } else if (e is AppException) {
    return ServerFailure(message: e.message);
  } else {
    return UnknownFailure(message: e.toString());
  }
}
