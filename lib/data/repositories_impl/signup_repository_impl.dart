import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/error/app_exceptions.dart';
import '../../domain/entities/signup/person_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/signup_repository.dart';
import '../datasources/remote/signup_remote_datasource.dart';
import '../mappers/failure_mapper.dart';

class SignupRepositoryImpl implements SignupRepository {
  final SignupRemoteDataSource _remote;

  SignupRepositoryImpl({required SignupRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, PersonEntity>> signUp({
    required String firstName,
    required String email,
    required String password,
    String? lastName,
    String? phone,
    String? userClass,
    String? birthDate,
    String? gender,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
    String? profilePhoto,
  }) async {
    try {
      final model = await _remote.signUp(
        firstName: firstName,
        email: email,
        password: password,
        lastName: lastName,
        phone: phone,
        userClass: userClass,
        birthDate: birthDate,
        gender: gender,
        address: address,
        city: city,
        state: state,
        country: country,
        pincode: pincode,
        profilePhoto: profilePhoto,
      );
      return Right(model.toEntity());
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }

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
}
