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
  final List<AlertErrorEntity> alerts;
  final List<DeviceEntity> devices;
  final Set<String> toggledImeis; // tracks visual active/inactive toggles

  const DeviceListLoaded({
    required this.alerts,
    required this.devices,
    this.toggledImeis = const {},
  });

  int get criticalAlertCount => alerts
      .where((a) => a.isCritical && !a.isAcknowledged)
      .map((a) => a.imei)
      .toSet()
      .length;

  int get devicesNeedingAttention => devices.where((d) => !d.hasData).length;

  // returns effective isActive state after toggle
  bool isDeviceActive(DeviceEntity device) {
    final isToggled = toggledImeis.contains(device.imei);
    return isToggled ? !device.isActive : device.isActive;
  }

  DeviceListLoaded copyWith({
    List<AlertErrorEntity>? alerts,
    List<DeviceEntity>? devices,
    Set<String>? toggledImeis,
  }) {
    return DeviceListLoaded(
      alerts: alerts ?? this.alerts,
      devices: devices ?? this.devices,
      toggledImeis: toggledImeis ?? this.toggledImeis,
    );
  }

  @override
  List<Object?> get props => [alerts, devices, toggledImeis];
}

class DeviceListError extends DeviceListState {
  final String message;

  const DeviceListError(this.message);

  @override
  List<Object?> get props => [message];
}
