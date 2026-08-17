import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../repositories/relationship_repository.dart';

class CreateRelationshipByPhoneUseCase {
  final RelationshipRepository _repository;

  CreateRelationshipByPhoneUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String personId,
    required String phoneNumber,
    required String relationType,
  }) {
    return _repository.createRelationshipByPhone(
      personId: personId,
      phoneNumber: phoneNumber,
      relationType: relationType,
    );
  }
}
