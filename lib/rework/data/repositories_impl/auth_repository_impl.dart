import 'package:dartz/dartz.dart';
import '../../domain/entities/auth/user_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/error/app_exceptions.dart';
import '../../core/di/injection_container.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../datasources/local/auth_local_datasource.dart';

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

      // Store user globally for access across all screens
      registerUser(entity);

      return Right(entity);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getLoggedInUser() async {
    try {
      final model = await _local.getUser();
      if (model != null) {
        final entity = model.toEntity();
        // Restore user singleton on app restart
        registerUser(entity);
        return Right(entity);
      }
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _local.clearUser();
      // Clear user singleton
      if (sl.isRegistered<UserHolder>()) {
        sl.unregister<UserHolder>();
        sl.registerLazySingleton<UserHolder>(() => const UserHolder(null));
      }
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
