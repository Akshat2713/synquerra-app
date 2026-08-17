import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/error/app_exceptions.dart';
import '../../domain/entities/signup/person_entity.dart';
import '../../domain/entities/signup/signup_progress_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/signup_repository.dart';
import '../datasources/local/signup_local_datasource.dart';
import '../datasources/remote/signup_remote_datasource.dart';
import '../mappers/failure_mapper.dart';

class SignupRepositoryImpl implements SignupRepository {
  final SignupRemoteDataSource _remote;
  final SignupLocalDataSource _local;

  SignupRepositoryImpl({
    required SignupRemoteDataSource remote,
    required SignupLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  // ── Create Person ─────────────────────────────────────────
  @override
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
  }) async {
    try {
      final model = await _remote.createPerson(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        birthDate: birthDate,
        gender: gender,
        address: address,
        city: city,
        state: state,
        country: country,
        pincode: pincode,
      );
      final entity = model.toEntity();

      // Only save local progress if explicitly requested (e.g., during signup flow)
      if (saveSignupProgress) {
        await _local.saveProgress(
          step: 2,
          personId: entity.personId,
          email: entity.email ?? email,
        );
      }

      return Right(entity);
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }

  // ── Delete Person ──────────────────────────────────────────
  @override
  Future<Either<Failure, void>> deletePerson(String personId) async {
    try {
      await _remote.deletePerson(personId);
      return const Right(null);
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }

  // ── Step 2 ────────────────────────────────────────────────
  @override
  Future<Either<Failure, void>> createCredentials({
    required String personId,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _remote.createCredentials(
        personId: personId,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      await _local.saveProgress(step: 3, personId: personId, email: email);

      return const Right(null);
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }

  @override
  Future<Either<Failure, SignupProgressEntity?>> getSavedProgress() async {
    try {
      final localProgress = await _local.getSavedProgress();
      if (localProgress == null) return const Right(null);
      return Right(localProgress.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> clearSavedProgress() async {
    try {
      await _local.clearProgress();
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
