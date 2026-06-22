import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../repositories/signup_repository.dart';
import '../base_usecase.dart';

class ClearSavedSignupProgressUseCase implements UseCase<void, NoParams> {
  final SignupRepository _repository;

  ClearSavedSignupProgressUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.clearSavedProgress();
  }
}
