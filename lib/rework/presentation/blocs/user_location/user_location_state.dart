part of 'user_location_bloc.dart';

abstract class UserLocationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserLocationInitial extends UserLocationState {}

class UserLocationLoading extends UserLocationState {}

class UserLocationLoaded extends UserLocationState {
  final LatLng position;
  UserLocationLoaded(this.position);
  @override
  List<Object?> get props => [position];
}

class UserLocationError extends UserLocationState {
  final String message;
  UserLocationError(this.message);
  @override
  List<Object?> get props => [message];
}
