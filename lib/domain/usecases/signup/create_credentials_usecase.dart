import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../repositories/signup_repository.dart';
import '../base_usecase.dart';

class CreateCredentialsParams {
  final String personId;
  final String email;
  final String password;
  final String passwordConfirmation;

  const CreateCredentialsParams({
    required this.personId,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });
}

class CreateCredentialsUseCase
    implements UseCase<void, CreateCredentialsParams> {
  final SignupRepository _repository;

  CreateCredentialsUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(CreateCredentialsParams params) {
    return _repository.createCredentials(
      personId: params.personId,
      email: params.email,
      password: params.password,
      passwordConfirmation: params.passwordConfirmation,
    );
  }
}
