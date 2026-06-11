// lib/domain/failures/failure.dart

abstract class Failure {
  final String message;
  const Failure({this.message = ''});

  /// Single source of truth for user-facing error strings.
  String get userMessage;
}

class ServerFailure extends Failure {
  final int? statusCode; // for logging only
  const ServerFailure({super.message, this.statusCode});
  @override
  String get userMessage =>
      message.isNotEmpty ? message : 'Server error. Please try again.';
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection.'});
  @override
  String get userMessage =>
      'No internet connection. Please check your network.';
}

class AuthFailure extends Failure {
  const AuthFailure({super.message});
  @override
  String get userMessage =>
      message.isNotEmpty ? message : 'Invalid email or password.';
}

class CacheFailure extends Failure {
  const CacheFailure({super.message});
  @override
  String get userMessage =>
      'Failed to read local data. Please restart the app.';
}

class NotFoundFailure extends Failure {
  // NEW
  const NotFoundFailure({super.message});
  @override
  String get userMessage =>
      message.isNotEmpty ? message : 'Requested data was not found.';
}

class PermissionFailure extends Failure {
  // NEW
  const PermissionFailure({super.message});
  @override
  String get userMessage => message.isNotEmpty ? message : 'Permission denied.';
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'Something went wrong.'});
  @override
  String get userMessage => 'Something went wrong. Please try again.';
}

// abstract class Failure {
//   final String message;
//   const Failure({this.message = ''});
// }

// class ServerFailure extends Failure {
//   const ServerFailure({super.message});
// }

// class NetworkFailure extends Failure {
//   const NetworkFailure({super.message = 'No internet connection.'});
// }

// class AuthFailure extends Failure {
//   const AuthFailure({super.message});
// }

// class CacheFailure extends Failure {
//   const CacheFailure({super.message});
// }

// class UnknownFailure extends Failure {
//   const UnknownFailure({super.message = 'Something went wrong.'});
// }

// extension FailureMessage on Failure {
//   String get userMessage {
//     if (this is NetworkFailure) return 'No internet connection.';
//     if (this is ServerFailure) {
//       return message.isNotEmpty ? message : 'Server error.';
//     }
//     if (this is AuthFailure) return 'Authentication failed.';
//     return 'Something went wrong.';
//   }
// }
