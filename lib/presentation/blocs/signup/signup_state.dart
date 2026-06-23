part of 'signup_bloc.dart';

enum SignupStatus { idle, loading, error, stepSuccess, done }

class SignupState extends Equatable {
  final int step;
  final SignupStatus status;
  final String? errorMessage;
  final String? personId;
  final String? email;
  final String? credentialsEmail;

  const SignupState({
    this.step = 1,
    this.status = SignupStatus.idle,
    this.errorMessage,
    this.personId,
    this.email,
    this.credentialsEmail,
  });

  SignupState copyWith({
    int? step,
    SignupStatus? status,
    String? errorMessage,
    String? personId,
    String? email,
    String? credentialsEmail,
  }) {
    return SignupState(
      step: step ?? this.step,
      status: status ?? this.status,
      errorMessage: errorMessage,
      personId: personId ?? this.personId,
      email: email ?? this.email,
      credentialsEmail: credentialsEmail ?? this.credentialsEmail,
    );
  }

  @override
  List<Object?> get props => [
    step,
    status,
    errorMessage,
    personId,
    email,
    credentialsEmail,
  ];
}
