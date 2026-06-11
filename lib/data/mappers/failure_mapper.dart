import '../../core/error/app_exceptions.dart';
import '../../domain/failures/failure.dart';

Failure mapExceptionToFailure(Object e) {
  if (e is AuthException) {
    return AuthFailure(message: e.message);
  } else if (e is NetworkException) {
    return NetworkFailure(message: e.message);
  } else if (e is NotFoundException) {
    return NotFoundFailure(message: e.message);
  } else if (e is PermissionException) {
    return PermissionFailure(message: e.message);
  } else if (e is ServerException) {
    return ServerFailure(message: e.message, statusCode: e.statusCode);
  } else if (e is CacheException) {
    return CacheFailure(message: e.message);
  } else if (e is AppException) {
    return ServerFailure(message: e.message);
  } else {
    return UnknownFailure(message: e.toString());
  }
}
