part of 'home_bloc.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<AlertErrorEntity> alerts;
  final List<DeviceEntity> devices;
  final Set<String> toggledImeis; // tracks visual active/inactive toggles

  HomeLoaded({
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

  HomeLoaded copyWith({
    List<AlertErrorEntity>? alerts,
    List<DeviceEntity>? devices,
    Set<String>? toggledImeis,
  }) {
    return HomeLoaded(
      alerts: alerts ?? this.alerts,
      devices: devices ?? this.devices,
      toggledImeis: toggledImeis ?? this.toggledImeis,
    );
  }
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
