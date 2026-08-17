part of 'manage_devices_bloc.dart';

abstract class ManageDevicesEvent extends Equatable {
  const ManageDevicesEvent();
  @override
  List<Object?> get props => [];
}

class ManageDevicesLoadRequested extends ManageDevicesEvent {
  const ManageDevicesLoadRequested();
}

class ManageDevicesAssignRequested extends ManageDevicesEvent {
  final String deviceId;
  final String personId;
  final String associationType;
  const ManageDevicesAssignRequested({
    required this.deviceId,
    required this.personId,
    required this.associationType,
  });
  @override
  List<Object?> get props => [deviceId, personId, associationType];
}

class ManageDevicesUnassignRequested extends ManageDevicesEvent {
  final String? personId;
  final String deviceId;
  final String associationType;
  const ManageDevicesUnassignRequested({
    this.personId,
    required this.deviceId,
    required this.associationType,
  });
  @override
  List<Object?> get props => [deviceId, associationType];
}
