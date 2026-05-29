import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/auth/user_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/error/app_exceptions.dart';
// import '../../core/error/failure_mapper.dart';
import '../../core/di/injection_container.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../mappers/failure_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remote.login(email: email, password: password);
      await _local.saveUser(model);
      final entity = model.toEntity();
      registerUser(entity);
      return Right(entity);
    } catch (e) {
      final cause = (e is DioException && e.error is AppException)
          ? e.error as AppException
          : e;
      return Left(mapExceptionToFailure(cause));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getLoggedInUser() async {
    try {
      final model = await _local.getUser();
      if (model != null) {
        final entity = model.toEntity();
        registerUser(entity);
        return Right(entity);
      }
      return const Right(null);
    } catch (e) {
      // Local/cache operations don't go through Dio, no unwrapping needed
      final cause = e is CacheException ? e : e;
      return Left(mapExceptionToFailure(cause));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _local.clearUser();
      if (sl.isRegistered<UserHolder>()) {
        sl.unregister<UserHolder>();
        sl.registerLazySingleton<UserHolder>(() => const UserHolder(null));
      }
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
