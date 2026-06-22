import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../repositories/signup_repository.dart';
import '../base_usecase.dart';
import '../../../data/datasources/local/signup_local_datasource.dart';

class GetSavedSignupProgressUseCase
    implements UseCase<SignupProgress?, NoParams> {
  final SignupRepository _repository;

  GetSavedSignupProgressUseCase(this._repository);

  @override
  Future<Either<Failure, SignupProgress?>> call(NoParams params) {
    return _repository.getSavedProgress();
  }
}
