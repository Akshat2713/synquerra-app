// lib/business/usecases/auth/login_usecase.dart
import 'package:dartz/dartz.dart';
import '../../repositories/auth_repository.dart';
import '../../entities/user_entity.dart';
import '../../failures/failure.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(
    String email,
    String password,
  ) async {
    // Basic validation
    if (email.isEmpty) {
      return Left(ValidationFailure(message: 'Email cannot be empty'));
    }
    if (password.isEmpty) {
      return Left(ValidationFailure(message: 'Password cannot be empty'));
    }
    if (!_isValidEmail(email)) {
      return Left(
        ValidationFailure(message: 'Please enter a valid email address'),
      );
    }
    if (password.length < 8) {
      return Left(
        ValidationFailure(message: 'Password must be at least 8 characters'),
      );
    }

    return await _repository.login(email, password);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
