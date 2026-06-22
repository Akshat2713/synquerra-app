part of 'signup_bloc.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object?> get props => [];
}

class SignupProfileSubmitted extends SignupEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String birthDate;
  final String gender;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;

  const SignupProfileSubmitted({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.gender,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
  });

  @override
  List<Object?> get props => [firstName, lastName, email, phone];
}

class SignupCredentialsSubmitted extends SignupEvent {
  final String email;
  final String password;
  final String passwordConfirmation;

  const SignupCredentialsSubmitted({
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [password, passwordConfirmation];
}

class SignupDeviceLinked extends SignupEvent {
  final String deviceSerialNo;

  const SignupDeviceLinked({required this.deviceSerialNo});

  @override
  List<Object?> get props => [deviceSerialNo];
}

class SignupStepBack extends SignupEvent {
  const SignupStepBack();
}

class SignupReset extends SignupEvent {
  const SignupReset();
}

class SignupProgressRestored extends SignupEvent {
  const SignupProgressRestored();
}
