import 'package:dartz/dartz.dart';
import '../../data/datasources/local/signup_local_datasource.dart';
import '../failures/failure.dart';
import '../entities/signup/signup_entity.dart';

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

  Future<Either<Failure, void>> linkDevice({
    required String ownerId,
    required String deviceSerialNo,
  });

  Future<Either<Failure, SignupProgress?>> getSavedProgress();
  Future<Either<Failure, void>> clearSavedProgress();
}
