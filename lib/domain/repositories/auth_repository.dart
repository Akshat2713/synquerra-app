import 'package:dartz/dartz.dart';
import '../entities/auth/user_entity.dart';
import '../failures/failure.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity?>> getLoggedInUser();

  Future<Either<Failure, void>> logout();
}
