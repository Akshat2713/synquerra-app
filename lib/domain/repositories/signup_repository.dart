import 'package:dartz/dartz.dart';

import '../entities/signup/person_entity.dart';
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
    bool saveSignupProgress = false,
  });

  Future<Either<Failure, void>> deletePerson(String personId);

  Future<Either<Failure, void>> createCredentials({
    required String personId,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<Either<Failure, SignupProgressEntity?>> getSavedProgress();

  Future<Either<Failure, void>> clearSavedProgress();
}
