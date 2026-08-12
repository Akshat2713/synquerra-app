import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../repositories/signup_repository.dart';

class DeletePersonUseCase {
  final SignupRepository _repository;

  DeletePersonUseCase(this._repository);

  Future<Either<Failure, void>> call(String personId) {
    return _repository.deletePerson(personId);
  }
}
