part of 'device_list_bloc.dart';

abstract class DeviceListState extends Equatable {
  const DeviceListState();

  @override
  List<Object?> get props => [];
}

class DeviceListInitial extends DeviceListState {
  const DeviceListInitial();
}

class DeviceListLoading extends DeviceListState {
  const DeviceListLoading();
}

class DeviceListLoaded extends DeviceListState {
  final List<DeviceEntity> devices;
  final Set<String> toggledImeis;
  const DeviceListLoaded({required this.devices, this.toggledImeis = const {}});

  // remove: criticalAlertCount getter (alerts no longer live here)
  int get devicesNeedingAttention => devices.where((d) => !d.hasData).length;

  bool isDeviceActive(DeviceEntity device) {
    final isToggled = toggledImeis.contains(device.imei);
    return isToggled ? !device.isActive : device.isActive;
  }

  DeviceListLoaded copyWith({
    List<DeviceEntity>? devices,
    Set<String>? toggledImeis,
  }) => DeviceListLoaded(
    devices: devices ?? this.devices,
    toggledImeis: toggledImeis ?? this.toggledImeis,
  );

  @override
  List<Object?> get props => [devices, toggledImeis];
}

class DeviceListError extends DeviceListState {
  final String message;

  const DeviceListError(this.message);

  @override
  List<Object?> get props => [message];
}
