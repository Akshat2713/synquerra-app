// lib/domain/repositories/user_repository.dart

import 'package:dartz/dartz.dart';
import 'package:synquerra/domain/entities/signup/person_entity.dart';
import '../failures/failure.dart';

abstract class UserRepository {
  Future<Either<Failure, PersonEntity>> getUserProfile();
}
