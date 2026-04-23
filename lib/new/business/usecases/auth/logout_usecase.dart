// lib/business/usecases/auth/logout_usecase.dart
import 'package:dartz/dartz.dart';
import '../../repositories/auth_repository.dart';
import '../../failures/failure.dart';

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Either<Failure, void>> call() async {
    return await _repository.logout();
  }
}
