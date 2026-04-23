// lib/business/blocs/auth_bloc/auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../repositories/auth_repository.dart';
import '../../entities/user_entity.dart';
import '../../entities/signup_input_entity.dart';
import '../../failures/failure.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthInitial()) {
    on<AuthCheckStatusRequested>(_onCheckStatusRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUserUpdated>(_onUserUpdated);
  }

  /// Handle check status event
  Future<void> _onCheckStatusRequested(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.getUser();

    result.fold((failure) => emit(AuthUnauthenticated()), (user) {
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  /// Handle login event
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('Login requested for: ${event.email}'); // Add this
    emit(AuthLoading());

    final result = await _authRepository.login(event.email, event.password);

    debugPrint('Login result: $result'); // Add this

    result.fold(
      (failure) {
        debugPrint('Login failure: ${failure.message}'); // Add this
        emit(AuthError(message: _mapFailureToMessage(failure)));
      },
      (user) {
        debugPrint('Login success for user: ${user.email}'); // Add this
        emit(AuthAuthenticated(user: user));
      },
    );
  }

  /// Handle signup event
  Future<void> _onSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.signup(event.input);

    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  /// Handle logout event
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.logout();

    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  /// Handle user update event
  Future<void> _onUserUpdated(
    AuthUserUpdated event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;

    if (currentState is AuthAuthenticated) {
      emit(AuthAuthenticated(user: event.user));
    }
  }

  /// Map failure to user-friendly message
  String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'No internet connection. Please check your network.';
    } else if (failure is ServerFailure) {
      return failure.message.isNotEmpty
          ? failure.message
          : 'Server error. Please try again later.';
    } else if (failure is AuthFailure) {
      return failure.message.isNotEmpty
          ? failure.message
          : 'Invalid email or password.';
    } else if (failure is CacheFailure) {
      return 'Unable to save user data. Please try again.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
}
