part of 'device_list_bloc.dart';

abstract class DeviceListEvent extends Equatable {
  const DeviceListEvent();

  @override
  List<Object?> get props => [];
}

class DeviceListLoadRequested extends DeviceListEvent {
  const DeviceListLoadRequested();
}

// device_list_event.dart
class DeviceListRefreshRequested extends DeviceListEvent {
  final Completer<void>? completer;
  const DeviceListRefreshRequested({this.completer});
}

class DeviceListDeviceToggled extends DeviceListEvent {
  final String imei;

  const DeviceListDeviceToggled(this.imei);

  @override
  List<Object?> get props => [imei];
}
