part of 'signup_bloc.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object?> get props => [];
}

class SignupSubmitted extends SignupEvent {
  final String firstName;
  final String email;
  final String password;
  final String? lastName;
  final String? phone;
  final String? birthDate;
  final String? gender;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;

  const SignupSubmitted({
    required this.firstName,
    required this.email,
    required this.password,
    this.lastName,
    this.phone,
    this.birthDate,
    this.gender,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pincode,
  });

  @override
  List<Object?> get props => [firstName, email, password];
}

class SignupReset extends SignupEvent {
  const SignupReset();
}
