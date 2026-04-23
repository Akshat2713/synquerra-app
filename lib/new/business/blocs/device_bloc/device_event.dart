// lib/business/blocs/device_bloc/device_event.dart
part of 'device_bloc.dart';

/// Base class for device events
abstract class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load device data for a specific IMEI
class DeviceDataRequested extends DeviceEvent {
  final String imei;

  const DeviceDataRequested({required this.imei});

  @override
  List<Object?> get props => [imei];
}

/// Event to refresh device data (force refresh)
class DeviceRefreshRequested extends DeviceEvent {
  final String imei;

  const DeviceRefreshRequested({required this.imei});

  @override
  List<Object?> get props => [imei];
}

/// Event to load history data
class DeviceHistoryRequested extends DeviceEvent {
  final String imei;

  const DeviceHistoryRequested({required this.imei});

  @override
  List<Object?> get props => [imei];
}

/// Event to clear device data (for logout)
class DeviceDataCleared extends DeviceEvent {}
