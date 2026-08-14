// lib/features/relationship/data/repositories/relationship_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../core/error/app_exceptions.dart';
import '../../domain/entities/relationship/relationship_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/relationship_repository.dart';
import '../datasources/remote/relationship_remote_datasource.dart';
import '../mappers/failure_mapper.dart';
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

  @override
  Future<Either<Failure, void>> createRelationship({
    required String personAId,
    required String personBId,
    required String relationshipType,
  }) async {
    try {
      await _remote.createRelationship(
        personAId: personAId,
        personBId: personBId,
        relationshipType: relationshipType,
      );
      return const Right(null);
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }

  @override
  Future<Either<Failure, void>> unlinkRelationship(
    String relationshipId,
  ) async {
    try {
      await _remote.unlinkRelationship(relationshipId);
      return const Right(null);
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }

  @override
  Future<Either<Failure, void>> createRelationshipByPhone({
    required String personId,
    required String phoneNumber,
    required String relationType,
  }) async {
    try {
      await _remote.createRelationshipByPhone(
        personId: personId,
        phoneNumber: phoneNumber,
        relationType: relationType,
      );
      return const Right(null);
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }
}
