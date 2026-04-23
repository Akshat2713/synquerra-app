// lib/data/repositories_impl/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../business/repositories/auth_repository.dart';
import '../../business/entities/user_entity.dart';
import '../../business/entities/signup_input_entity.dart';
import '../../business/failures/failure.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../mappers/user_mapper.dart';
import '../network/error_handler.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final UserMapper _mapper;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required UserMapper mapper,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _mapper = mapper;

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final userModel = await _remoteDataSource.login(email, password);
      final userEntity = _mapper.toEntity(userModel);

      // Save to local storage
      await _localDataSource.saveUser(userModel);

      return Right(userEntity);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signup(SignupInputEntity input) async {
    try {
      final inputMap = {
        'firstName': input.firstName,
        'lastName': input.lastName,
        'email': input.email,
        'mobile': input.mobile,
        'password': input.password,
      };

      final userModel = await _remoteDataSource.signup(inputMap);
      final userEntity = _mapper.toEntity(userModel);

      return Right(userEntity);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _localDataSource.clearUserData();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to logout: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getUser() async {
    try {
      final userModel = await _localDataSource.getUser();
      if (userModel == null) {
        return const Right(null);
      }
      final userEntity = _mapper.toEntity(userModel);
      return Right(userEntity);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveUser(UserEntity user) async {
    try {
      final userModel = _mapper.toModel(user);
      await _localDataSource.saveUser(userModel);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to save user: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final isAuth = await _localDataSource.isAuthenticated();
      return Right(isAuth);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to check authentication status'),
      );
    }
  }

  @override
  Future<Either<Failure, String?>> getAccessToken() async {
    try {
      final token = await _localDataSource.getAccessToken();
      return Right(token);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get access token'));
    }
  }
}
