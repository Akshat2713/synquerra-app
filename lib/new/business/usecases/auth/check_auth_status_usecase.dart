// lib/business/usecases/auth/check_auth_status_usecase.dart
import 'package:dartz/dartz.dart';
import '../../repositories/auth_repository.dart';
import '../../entities/user_entity.dart';
import '../../failures/failure.dart';

class CheckAuthStatusUseCase {
  final AuthRepository _repository;

  CheckAuthStatusUseCase(this._repository);

  Future<Either<Failure, UserEntity?>> call() async {
    return await _repository.getUser();
  }
}
