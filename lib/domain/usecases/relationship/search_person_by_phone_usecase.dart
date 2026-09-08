import 'package:dartz/dartz.dart';
import '../../entities/signup/person_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/relationship_repository.dart';

class SearchPersonByPhoneUseCase {
  final RelationshipRepository _repository;
  SearchPersonByPhoneUseCase(this._repository);

  Future<Either<Failure, PersonEntity>> call(String phoneNumber) {
    return _repository.searchPersonByPhone(phoneNumber);
  }
}
