// lib/data/repositories/user_repository_impl.dart

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
      final entity = model.toEntity();
      return Right(entity);
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }
}
