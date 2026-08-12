import 'package:dartz/dartz.dart';
import '../../domain/entities/relationship/relationship_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/relationship_repository.dart';
import '../datasources/remote/relationship_remote_datasource.dart';
import 'repository_helper.dart';

class RelationshipRepositoryImpl implements RelationshipRepository {
  final RelationshipRemoteDataSource _remote;

  RelationshipRepositoryImpl({required RelationshipRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, List<RelationshipEntity>>> getRelationshipList(
    String personId,
  ) async {
    return await safeListCall(
      call: () => _remote.getRelationshipList(personId),
      toEntity: (m) => m.toEntity(),
    );
  }
}
