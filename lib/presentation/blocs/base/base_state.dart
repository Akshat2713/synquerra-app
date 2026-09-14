// lib/presentation/blocs/base/base_state.dart

import 'package:equatable/equatable.dart';

abstract class BaseState extends Equatable {
  const BaseState();

  @override
  List<Object?> get props => [];
}

/// Generic Loading mixin
mixin LoadingState on BaseState {}

/// Generic Error mixin with message property
mixin ErrorState on BaseState {
  String get message;
}
