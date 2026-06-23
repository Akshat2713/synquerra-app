part of 'device_list_bloc.dart';

abstract class DeviceListEvent extends Equatable {
  const DeviceListEvent();

  @override
  List<Object?> get props => [];
}

class DeviceListLoadRequested extends DeviceListEvent {
  const DeviceListLoadRequested();
}

class DeviceListRefreshRequested extends DeviceListEvent {
  const DeviceListRefreshRequested();
}

class DeviceListDeviceToggled extends DeviceListEvent {
  final String imei;

  const DeviceListDeviceToggled(this.imei);

  @override
  List<Object?> get props => [imei];
}
