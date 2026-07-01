import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/signup_repository.dart';
import '../../core/error/app_exceptions.dart';
import '../../domain/entities/signup/signup_entity.dart';
import '../datasources/remote/signup_remote_datasource.dart';
import '../datasources/local/signup_local_datasource.dart';
import '../mappers/failure_mapper.dart';

class SignupRepositoryImpl implements SignupRepository {
  final SignupRemoteDataSource _remote;
  final SignupLocalDataSource _local;

  SignupRepositoryImpl({
    required SignupRemoteDataSource remote,
    required SignupLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  // ── Step 1 ────────────────────────────────────────────────
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

      await _local.saveProgress(
        step: 2,
        personId: entity.personId,
        email: entity.email!,
      );

      return Right(entity);
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

  // ── Step 3 ────────────────────────────────────────────────
  @override
  Future<Either<Failure, void>> linkDevice({
    required String ownerId,
    required String ownerType,
    required String deviceSerialNo,
  }) async {
    try {
      await _remote.linkDevice(
        ownerId: ownerId,
        ownerType: ownerType,
        deviceSerialNo: deviceSerialNo,
      );

      await _local.clearProgress();

      return const Right(null);
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }

  // ── Get Saved Progress ────────────────────────────────────
  @override
  Future<Either<Failure, SignupProgress?>> getSavedProgress() async {
    try {
      final progress = await _local.getProgress();
      return Right(progress);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  // ── Clear Saved Progress ──────────────────────────────────
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
