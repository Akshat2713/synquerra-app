abstract class Failure {
  final String message;
  const Failure({this.message = ''});
}

class ServerFailure extends Failure {
  const ServerFailure({super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection.'});
}

class AuthFailure extends Failure {
  const AuthFailure({super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'Something went wrong.'});
}

extension FailureMessage on Failure {
  String get userMessage {
    if (this is NetworkFailure) return 'No internet connection.';
    if (this is ServerFailure) {
      return message.isNotEmpty ? message : 'Server error.';
    }
    if (this is AuthFailure) return 'Authentication failed.';
    return 'Something went wrong.';
  }
}
