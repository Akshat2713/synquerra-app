// lib/business/usecases/auth/signup_usecase.dart
import 'package:dartz/dartz.dart';
import '../../repositories/auth_repository.dart';
import '../../entities/user_entity.dart';
import '../../entities/signup_input_entity.dart';
import '../../failures/failure.dart';

class SignupUseCase {
  final AuthRepository _repository;

  SignupUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(SignupInputEntity input) async {
    // Validation
    if (input.firstName.isEmpty) {
      return Left(ValidationFailure(message: 'First name cannot be empty'));
    }
    if (input.lastName.isEmpty) {
      return Left(ValidationFailure(message: 'Last name cannot be empty'));
    }
    if (input.email.isEmpty) {
      return Left(ValidationFailure(message: 'Email cannot be empty'));
    }
    if (input.mobile.isEmpty) {
      return Left(ValidationFailure(message: 'Mobile number cannot be empty'));
    }
    if (input.password.isEmpty) {
      return Left(ValidationFailure(message: 'Password cannot be empty'));
    }

    if (!_isValidEmail(input.email)) {
      return Left(
        ValidationFailure(message: 'Please enter a valid email address'),
      );
    }

    if (input.mobile.length < 10) {
      return Left(
        ValidationFailure(message: 'Please enter a valid mobile number'),
      );
    }

    if (input.password.length < 8) {
      return Left(
        ValidationFailure(message: 'Password must be at least 8 characters'),
      );
    }

    if (!_hasUpperCase(input.password)) {
      return Left(
        ValidationFailure(
          message: 'Password must contain at least one uppercase letter',
        ),
      );
    }

    if (!_hasNumber(input.password)) {
      return Left(
        ValidationFailure(message: 'Password must contain at least one number'),
      );
    }

    return await _repository.signup(input);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _hasUpperCase(String password) {
    return password.contains(RegExp(r'[A-Z]'));
  }

  bool _hasNumber(String password) {
    return password.contains(RegExp(r'[0-9]'));
  }
}
