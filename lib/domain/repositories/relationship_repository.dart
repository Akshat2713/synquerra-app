// lib/features/relationship/domain/repositories/relationship_repository.dart

import 'package:dartz/dartz.dart';
import '../entities/relationship/relationship_entity.dart';
import '../entities/signup/person_entity.dart';
import '../failures/failure.dart';

abstract class RelationshipRepository {
  Future<Either<Failure, List<RelationshipEntity>>> getRelationshipList(
    String personId,
  );
  Future<Either<Failure, PersonEntity>> searchPersonByPhone(String phoneNumber);

  Future<Either<Failure, void>> createRelationship({
    required String relatedUserId,
    required String relationshipType,
  });
  Future<Either<Failure, PersonEntity>> createPersonWithRelationship({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String relationshipType,
    String? middleName,
    String? mobile,
    String? birthDate,
    String? gender,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
    bool isHead = false,
  });
  Future<Either<Failure, void>> unlinkRelationship(String relationshipId);
}
