// lib/business/blocs/searched_device_bloc/searched_device_event.dart
part of 'searched_device_bloc.dart';

/// Base class for searched device events
abstract class SearchedDeviceEvent extends Equatable {
  const SearchedDeviceEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch a searched device by IMEI
class SearchedDeviceFetchRequested extends SearchedDeviceEvent {
  final String imei;

  const SearchedDeviceFetchRequested({required this.imei});

  @override
  List<Object?> get props => [imei];
}

/// Event to clear the searched device data
class SearchedDeviceCleared extends SearchedDeviceEvent {}
