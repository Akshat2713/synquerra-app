part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}

class HomeDeviceToggled extends HomeEvent {
  final String imei;

  const HomeDeviceToggled(this.imei);

  @override
  List<Object?> get props => [imei];
}
