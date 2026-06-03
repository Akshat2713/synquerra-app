import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../repositories/auth_repository.dart';
import '../base_usecase.dart';

class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.logout();
  }
}
