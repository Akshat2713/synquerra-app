import 'package:dartz/dartz.dart';
import '../entities/relationship/relationship_entity.dart';
import '../failures/failure.dart';

abstract class RelationshipRepository {
  Future<Either<Failure, List<RelationshipEntity>>> getRelationshipList(
    String personId,
  );
}
