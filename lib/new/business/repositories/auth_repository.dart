// lib/business/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../entities/signup_input_entity.dart';
import '../failures/failure.dart';

abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, UserEntity>> login(String email, String password);

  /// Signup with user details
  Future<Either<Failure, UserEntity>> signup(SignupInputEntity input);

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Get stored user data
  Future<Either<Failure, UserEntity?>> getUser();

  /// Save user data to local storage
  Future<Either<Failure, void>> saveUser(UserEntity user);

  /// Check if user is authenticated
  Future<Either<Failure, bool>> isAuthenticated();

  /// Get access token
  Future<Either<Failure, String?>> getAccessToken();
}
