import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../repositories/relationship_repository.dart';

class CreateRelationshipUseCase {
  final RelationshipRepository _repository;

  CreateRelationshipUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String relatedUserId,
    required String relationshipType,
  }) {
    return _repository.createRelationship(
      relatedUserId: relatedUserId,
      relationshipType: relationshipType,
    );
  }
}
