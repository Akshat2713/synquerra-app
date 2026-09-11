part of 'signup_bloc.dart';

enum SignupStatus { idle, loading, error, done }

class SignupState extends Equatable {
  final SignupStatus status;
  final String? errorMessage;
  final String? personId;

  const SignupState({
    this.status = SignupStatus.idle,
    this.errorMessage,
    this.personId,
  });

  SignupState copyWith({
    SignupStatus? status,
    String? errorMessage,
    String? personId,
  }) {
    return SignupState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      personId: personId ?? this.personId,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, personId];
}
