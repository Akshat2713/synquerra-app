import 'failure.dart';

String mapFailureToMessage(Failure failure) {
  if (failure is NetworkFailure) return 'No internet connection.';
  if (failure is ServerFailure) {
    return failure.message.isNotEmpty ? failure.message : 'Server error.';
  }
  return 'Something went wrong.';
}
