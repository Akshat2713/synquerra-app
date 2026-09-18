// lib/domain/usecases/user/get_user_profile_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:synquerra/domain/entities/signup/person_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

class GetUserProfileUseCase implements UseCase<PersonEntity, NoParams> {
  final UserRepository _repository;

  GetUserProfileUseCase(this._repository);

  @override
  Future<Either<Failure, PersonEntity>> call(NoParams params) {
    return _repository.getUserProfile();
  }
}
