part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<AlertErrorEntity> alerts;
  final List<DeviceEntity> devices;
  final Set<String> toggledImeis; // tracks visual active/inactive toggles

  const HomeLoaded({
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

  @override
  List<Object?> get props => [alerts, devices, toggledImeis];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
