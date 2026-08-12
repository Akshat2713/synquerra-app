import 'package:dartz/dartz.dart';
import '../../entities/relationship/relationship_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/relationship_repository.dart';
import '../base_usecase.dart';

class GetRelationshipListUseCase
    implements UseCase<List<RelationshipEntity>, String> {
  final RelationshipRepository _repository;

  GetRelationshipListUseCase(this._repository);

  @override
  Future<Either<Failure, List<RelationshipEntity>>> call(String personId) =>
      _repository.getRelationshipList(personId);
}
