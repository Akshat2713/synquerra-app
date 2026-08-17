import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../repositories/relationship_repository.dart';
import '../base_usecase.dart';

class UnlinkRelationshipUseCase implements UseCase<void, String> {
  final RelationshipRepository _repository;

  UnlinkRelationshipUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(String relationshipId) {
    return _repository.unlinkRelationship(relationshipId);
  }
}
