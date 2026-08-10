part of 'manage_bloc.dart';

abstract class ManageEvent extends Equatable {
  const ManageEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load for the Manage screen: fetches Modes & Settings concurrently.
class ManageLoadRequested extends ManageEvent {
  final DeviceEntity device;

  const ManageLoadRequested(this.device);

  @override
  List<Object?> get props => [device];
}

/// Request to switch active tracking mode.
class ManageModeSwitchRequested extends ManageEvent {
  final String deviceId;
  final String modeId;

  const ManageModeSwitchRequested({
    required this.deviceId,
    required this.modeId,
  });

  @override
  List<Object?> get props => [deviceId, modeId];
}

/// Request to update emergency phone numbers.
class ManagePhoneNumbersUpdateRequested extends ManageEvent {
  final String deviceId;
  final String? phoneNum1;
  final String? phoneNum2;

  const ManagePhoneNumbersUpdateRequested({
    required this.deviceId,
    this.phoneNum1,
    this.phoneNum2,
  });

  @override
  List<Object?> get props => [deviceId, phoneNum1, phoneNum2];
}
