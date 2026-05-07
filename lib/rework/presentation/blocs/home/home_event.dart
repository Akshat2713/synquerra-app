part of 'home_bloc.dart';

abstract class HomeEvent {}

class HomeLoadRequested extends HomeEvent {}

class HomeRefreshRequested extends HomeEvent {}

class HomeDeviceToggled extends HomeEvent {
  final String imei;
  HomeDeviceToggled(this.imei);
}
