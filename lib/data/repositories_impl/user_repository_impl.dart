// lib/data/repositories/user_repository_impl.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:synquerra/domain/entities/signup/person_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/user_repository.dart';
import '../../core/error/app_exceptions.dart';
import '../datasources/remote/user_remote_datasource.dart';
import '../mappers/failure_mapper.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remote;

  UserRepositoryImpl({required UserRemoteDataSource remote}) : _remote = remote;

  @override
  Future<Either<Failure, PersonEntity>> getUserProfile() async {
    try {
      final model = await _remote.fetchUserProfile();
      return Right(model.toEntity());
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }

  @override
  Future<Either<Failure, PersonEntity>> updateUserProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? password,
    String? relationshipType,
    bool? isHead,
    String? middleName,
    String? mobile,
    String? birthDate,
    String? gender,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
    File? profileImage,
  }) async {
    try {
      final model = await _remote.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        relationshipType: relationshipType,
        isHead: isHead,
        middleName: middleName,
        mobile: mobile,
        birthDate: birthDate,
        gender: gender,
        address: address,
        city: city,
        state: state,
        country: country,
        pincode: pincode,
        profileImage: profileImage,
      );
      return Right(model.toEntity());
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }
}
