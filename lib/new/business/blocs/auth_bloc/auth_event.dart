// lib/business/blocs/auth_bloc/auth_event.dart
part of 'auth_bloc.dart';

/// Base class for all authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check if user is already authenticated (splash screen)
class AuthCheckStatusRequested extends AuthEvent {}

/// Event to login with email and password
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Event to sign up a new user
class AuthSignupRequested extends AuthEvent {
  final SignupInputEntity input;

  const AuthSignupRequested({required this.input});

  @override
  List<Object?> get props => [input];
}

/// Event to logout the current user
class AuthLogoutRequested extends AuthEvent {}

/// Event to update/save user data
class AuthUserUpdated extends AuthEvent {
  final UserEntity user;

  const AuthUserUpdated({required this.user});

  @override
  List<Object?> get props => [user];
}
