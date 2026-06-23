import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../entities/auth/user_entity.dart';
import '../../repositories/auth_repository.dart';
import '../base_usecase.dart';

class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}

class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) {
    return _repository.login(email: params.email, password: params.password);
  }
}
