// lib/business/entities/signup_input_entity.dart
import 'package:equatable/equatable.dart';

class SignupInputEntity extends Equatable {
  final String firstName;
  final String? middleName;
  final String lastName;
  final String email;
  final String mobile;
  final String password;

  const SignupInputEntity({
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.password,
  });

  @override
  List<Object?> get props => [
    firstName,
    middleName,
    lastName,
    email,
    mobile,
    password,
  ];
}
