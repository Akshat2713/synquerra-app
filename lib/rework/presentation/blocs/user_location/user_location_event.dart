part of 'user_location_bloc.dart';

abstract class UserLocationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchUserLocation extends UserLocationEvent {}
