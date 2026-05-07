import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../entities/auth/user_entity.dart';
import '../../repositories/auth_repository.dart';
import '../base_usecase.dart';

class CheckAuthStatusUseCase implements UseCase<UserEntity?, NoParams> {
  final AuthRepository _repository;

  CheckAuthStatusUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) {
    return _repository.getLoggedInUser();
  }
}
