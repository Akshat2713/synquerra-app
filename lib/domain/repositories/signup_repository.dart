import 'package:dartz/dartz.dart';

import '../entities/signup/signup_entity.dart';
import '../entities/signup/signup_progress_entity.dart';
import '../failures/failure.dart';

abstract class SignupRepository {
  Future<Either<Failure, PersonEntity>> createPerson({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String birthDate,
    required String gender,
    required String address,
    required String city,
    required String state,
    required String country,
    required String pincode,
  });

  Future<Either<Failure, void>> createCredentials({
    required String personId,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  /// Returns [SignupProgressEntity] instead of the data layer model
  Future<Either<Failure, SignupProgressEntity?>> getSavedProgress();

  Future<Either<Failure, void>> clearSavedProgress();
}
