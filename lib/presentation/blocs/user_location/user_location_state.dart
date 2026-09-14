// lib/presentation/blocs/user_location/user_location_state.dart

part of 'user_location_bloc.dart';

abstract class UserLocationState extends BaseState {
  const UserLocationState();
}

class UserLocationInitial extends UserLocationState {
  const UserLocationInitial();
}

class UserLocationLoading extends UserLocationState with LoadingState {
  const UserLocationLoading();
}

class UserLocationLoaded extends UserLocationState {
  final LatLng position;

  const UserLocationLoaded(this.position);

  @override
  List<Object?> get props => [position];
}

class UserLocationError extends UserLocationState with ErrorState {
  @override
  final String message;

  const UserLocationError(this.message);

  @override
  List<Object?> get props => [message];
}
