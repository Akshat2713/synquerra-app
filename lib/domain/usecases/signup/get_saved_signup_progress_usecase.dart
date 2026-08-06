import 'package:dartz/dartz.dart';

import '../../entities/signup/signup_progress_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/signup_repository.dart';
import '../base_usecase.dart';

class GetSavedSignupProgressUseCase
    implements UseCase<SignupProgressEntity?, NoParams> {
  final SignupRepository _repository;

  GetSavedSignupProgressUseCase(this._repository);

  @override
  Future<Either<Failure, SignupProgressEntity?>> call(NoParams params) {
    return _repository.getSavedProgress();
  }
}
