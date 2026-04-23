// lib/business/blocs/auth_bloc/auth_state.dart
part of 'auth_bloc.dart';

/// Base class for all authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - before any action
class AuthInitial extends AuthState {}

/// Loading state - during login, signup, or logout
class AuthLoading extends AuthState {}

/// Authenticated state - user is logged in
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state - user is not logged in
class AuthUnauthenticated extends AuthState {}

/// Error state - authentication failed
class AuthError extends AuthState {
  final String message;
  final int? statusCode;

  const AuthError({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}
